import '../../../../core/errors/exceptions.dart';
import '../../../events_workshops_craft/data/datasources/events_remote_data_source.dart';
import '../../../events_workshops_craft/domain/entities/event_entities.dart';
import '../../domain/entities/booking_entities.dart';
import '../../domain/repositories/booking_repository.dart';
import '../datasources/booking_remote_data_source.dart';

class BookingRepositoryImpl implements BookingRepository {
  BookingRepositoryImpl({required this.remote, required this.events});

  final BookingRemoteDataSource remote;

  /// Sự kiện/workshop (FE-06) cũng là dịch vụ có thể đặt chỗ.
  final EventsRemoteDataSource events;

  late final List<BookableService> _standalone = StandaloneServiceSampleData.services();

  BookableService _fromEvent(EventWorkshop e) => BookableService(
        id: e.id,
        title: e.title,
        typeLabel: e.kind.label,
        price: e.price,
        coverImage: e.coverImage,
        venue: e.venue,
        sessions: [e.startAt],
        remainingSlots: e.remainingSlots,
        durationLabel: '${e.endAt.difference(e.startAt).inMinutes} phút',
        maxPerBooking: e.price == 0 ? 6 : 10,
      );

  @override
  Future<List<BookableService>> getBookableServices() async {
    final evs = await events.fetchEvents();
    return [
      ..._standalone,
      ...evs.where((e) => e.isUpcoming && e.startAt.isAfter(DateTime.now())).map(_fromEvent),
    ];
  }

  @override
  Future<BookableService> getService(String serviceId) async {
    final all = await getBookableServices();
    return all.firstWhere(
      (s) => s.id == serviceId,
      orElse: () => throw const ServerException('Dịch vụ không tồn tại hoặc đã ngừng nhận đặt chỗ.'),
    );
  }

  @override
  Future<Booking> createBooking(BookingRequest r) async {
    final booking = Booking(
      id: 'bk_${DateTime.now().millisecondsSinceEpoch}',
      code: generateBookingCode(),
      userId: r.userId,
      serviceId: r.service.id,
      serviceTitle: r.service.title,
      serviceImage: r.service.coverImage,
      venue: r.service.venue,
      sessionAt: r.sessionAt,
      participants: r.participants,
      unitPrice: r.service.price,
      status: BookingStatus.pending,
      contactName: r.contactName,
      contactPhone: r.contactPhone,
      note: r.note,
      createdAt: DateTime.now(),
    );
    final saved = await remote.create(booking);
    await events.adjustBookedCount(r.service.id, r.participants);
    return saved;
  }

  @override
  Future<List<Booking>> getMyBookings(String userId) async {
    final list = await remote.fetchByUser(userId);
    return list..sort((a, b) => b.sessionAt.compareTo(a.sessionAt));
  }

  @override
  Future<Booking> getBooking(String bookingId) => remote.fetchById(bookingId);

  @override
  Future<Booking> cancelBooking(String bookingId) async {
    final current = await remote.fetchById(bookingId);
    if (!current.canCancel) {
      throw const ServerException('Đơn này không thể hủy (đã diễn ra hoặc còn dưới 2 giờ trước giờ bắt đầu).');
    }
    final updated = await remote.updateStatus(bookingId, BookingStatus.cancelled);
    await events.adjustBookedCount(current.serviceId, -current.participants);
    return updated;
  }
}
