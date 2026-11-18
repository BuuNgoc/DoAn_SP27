import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/utils/view_status.dart';
import '../../../../shared/widgets/cover_image.dart';
import '../../../../shared/widgets/floating_ai_chat_button.dart';
import '../../../../shared/widgets/state_views.dart';
import '../../domain/entities/destination.dart';
import '../bloc/destination_cubits.dart';

/// [Ảnh Mẫu 4: Pixel-Perfect] Danh sách điểm đến phong cách Shangri-La Circle Luxury.
/// 1. Top Bar:
///    - Nút Back <
///    - Tiêu đề "Ngũ Hành Sơn", phụ đề ngày tham quan "13 Th12 - 14 Th12"
///    - Pill đơn vị tiền tệ "VND" kèm biểu tượng thẻ tag bên phải
/// 2. Segmented Tabs:
///    - Tab "List" (icon danh sách) kèm vạch gạch chân vàng kim Soft Gold (#B69A67 / #D4AF37)
///    - Tab "Map" (icon bản đồ) - bấm chuyển nhanh sang Bản đồ tương tác
/// 3. Thẻ điểm đến toàn màn hình (Luxury Hero Cards):
///    - Ảnh tràn viền chất lượng cao
///    - Góc trên trái: Logo ấn ngọc SmartTravel hoàng gia màu trắng
///    - Góc trên phải: Pill vàng kim chứa giá "Từ 40.000 VNĐ / vé" hoặc "Miễn phí" / Pill xám "Sold Out"
///    - Đáy ảnh: Tiêu đề in đậm màu trắng + Biểu tượng ghim vị trí và địa chỉ chi tiết
/// 4. Nút nổi "Trợ lý AI" (Shangri-La Chat) ở góc dưới trái
class DestinationListScreen extends StatelessWidget {
  const DestinationListScreen({
    super.key,
    this.initialCategory,
    this.autofocusSearch = false,
  });

  final DestinationCategory? initialCategory;
  final bool autofocusSearch;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<DestinationListCubit>()..load(category: initialCategory),
      child: const _DestinationListPixelPerfectView(),
    );
  }
}

class _DestinationListPixelPerfectView extends StatefulWidget {
  const _DestinationListPixelPerfectView();

  @override
  State<_DestinationListPixelPerfectView> createState() => _DestinationListPixelPerfectViewState();
}

class _DestinationListPixelPerfectViewState extends State<_DestinationListPixelPerfectView> {
  int _selectedViewTab = 0; // 0: List, 1: Map
  String _selectedCurrency = 'VND';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                // ── 1. Top Bar (Back, Title + Dates, Currency Tag Pill) ──
                _buildTopBar(context),

                // ── 2. Segmented Tabs (List vs Map) ─────────────────────
                _buildSegmentedTabs(context),

                const Divider(height: 1, color: Color(0xFFEBE7DD)),

                // ── 3. Destination Cards List ───────────────────────────
                Expanded(
                  child: BlocBuilder<DestinationListCubit, DestinationListState>(
                    builder: (context, state) {
                      if (state.status.isLoading) {
                        return const Center(
                          child: LoadingState(message: 'Đang tải danh sách điểm đến...'),
                        );
                      }

                      if (state.status.isFailure) {
                        return Center(
                          child: ErrorState(
                            message: state.errorMessage ?? 'Không thể tải danh sách',
                            onRetry: () => context.read<DestinationListCubit>().load(),
                          ),
                        );
                      }

                      if (state.items.isEmpty) {
                        return const Center(
                          child: EmptyState(
                            title: 'Chưa có điểm đến',
                            subtitle: 'Không tìm thấy danh thắng nào phù hợp.',
                          ),
                        );
                      }

                      return RefreshIndicator(
                        color: AppColors.primary,
                        onRefresh: () => context.read<DestinationListCubit>().load(),
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                          itemCount: state.items.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final destination = state.items[index];
                            final isSoldOut = index == state.items.length - 1 && state.items.length > 3;

                            return _ShangriLaLuxuryCard(
                              destination: destination,
                              isSoldOut: isSoldOut,
                              currency: _selectedCurrency,
                              onTap: () => context.push(RouteNames.destinationDetail(destination.id)),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            // ── 4. Floating AI Assistant Chat Button (Bottom Left) ─────────
            Positioned(
              left: 20,
              bottom: 24,
              child: FloatingAiChatButton(
                label: 'Trợ lý AI',
                onTap: () => context.push(RouteNames.aiChat),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Top Bar ────────────────────────────────────────────────────────────────
  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Color(0xFF242824)),
            onPressed: () => Navigator.of(context).maybePop(),
          ),

          // Center Title & Dates
          const Column(
            children: [
              Text(
                'Ngũ Hành Sơn',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF242824),
                  letterSpacing: -0.2,
                ),
              ),
              SizedBox(height: 2),
              Text(
                '13 Th12 - 14 Th12',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF70736C),
                ),
              ),
            ],
          ),

          // Currency Tag Pill
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedCurrency = _selectedCurrency == 'VND' ? 'USD' : 'VND';
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFDBD6CA), width: 1.0),
              ),
              child: Row(
                children: [
                  const Icon(Icons.sell_outlined, size: 13, color: Color(0xFF5A5D55)),
                  const SizedBox(width: 4),
                  Text(
                    _selectedCurrency,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF242824),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Segmented Tabs (List vs Map) ───────────────────────────────────────────
  Widget _buildSegmentedTabs(BuildContext context) {
    return Row(
      children: [
        // Tab 1: List
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedViewTab = 0),
            child: Container(
              color: Colors.transparent,
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.format_list_bulleted_rounded, size: 18, color: Color(0xFF242824)),
                      SizedBox(width: 6),
                      Text(
                        'Danh sách (List)',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF242824),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Golden Underline Indicator
                  Container(
                    height: 2.5,
                    width: double.infinity,
                    color: _selectedViewTab == 0 ? const Color(0xFFB69A67) : Colors.transparent, // Soft Gold
                  ),
                ],
              ),
            ),
          ),
        ),

        // Tab 2: Map
        Expanded(
          child: GestureDetector(
            onTap: () {
              // Bấm chuyển sang Bản đồ tương tác
              context.push(RouteNames.map);
            },
            child: Container(
              color: Colors.transparent,
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.map_outlined, size: 18, color: Color(0xFF70736C)),
                      SizedBox(width: 6),
                      Text(
                        'Bản đồ (Map)',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF70736C),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 2.5,
                    width: double.infinity,
                    color: Colors.transparent,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// THẺ ĐIỂM ĐẾN PHONG CÁCH SHANGRI-LA (PIXEL-PERFECT CARD WITH GOLD PRICE PILL)
// ─────────────────────────────────────────────────────────────────────────────

class _ShangriLaLuxuryCard extends StatelessWidget {
  const _ShangriLaLuxuryCard({
    required this.destination,
    required this.isSoldOut,
    required this.currency,
    required this.onTap,
  });

  final Destination destination;
  final bool isSoldOut;
  final String currency;
  final VoidCallback onTap;

  String _formatPrice() {
    if (destination.ticketInfo.contains('Miễn phí')) {
      return 'Miễn phí';
    }
    if (currency == 'USD') {
      return 'From USD 2 / vé';
    }
    return 'Từ 40.000 VNĐ / vé';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 210,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Hero Image
              CoverImage(
                source: destination.coverImage,
                fit: BoxFit.cover,
              ),

              // Gradient Overlay (top shadow for logo/pill + dark bottom for title/address)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.35),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.82),
                    ],
                    stops: const [0.0, 0.4, 1.0],
                  ),
                ),
              ),

              // Top-Left Brand Logo Emblem
              Positioned(
                top: 14,
                left: 14,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.85),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.temple_buddhist_rounded, size: 18, color: Color(0xFF173F35)),
                  ),
                ),
              ),

              // Top-Right Gold Price Pill or Grey Sold Out Pill
              Positioned(
                top: 14,
                right: 14,
                child: isSoldOut
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF5A5D55).withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          'Đã hết vé hôm nay',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                    : Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE4B85E), // Soft Gold
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          _formatPrice(),
                          style: const TextStyle(
                            color: Color(0xFF242824),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
              ),

              // Bottom Title & Address Overlay
              Positioned(
                left: 14,
                right: 14,
                bottom: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      destination.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                        shadows: [
                          Shadow(color: Colors.black54, blurRadius: 8, offset: Offset(0, 2)),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded, size: 14, color: Colors.white70),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            destination.address,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
