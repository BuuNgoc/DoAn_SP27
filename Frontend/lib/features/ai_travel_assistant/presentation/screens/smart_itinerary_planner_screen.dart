import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/view_status.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_feedback.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/pill_badge.dart';
import '../../../../shared/widgets/topographic_scaffold.dart';
import '../../../reviews_social_sharing/presentation/widgets/social_share_sheet.dart';
import '../../domain/entities/ai_entities.dart';
import '../bloc/ai_cubits.dart';

/// [FE-05 & RAG] Form chọn thời gian rảnh, ngân sách, phương tiện, sở thích →
/// AI sinh lịch trình tham quan theo dòng thời gian.
class SmartItineraryPlannerScreen extends StatelessWidget {
  const SmartItineraryPlannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ItineraryCubit>(),
      child: BlocConsumer<ItineraryCubit, ItineraryState>(
        listener: (context, state) {
          if (state.status.isFailure) {
            showAppSnackBar(context, state.errorMessage ?? 'Không tạo được lịch trình.', type: SnackType.error);
          }
        },
        builder: (context, state) {
          final showResult = state.status.isSuccess && state.itinerary != null;
          return TopographicScaffold(
            seed: 5,
            appBar: CustomAppBar(
              title: showResult ? 'Lịch trình của bạn' : 'Lịch trình thông minh',
              subtitle: showResult ? 'Được tạo bởi SmartTravel AI' : 'RAG · cá nhân hóa theo sở thích',
              actions: [
                if (showResult)
                  CircleIconButton(
                    icon: Icons.ios_share_rounded,
                    tooltip: 'Chia sẻ lịch trình',
                    onPressed: () => SocialShareSheet.show(
                      context,
                      title: state.itinerary!.title,
                      message: _shareText(state.itinerary!),
                    ),
                  ),
              ],
            ),
            body: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              child: showResult
                  ? _ItineraryTimeline(key: const ValueKey('result'), itinerary: state.itinerary!)
                  : _PlannerForm(
                      key: const ValueKey('form'),
                      initial: state.request,
                      loading: state.status.isLoading,
                    ),
            ),
          );
        },
      ),
    );
  }

  static String _shareText(GeneratedItinerary it) {
    final b = StringBuffer('🗺️ ${it.title}\n');
    for (final s in it.stops) {
      b.writeln('${s.time} – ${s.title}');
    }
    b.write('\nTạo bởi ứng dụng SmartTravel – Ngũ Hành Sơn #SmartTravel');
    return b.toString();
  }
}

class _PlannerForm extends StatefulWidget {
  const _PlannerForm({super.key, this.initial, required this.loading});

  final ItineraryRequest? initial;
  final bool loading;

  @override
  State<_PlannerForm> createState() => _PlannerFormState();
}

class _PlannerFormState extends State<_PlannerForm> {
  late double _hours = (widget.initial?.freeHours ?? 4).toDouble();
  late TimeOfDay _start = widget.initial?.startTime ?? const TimeOfDay(hour: 8, minute: 0);
  late TravelBudget _budget = widget.initial?.budget ?? TravelBudget.standard;
  late TravelTransport _transport = widget.initial?.transport ?? TravelTransport.motorbike;
  late final Set<String> _interests = {...?widget.initial?.interests};
  late int _group = widget.initial?.groupSize ?? 2;
  late final _note = TextEditingController(text: widget.initial?.note ?? '');

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  void _submit() {
    if (_interests.isEmpty) {
      showAppSnackBar(context, 'Vui lòng chọn ít nhất một sở thích.', type: SnackType.warning);
      return;
    }
    context.read<ItineraryCubit>().generate(ItineraryRequest(
          freeHours: _hours.round(),
          startTime: _start,
          budget: _budget,
          transport: _transport,
          interests: _interests,
          groupSize: _group,
          note: _note.text.trim(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        _Section(
          icon: Icons.schedule_rounded,
          title: 'Thời gian rảnh',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('${_hours.round()} giờ',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.primaryTeal)),
                  const Spacer(),
                  ActionChip(
                    avatar: const Icon(Icons.wb_sunny_outlined, size: 18),
                    label: Text('Bắt đầu ${_start.format(context)}'),
                    onPressed: () async {
                      final t = await showTimePicker(context: context, initialTime: _start);
                      if (t != null) setState(() => _start = t);
                    },
                  ),
                ],
              ),
              Slider(
                value: _hours,
                min: 2,
                max: 12,
                divisions: 10,
                label: '${_hours.round()} giờ',
                onChanged: (v) => setState(() => _hours = v),
              ),
            ],
          ),
        ),
        _Section(
          icon: Icons.account_balance_wallet_rounded,
          title: 'Ngân sách',
          child: Column(
            children: [
              for (final b in TravelBudget.values)
                ListTile(
                  onTap: () => setState(() => _budget = b),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  leading: Icon(
                    _budget == b ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                    color: _budget == b ? AppColors.primaryTeal : AppColors.textMuted,
                  ),
                  title: Text(b.label, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(b.range),
                ),
            ],
          ),
        ),
        _Section(
          icon: Icons.commute_rounded,
          title: 'Phương tiện',
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final t in TravelTransport.values)
                ChoiceChip(
                  avatar: Icon(t.icon, size: 18),
                  label: Text(t.label),
                  selected: _transport == t,
                  onSelected: (_) => setState(() => _transport = t),
                ),
            ],
          ),
        ),
        _Section(
          icon: Icons.favorite_rounded,
          title: 'Sở thích',
          trailing: Text('${_interests.length} đã chọn', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final i in kTravelInterests)
                FilterChip(
                  label: Text(i),
                  selected: _interests.contains(i),
                  onSelected: (on) => setState(() => on ? _interests.add(i) : _interests.remove(i)),
                ),
            ],
          ),
        ),
        _Section(
          icon: Icons.groups_rounded,
          title: 'Số người',
          child: Row(
            children: [
              IconButton.filledTonal(
                onPressed: _group > 1 ? () => setState(() => _group--) : null,
                icon: const Icon(Icons.remove_rounded),
              ),
              SizedBox(
                width: 56,
                child: Text('$_group', textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              ),
              IconButton.filledTonal(
                onPressed: _group < 20 ? () => setState(() => _group++) : null,
                icon: const Icon(Icons.add_rounded),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text('Chi phí ước tính sẽ nhân theo số người.',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
              ),
            ],
          ),
        ),
        TextField(
          controller: _note,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'Ghi chú thêm (không bắt buộc)',
            hintText: 'Ví dụ: đi cùng trẻ nhỏ, muốn tránh leo nhiều bậc thang...',
            prefixIcon: Icon(Icons.edit_note_rounded),
          ),
        ),
        const SizedBox(height: 20),
        CustomButton(
          label: widget.loading ? 'AI đang lên lịch trình...' : 'Tạo lịch trình với AI',
          icon: Icons.auto_awesome_rounded,
          gold: true,
          isLoading: widget.loading,
          onPressed: _submit,
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.icon, required this.title, required this.child, this.trailing});

  final IconData icon;
  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primaryTeal, size: 20),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15.5)),
              const Spacer(),
              ?trailing,
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _ItineraryTimeline extends StatelessWidget {
  const _ItineraryTimeline({super.key, required this.itinerary});

  final GeneratedItinerary itinerary;

  @override
  Widget build(BuildContext context) {
    final it = itinerary;
    final hours = it.totalMinutes ~/ 60;
    final mins = it.totalMinutes % 60;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        AppCard(
          gradient: AppColors.primaryGradient,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(it.title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text(it.summary, style: TextStyle(color: Colors.white.withValues(alpha: 0.9), height: 1.45)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  PillBadge(
                    label: '${it.stops.length} điểm dừng',
                    icon: Icons.place_rounded,
                    color: Colors.white,
                    background: Colors.white.withValues(alpha: 0.18),
                  ),
                  PillBadge(
                    label: mins == 0 ? '$hours giờ' : '$hours giờ $mins phút',
                    icon: Icons.timelapse_rounded,
                    color: Colors.white,
                    background: Colors.white.withValues(alpha: 0.18),
                  ),
                  PillBadge(
                    label: '≈ ${CurrencyFormatter.vnd(it.totalCost)}',
                    icon: Icons.payments_rounded,
                    color: Colors.white,
                    background: Colors.white.withValues(alpha: 0.18),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        for (var i = 0; i < it.stops.length; i++)
          _TimelineTile(stop: it.stops[i], isFirst: i == 0, isLast: i == it.stops.length - 1),
        const SizedBox(height: 12),
        AppCard(
          color: AppColors.backgroundSecondary,
          showShadow: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Lưu ý hữu ích', style: TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              for (final t in it.tips)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_circle_rounded, size: 16, color: AppColors.success),
                      const SizedBox(width: 8),
                      Expanded(child: Text(t, style: const TextStyle(color: AppColors.textSecondary, height: 1.4))),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ExpansionTile(
          tilePadding: EdgeInsets.zero,
          leading: const Icon(Icons.menu_book_rounded, color: AppColors.accentSoftGold),
          title: const Text('Nguồn tri thức RAG đã tham khảo', style: TextStyle(fontWeight: FontWeight.w700)),
          children: [
            for (final s in it.sources)
              ListTile(
                dense: true,
                leading: const Icon(Icons.source_outlined, size: 18),
                title: Text(s),
              ),
          ],
        ),
        const Text(
          'Lịch trình do AI đề xuất chỉ mang tính tham khảo; thời gian và chi phí có thể thay đổi thực tế.',
          style: TextStyle(color: AppColors.textMuted, fontSize: 12),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                onPressed: () => context.read<ItineraryCubit>().edit(),
                icon: const Icon(Icons.tune_rounded),
                label: const Text('Chỉnh sửa'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                onPressed: () => context.push(RouteNames.aiChat),
                icon: const Icon(Icons.forum_rounded),
                label: const Text('Hỏi thêm AI'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TimelineTile extends StatelessWidget {
  const _TimelineTile({required this.stop, required this.isFirst, required this.isLast});

  final ItineraryStop stop;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 54,
            child: Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Text(stop.time,
                  style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primaryTeal, fontSize: 15)),
            ),
          ),
          SizedBox(
            width: 30,
            child: Column(
              children: [
                Container(width: 2, height: 14, color: isFirst ? Colors.transparent : AppColors.cardBorder),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Icon(stop.kind.icon, color: Colors.white, size: 14),
                ),
                Expanded(child: Container(width: 2, color: isLast ? Colors.transparent : AppColors.cardBorder)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: AppCard(
                padding: const EdgeInsets.all(14),
                onTap: stop.destinationId == null
                    ? null
                    : () => context.push(RouteNames.destinationDetail(stop.destinationId!)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (stop.travelNote != null) ...[
                      Row(
                        children: [
                          const Icon(Icons.directions_rounded, size: 14, color: AppColors.textMuted),
                          const SizedBox(width: 4),
                          Text(stop.travelNote!, style: const TextStyle(color: AppColors.textMuted, fontSize: 11.5)),
                        ],
                      ),
                      const SizedBox(height: 6),
                    ],
                    Text(stop.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                    const SizedBox(height: 4),
                    Text(stop.description,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.45)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        PillBadge(label: '${stop.durationMinutes} phút', icon: Icons.timer_outlined),
                        const SizedBox(width: 6),
                        PillBadge(
                          label: stop.estimatedCost == 0 ? 'Miễn phí' : CurrencyFormatter.vnd(stop.estimatedCost),
                          icon: Icons.payments_outlined,
                          color: AppColors.accentSoftGold,
                        ),
                        if (stop.destinationId != null) ...[
                          const Spacer(),
                          const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
