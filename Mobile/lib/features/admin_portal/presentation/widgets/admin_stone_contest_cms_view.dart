import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/tourism_components.dart';

class ContestEntryItem {
  ContestEntryItem({
    required this.id,
    required this.title,
    required this.artisanName,
    required this.workshopName,
    required this.stoneType,
    required this.carvingTechnique,
    required this.photoUrl,
    required this.story,
    required this.votes,
    required this.shares,
    required this.status, // 'PENDING', 'APPROVED', 'AWARDED'
  });

  final String id;
  final String title;
  final String artisanName;
  final String workshopName;
  final String stoneType;
  final String carvingTechnique;
  final String photoUrl;
  final String story;
  int votes;
  int shares;
  String status;
}

/// [FE-16 / Epic 6] Quản Lý Cuộc Thi Điêu Khắc Đá Non Nước & Duyệt Tác Phẩm Nghệ Nhân
class AdminStoneContestCmsView extends StatefulWidget {
  const AdminStoneContestCmsView({super.key});

  @override
  State<AdminStoneContestCmsView> createState() => _AdminStoneContestCmsViewState();
}

class _AdminStoneContestCmsViewState extends State<AdminStoneContestCmsView> {
  String _activeView = 'LEADERBOARD'; // 'LEADERBOARD' or 'APPROVAL' or 'CONFIG'

  late final List<ContestEntryItem> _entries = [
    ContestEntryItem(
      id: 'entry_1',
      title: 'Vũ Điệu Apsara Bằng Cẩm Thạch Trắng',
      artisanName: 'Nghệ Nhân Ưu Tú Lê Triều',
      workshopName: 'Xưởng Điêu Khắc Đá Triều Phát',
      stoneType: 'Đá Cẩm Thạch Trắng Non Nước',
      carvingTechnique: 'Chạm nổi 3D kết hợp lộng đá tinh xảo',
      photoUrl: 'https://images.unsplash.com/photo-1579783900882-c0d3dad7b119?auto=format&fit=crop&w=600&q=80',
      story: 'Tác phẩm khắc họa vẻ đẹp uyển chuyển của nàng tiên Apsara trong văn hóa Chăm Pa gắn liền với di tích tháp cổ.',
      votes: 3420,
      shares: 1250,
      status: 'APPROVED',
    ),
    ContestEntryItem(
      id: 'entry_2',
      title: 'Long Quy Thủy Mộc Vượt Sóng',
      artisanName: 'Nghệ Nhân Huỳnh Bá Cảnh',
      workshopName: 'Cơ Sở Đá Mỹ Nghệ Bá Cảnh',
      stoneType: 'Đá Sa Thạch Tự Nhiên',
      carvingTechnique: 'Đục đẽo nguyên khối cổ truyền',
      photoUrl: 'https://images.unsplash.com/photo-1544717305-2782549b5136?auto=format&fit=crop&w=600&q=80',
      story: 'Hình tượng Long Quy vững chãi chở che cho ngư dân vùng biển Ngũ Hành Sơn vượt qua ngàn cơn sóng dữ.',
      votes: 2890,
      shares: 940,
      status: 'APPROVED',
    ),
    ContestEntryItem(
      id: 'entry_3',
      title: 'Quán Thế Âm Bồ Tát Ngự Tòa Sen Thủy Sơn',
      artisanName: 'Nghệ Nhân Trẻ Nguyễn Tấn Thành',
      workshopName: 'Xưởng Đá Mỹ Nghệ Tấn Thành',
      stoneType: 'Đá Cẩm Thạch Xanh Vân Mây',
      carvingTechnique: 'Điêu khắc tượng truyền thần',
      photoUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?auto=format&fit=crop&w=600&q=80',
      story: 'Tái hiện hình tượng Đức Bồ Tát Quán Thế Âm trong ngày lễ hội 19/2 Âm lịch linh thiêng tại Ngũ Hành Sơn.',
      votes: 2150,
      shares: 820,
      status: 'APPROVED',
    ),
    ContestEntryItem(
      id: 'entry_4',
      title: 'Tượng Kỳ Lân Trấn Cổng Cổ Tự',
      artisanName: 'Nghệ Nhân Đỗ Hữu Phước',
      workshopName: 'Cơ Sở Điêu Khắc Phước Đá',
      stoneType: 'Đá Hoa Cương Vân Đen',
      carvingTechnique: 'Tạc hình khối uy lực',
      photoUrl: 'https://images.unsplash.com/photo-1579783900882-c0d3dad7b119?auto=format&fit=crop&w=600&q=80',
      story: 'Linh vật bảo hộ cổng Tam quan chùa cổ Tam Thai với đôi mắt sắc sảo canh giữ sự bình an.',
      votes: 0,
      shares: 0,
      status: 'PENDING',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final pendingCount = _entries.where((e) => e.status == 'PENDING').length;
    final totalVotes = _entries.fold<int>(0, (sum, e) => sum + e.votes);
    final totalShares = _entries.fold<int>(0, (sum, e) => sum + e.shares);

    return TourismCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header & Stats ──────────────────────────────────────────────────
          Row(
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cuộc Thi Điêu Khắc Đá Mỹ Nghệ Non Nước 2026 (FE-16, Epic 6)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Chủ đề: "400 Năm Tinh Hoa Bàn Tay Vàng Làng Đá" • Leaderboard bình chọn du khách & kiểm duyệt tác phẩm',
                    style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                  ),
                ],
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _openCreateContestDialog(context),
                icon: const Icon(Icons.emoji_events_rounded, size: 18),
                label: const Text('+ Thiết Lập Cuộc Thi Mới'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Stat Badges ─────────────────────────────────────────────────────
          Row(
            children: [
              _buildMetricBadge('Tổng Tác Phẩm', '${_entries.length} bài thi', Icons.palette_rounded, AppColors.primary),
              const SizedBox(width: 14),
              _buildMetricBadge('Tổng Lượt Bình Chọn', '$totalVotes lượt vote', Icons.how_to_vote_rounded, const Color(0xFFD97706)),
              const SizedBox(width: 14),
              _buildMetricBadge('Lượt Share Mạng Xã Hội', '$totalShares lượt share', Icons.share_rounded, const Color(0xFF2563EB)),
              const SizedBox(width: 14),
              _buildMetricBadge('Chờ Kiểm Duyệt', '$pendingCount tác phẩm', Icons.pending_rounded, pendingCount > 0 ? const Color(0xFFDC2626) : const Color(0xFF16A34A)),
            ],
          ),
          const SizedBox(height: 20),

          // ── Navigation Tabs ─────────────────────────────────────────────────
          Row(
            children: [
              ChoiceChip(
                label: const Text('Bảng Xếp Hạng Bình Chọn (Leaderboard)'),
                selected: _activeView == 'LEADERBOARD',
                selectedColor: AppColors.primarySurface,
                labelStyle: TextStyle(fontWeight: _activeView == 'LEADERBOARD' ? FontWeight.w800 : FontWeight.w600, color: _activeView == 'LEADERBOARD' ? AppColors.primary : AppColors.textPrimary),
                onSelected: (s) => setState(() => _activeView = 'LEADERBOARD'),
              ),
              const SizedBox(width: 10),
              ChoiceChip(
                label: Text('Duyệt Tác Phẩm Nghệ Nhân Gửi Lên ($pendingCount)'),
                selected: _activeView == 'APPROVAL',
                selectedColor: AppColors.primarySurface,
                labelStyle: TextStyle(fontWeight: _activeView == 'APPROVAL' ? FontWeight.w800 : FontWeight.w600, color: _activeView == 'APPROVAL' ? AppColors.primary : AppColors.textPrimary),
                onSelected: (s) => setState(() => _activeView = 'APPROVAL'),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // ── View Content ────────────────────────────────────────────────────
          if (_activeView == 'LEADERBOARD')
            _buildLeaderboardTable()
          else
            _buildApprovalView(),
        ],
      ),
    );
  }

  Widget _buildMetricBadge(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: color)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardTable() {
    final sorted = List<ContestEntryItem>.from(_entries.where((e) => e.status == 'APPROVED'))
      ..sort((a, b) => b.votes.compareTo(a.votes));

    return Table(
      border: TableBorder.all(color: AppColors.border, width: 1),
      columnWidths: const {
        0: FlexColumnWidth(1.2),
        1: FlexColumnWidth(3.5),
        2: FlexColumnWidth(2.5),
        3: FlexColumnWidth(1.8),
        4: FlexColumnWidth(1.8),
        5: FlexColumnWidth(1.6),
      },
      children: [
        TableRow(
          decoration: const BoxDecoration(color: Color(0xFFF8FAFC)),
          children: [
            for (final h in ['Hạng', 'Tác Phẩm & Chất Liệu', 'Nghệ Nhân / Xưởng Đá', 'Lượt Vote', 'Lượt Share', 'Trạng Thái'])
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(h, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5)),
              ),
          ],
        ),
        for (int i = 0; i < sorted.length; i++)
          TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Center(
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: i == 0 ? const Color(0xFFF59E0B) : (i == 1 ? const Color(0xFF94A3B8) : (i == 2 ? const Color(0xFFB45309) : Colors.transparent)),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '#${i + 1}',
                        style: TextStyle(fontWeight: FontWeight.w900, color: i < 3 ? Colors.white : AppColors.textPrimary, fontSize: 12),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(sorted[i].title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)),
                    Text('${sorted[i].stoneType} • ${sorted[i].carvingTechnique}', style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(sorted[i].artisanName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    Text(sorted[i].workshopName, style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text('★ ${sorted[i].votes} votes', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFFD97706))),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text('↗ ${sorted[i].shares} shares', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5, color: Color(0xFF2563EB))),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(4)),
                  child: const Text('Đang bình chọn', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF15803D))),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildApprovalView() {
    final pending = _entries.where((e) => e.status == 'PENDING').toList();
    if (pending.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: Text('Không có tác phẩm nào đang chờ duyệt.')),
      );
    }

    return Column(
      children: [
        for (final item in pending)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                const Icon(Icons.handyman_rounded, size: 36, color: AppColors.primary),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5)),
                      Text('Nghệ nhân: ${item.artisanName} | Xưởng: ${item.workshopName}', style: const TextStyle(fontSize: 12.5, color: AppColors.textPrimary)),
                      const SizedBox(height: 2),
                      Text('Chất liệu: ${item.stoneType} • Kỹ thuật: ${item.carvingTechnique}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      const SizedBox(height: 4),
                      Text('Ý nghĩa: "${item.story}"', style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.textMuted)),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() => item.status = 'APPROVED');
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã duyệt tác phẩm "${item.title}" lên bảng bình chọn!')));
                  },
                  icon: const Icon(Icons.check_rounded, size: 16),
                  label: const Text('Phê Duyệt Tham Gia'),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A34A), foregroundColor: Colors.white),
                ),
              ],
            ),
          ),
      ],
    );
  }

  void _openCreateContestDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Thiết Lập Cuộc Thi Điêu Khắc Đá Mới (FE-16)'),
        content: const SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(decoration: InputDecoration(labelText: 'Tên Cuộc Thi*', border: OutlineInputBorder())),
              SizedBox(height: 12),
              TextField(decoration: InputDecoration(labelText: 'Chủ Đề Điêu Khắc*', border: OutlineInputBorder())),
              SizedBox(height: 12),
              TextField(decoration: InputDecoration(labelText: 'Thời Gian Bình Chọn (Từ ngày - Đến ngày)*', border: OutlineInputBorder())),
              SizedBox(height: 12),
              TextField(decoration: InputDecoration(labelText: 'Cơ Cấu Giải Thưởng (Giải Nhất, Nhì, Yêu Thích)', border: OutlineInputBorder())),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            child: const Text('Tạo Cuộc Thi'),
          ),
        ],
      ),
    );
  }
}
