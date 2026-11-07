import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/view_status.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_feedback.dart';
import '../../../../shared/widgets/cover_image.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/pill_badge.dart';
import '../../../../shared/widgets/topographic_scaffold.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../bloc/booking_cubits.dart';

/// [FE-07] Chọn dịch vụ/sự kiện/workshop, ngày giờ, số người và gửi yêu cầu đặt chỗ.
class BookingFormScreen extends StatelessWidget {
  const BookingFormScreen({super.key, required this.serviceId});

  final String serviceId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<BookingFormCubit>()..load(serviceId),
      child: const _BookingFormView(),
    );
  }
}

class _BookingFormView extends StatefulWidget {
  const _BookingFormView();

  @override
  State<_BookingFormView> createState() => _BookingFormViewState();
}

class _BookingFormViewState extends State<_BookingFormView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _phone;
  final _note = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthCubit>().state.user;
    _name = TextEditingController(text: user?.fullName ?? '');
    _phone = TextEditingController(text: user?.phone ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _note.dispose();
    super.dispose();
  }

  void _submit(BookingFormState state) {
    if (!_formKey.currentState!.validate()) return;
    if (state.session == null) {
      showAppSnackBar(context, 'Vui lòng chọn khung giờ tham gia.', type: SnackType.warning);
      return;
    }
    final user = context.read<AuthCubit>().state.user;
    if (user == null) return;
    context.read<BookingFormCubit>().submit(
          userId: user.uid,
          contactName: _name.text.trim(),
          contactPhone: _phone.text.trim(),
          note: _note.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BookingFormCubit, BookingFormState>(
      listenWhen: (a, b) => a.created != b.created || (b.errorMessage != null && a.errorMessage != b.errorMessage),
      listener: (context, state) {
        if (state.created != null) {
          context.pushReplacement(RouteNames.bookingConfirmation(state.created!.id));
        } else if (state.errorMessage != null) {
          showAppSnackBar(context, state.errorMessage!, type: SnackType.error);
        }
      },
      builder: (context, state) {
        final cubit = context.read<BookingFormCubit>();
        final s = state.selected;
        return TopographicScaffold(
          appBar: const CustomAppBar(title: 'Đặt chỗ', subtitle: 'Dịch vụ · Sự kiện · Workshop'),
          bottomNavigationBar: s == null
              ? null
              : Container(
                  padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.paddingOf(context).bottom + 12),
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceWhite,
                    border: Border(top: BorderSide(color: AppColors.cardBorder)),
                  ),
                  child: Row(
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Tạm tính', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                          Text(CurrencyFormatter.vnd(state.total),
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.primaryTeal)),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CustomButton(
                          label: 'Xác nhận đặt chỗ',
                          icon: Icons.check_circle_rounded,
                          isLoading: state.isSubmitting,
                          onPressed: s.remainingSlots == 0 ? null : () => _submit(state),
                        ),
                      ),
                    ],
                  ),
                ),
          body: Builder(
            builder: (context) {
              if (state.status.isFailure) {
                return ErrorViewWidget(message: state.errorMessage ?? 'Không tải được dịch vụ.');
              }
              if (state.status.isLoading || state.status == ViewStatus.initial) return const LoadingIndicator();
              if (s == null) {
                return const EmptyStateWidget(icon: Icons.event_busy_rounded, title: 'Không có dịch vụ khả dụng');
              }
              return Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                  children: [
                    const _Label('1. Chọn dịch vụ'),
                    DropdownButtonFormField<String>(
                      initialValue: s.id,
                      isExpanded: true,
                      decoration: const InputDecoration(prefixIcon: Icon(Icons.local_activity_rounded)),
                      items: [
                        for (final svc in state.services)
                          DropdownMenuItem(
                            value: svc.id,
                            child: Text('${svc.title} · ${svc.typeLabel}', overflow: TextOverflow.ellipsis),
                          ),
                      ],
                      onChanged: (id) => cubit.selectService(state.services.firstWhere((x) => x.id == id)),
                    ),
                    const SizedBox(height: 12),
                    AppCard(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          CoverImage(source: s.coverImage, width: 76, height: 76, radius: 14),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(s.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                                const SizedBox(height: 4),
                                Text(s.venue, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: [
                                    if (s.durationLabel.isNotEmpty)
                                      PillBadge(label: s.durationLabel, icon: Icons.timer_outlined),
                                    PillBadge(
                                      label: s.remainingSlots == 0 ? 'Hết chỗ' : 'Còn ${s.remainingSlots} chỗ',
                                      icon: Icons.event_seat_rounded,
                                      color: s.remainingSlots == 0 ? AppColors.error : AppColors.success,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const _Label('2. Chọn ngày giờ'),
                    _SessionPicker(state: state),
                    const SizedBox(height: 20),
                    const _Label('3. Số người tham gia'),
                    AppCard(
                      child: Row(
                        children: [
                          IconButton.filledTonal(
                            onPressed: state.participants > 1 ? () => cubit.setParticipants(state.participants - 1) : null,
                            icon: const Icon(Icons.remove_rounded),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Text('${state.participants}',
                                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                                Text('tối đa ${state.maxParticipants} người/lượt',
                                    style: const TextStyle(color: AppColors.textMuted, fontSize: 11.5)),
                              ],
                            ),
                          ),
                          IconButton.filledTonal(
                            onPressed: state.participants < state.maxParticipants
                                ? () => cubit.setParticipants(state.participants + 1)
                                : null,
                            icon: const Icon(Icons.add_rounded),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const _Label('4. Thông tin liên hệ'),
                    TextFormField(
                      controller: _name,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(labelText: 'Họ và tên', prefixIcon: Icon(Icons.person_outline)),
                      validator: (v) => Validators.required(v, 'họ và tên'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(labelText: 'Số điện thoại', prefixIcon: Icon(Icons.phone_outlined)),
                      validator: (v) => Validators.required(v, 'số điện thoại') ?? Validators.phone(v),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _note,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Ghi chú (không bắt buộc)',
                        hintText: 'Ví dụ: có trẻ em đi cùng, cần hỗ trợ xe lăn...',
                        prefixIcon: Icon(Icons.edit_note_rounded),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Bạn có thể hủy miễn phí trước giờ bắt đầu ít nhất 2 tiếng trong mục “Lịch sử đặt chỗ”.',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15.5)),
      );
}

class _SessionPicker extends StatelessWidget {
  const _SessionPicker({required this.state});

  final BookingFormState state;

  @override
  Widget build(BuildContext context) {
    final s = state.selected!;
    if (s.hasFixedSession) {
      final at = s.sessions.first;
      return AppCard(
        color: AppColors.backgroundSecondary,
        showShadow: false,
        child: Row(
          children: [
            const Icon(Icons.event_rounded, color: AppColors.primaryTeal),
            const SizedBox(width: 10),
            Expanded(
              child: Text('${DateFormatter.formatTime(at)} · ${DateFormatter.formatWithWeekday(at)}',
                  style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
            const PillBadge(label: 'Lịch cố định'),
          ],
        ),
      );
    }
    final byDay = <DateTime, List<DateTime>>{};
    for (final t in s.sessions) {
      byDay.putIfAbsent(DateTime(t.year, t.month, t.day), () => []).add(t);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final entry in byDay.entries) ...[
          Text(DateFormatter.formatWithWeekday(entry.key),
              style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final t in entry.value)
                ChoiceChip(
                  label: Text(DateFormatter.formatTime(t)),
                  selected: state.session == t,
                  onSelected: (_) => context.read<BookingFormCubit>().selectSession(t),
                ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}
