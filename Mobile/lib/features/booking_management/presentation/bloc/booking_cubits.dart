import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/view_status.dart';
import '../../domain/entities/booking_entities.dart';
import '../../domain/usecases/booking_usecases.dart';

// ─────────────────────────── Form đặt chỗ ───────────────────────────

class BookingFormState extends Equatable {
  const BookingFormState({
    this.status = ViewStatus.initial,
    this.services = const [],
    this.selected,
    this.session,
    this.participants = 1,
    this.isSubmitting = false,
    this.created,
    this.errorMessage,
  });

  final ViewStatus status;
  final List<BookableService> services;
  final BookableService? selected;
  final DateTime? session;
  final int participants;
  final bool isSubmitting;
  final Booking? created;
  final String? errorMessage;

  int get total => (selected?.price ?? 0) * participants;
  int get maxParticipants {
    final s = selected;
    if (s == null) return 1;
    return s.remainingSlots < s.maxPerBooking ? s.remainingSlots : s.maxPerBooking;
  }

  BookingFormState copyWith({
    ViewStatus? status,
    List<BookableService>? services,
    BookableService? selected,
    DateTime? session,
    bool clearSession = false,
    int? participants,
    bool? isSubmitting,
    Booking? created,
    String? errorMessage,
  }) =>
      BookingFormState(
        status: status ?? this.status,
        services: services ?? this.services,
        selected: selected ?? this.selected,
        session: clearSession ? null : (session ?? this.session),
        participants: participants ?? this.participants,
        isSubmitting: isSubmitting ?? this.isSubmitting,
        created: created ?? this.created,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props => [status, services, selected, session, participants, isSubmitting, created, errorMessage];
}

class BookingFormCubit extends Cubit<BookingFormState> {
  BookingFormCubit(this._getServices, this._create) : super(const BookingFormState());

  final GetBookableServicesUseCase _getServices;
  final CreateBookingUseCase _create;

  Future<void> load(String serviceId) async {
    emit(state.copyWith(status: ViewStatus.loading));
    try {
      final services = await _getServices();
      final selected = services.where((s) => s.id == serviceId).firstOrNull ?? services.firstOrNull;
      emit(BookingFormState(
        status: ViewStatus.success,
        services: services,
        selected: selected,
        session: selected != null && selected.hasFixedSession ? selected.sessions.first : null,
      ));
    } catch (e) {
      emit(state.copyWith(status: ViewStatus.failure, errorMessage: errorMessageOf(e)));
    }
  }

  void selectService(BookableService service) => emit(BookingFormState(
        status: state.status,
        services: state.services,
        selected: service,
        session: service.hasFixedSession ? service.sessions.first : null,
      ));

  void selectSession(DateTime session) => emit(state.copyWith(session: session));

  void setParticipants(int value) => emit(state.copyWith(participants: value.clamp(1, state.maxParticipants)));

  Future<void> submit({
    required String userId,
    required String contactName,
    required String contactPhone,
    String note = '',
  }) async {
    final service = state.selected;
    final session = state.session;
    if (service == null || session == null) {
      emit(state.copyWith(errorMessage: 'Vui lòng chọn dịch vụ và khung giờ.'));
      return;
    }
    emit(state.copyWith(isSubmitting: true));
    try {
      final booking = await _create(BookingRequest(
        userId: userId,
        service: service,
        sessionAt: session,
        participants: state.participants,
        contactName: contactName,
        contactPhone: contactPhone,
        note: note,
      ));
      emit(state.copyWith(isSubmitting: false, created: booking));
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, errorMessage: errorMessageOf(e)));
    }
  }
}

// ─────────────────────────── Lịch sử & chi tiết ───────────────────────────

class BookingListState extends Equatable {
  const BookingListState({this.status = ViewStatus.initial, this.bookings = const [], this.errorMessage});

  final ViewStatus status;
  final List<Booking> bookings;
  final String? errorMessage;

  List<Booking> get upcoming =>
      bookings.where((b) => b.isUpcoming && b.status != BookingStatus.cancelled).toList().reversed.toList();
  List<Booking> get past => bookings.where((b) => !b.isUpcoming || b.status == BookingStatus.cancelled).toList();

  @override
  List<Object?> get props => [status, bookings, errorMessage];
}

class BookingHistoryCubit extends Cubit<BookingListState> {
  BookingHistoryCubit(this._getMine) : super(const BookingListState());

  final GetMyBookingsUseCase _getMine;

  Future<void> load(String userId) async {
    emit(BookingListState(status: ViewStatus.loading, bookings: state.bookings));
    try {
      emit(BookingListState(status: ViewStatus.success, bookings: await _getMine(userId)));
    } catch (e) {
      emit(BookingListState(status: ViewStatus.failure, errorMessage: errorMessageOf(e)));
    }
  }
}

class BookingDetailState extends Equatable {
  const BookingDetailState({this.status = ViewStatus.initial, this.booking, this.isCancelling = false, this.errorMessage});

  final ViewStatus status;
  final Booking? booking;
  final bool isCancelling;
  final String? errorMessage;

  @override
  List<Object?> get props => [status, booking, isCancelling, errorMessage];
}

class BookingDetailCubit extends Cubit<BookingDetailState> {
  BookingDetailCubit(this._get, this._cancel) : super(const BookingDetailState());

  final GetBookingDetailUseCase _get;
  final CancelBookingUseCase _cancel;

  Future<void> load(String id) async {
    emit(const BookingDetailState(status: ViewStatus.loading));
    try {
      emit(BookingDetailState(status: ViewStatus.success, booking: await _get(id)));
    } catch (e) {
      emit(BookingDetailState(status: ViewStatus.failure, errorMessage: errorMessageOf(e)));
    }
  }

  /// Trả về thông báo lỗi (null nếu thành công).
  Future<String?> cancel() async {
    final b = state.booking;
    if (b == null) return 'Không tìm thấy đơn.';
    emit(BookingDetailState(status: state.status, booking: b, isCancelling: true));
    try {
      final updated = await _cancel(b.id);
      emit(BookingDetailState(status: ViewStatus.success, booking: updated));
      return null;
    } catch (e) {
      emit(BookingDetailState(status: ViewStatus.success, booking: b));
      return errorMessageOf(e);
    }
  }
}
