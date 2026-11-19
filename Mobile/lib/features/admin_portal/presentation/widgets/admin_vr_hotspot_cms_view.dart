import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/tourism_components.dart';

/// Mô hình Hotspot tương tác trên ảnh VR360 (Epic 4).
class VrHotspotItem {
  VrHotspotItem({
    required this.id,
    required this.title,
    required this.yaw,
    required this.pitch,
    required this.description,
    required this.type, // 'INFO', 'AUDIO', 'VIDEO', 'SCENE_TRANSITION'
    required this.audioUrl,
    required this.videoUrl,
    required this.nextSceneTitle,
  });

  final String id;
  String title;
  double yaw; // -180.0 to 180.0
  double pitch; // -90.0 to 90.0
  String description;
  String type;
  String audioUrl;
  String videoUrl;
  String nextSceneTitle;
}

/// Mô hình cảnh VR360 Panorama.
class VrSceneItem {
  VrSceneItem({
    required this.id,
    required this.title,
    required this.zone,
    required this.imageUrl,
    required this.resolution,
    required this.fileSize,
    required this.hotspots,
  });

  final String id;
  final String title;
  final String zone;
  final String imageUrl;
  final String resolution;
  final String fileSize;
  final List<VrHotspotItem> hotspots;
}

/// [FE-18 / Epic 4] Quản trị Kho VR360 & Cấu Hình Hotspot Tương Tác
class AdminVrHotspotCmsView extends StatefulWidget {
  const AdminVrHotspotCmsView({super.key});

  @override
  State<AdminVrHotspotCmsView> createState() => _AdminVrHotspotCmsViewState();
}

class _AdminVrHotspotCmsViewState extends State<AdminVrHotspotCmsView> {
  int _selectedSceneIndex = 0;

  late final List<VrSceneItem> _scenes = [
    VrSceneItem(
      id: 'vr_huyen_khong',
      title: 'Động Huyền Không (Vòm Trời Linh Thiêng)',
      zone: 'Thủy Sơn',
      imageUrl: 'https://storage.googleapis.com/smarttravel-vr/huyen_khong_8k.jpg',
      resolution: '8192 x 4096 (8K Equirectangular)',
      fileSize: '5.4 MB',
      hotspots: [
        VrHotspotItem(
          id: 'hs_1',
          title: 'Tượng Phật Thích Ca Mâu Ni',
          yaw: 15.0,
          pitch: 12.5,
          description: 'Pho tượng Phật ngự trên vách đá cao, được chạm khắc tinh xảo đón luồng ánh sáng mặt trời rọi thẳng từ vòm trời.',
          type: 'INFO',
          audioUrl: 'https://storage.googleapis.com/smarttravel-audio/tuong_phat_vi.mp3',
          videoUrl: '',
          nextSceneTitle: '',
        ),
        VrHotspotItem(
          id: 'hs_2',
          title: 'Văn Bia Ma Nhai Cổ (UNESCO)',
          yaw: -45.0,
          pitch: -5.0,
          description: 'Hệ thống Ma Nhai gồm các bài thơ ngự chế của vua Minh Mạng và các danh sĩ thời Nguyễn khắc trực tiếp vào vách đá cẩm thạch.',
          type: 'AUDIO',
          audioUrl: 'https://storage.googleapis.com/smarttravel-audio/ma_nhai_huyen_khong.mp3',
          videoUrl: '',
          nextSceneTitle: '',
        ),
        VrHotspotItem(
          id: 'hs_3',
          title: 'Chuyển Sang: Cổng Động Tàng Chơn',
          yaw: 110.0,
          pitch: 2.0,
          description: 'Lối đi thông sang Động Tàng Chơn và Chùa Linh Ứng.',
          type: 'SCENE_TRANSITION',
          audioUrl: '',
          videoUrl: '',
          nextSceneTitle: 'Động Tàng Chơn',
        ),
      ],
    ),
    VrSceneItem(
      id: 'vr_linh_ung',
      title: 'Chùa Linh Ứng Non Nước (Sân Chính & Tháp Xá Lợi)',
      zone: 'Thủy Sơn',
      imageUrl: 'https://storage.googleapis.com/smarttravel-vr/linh_ung_main_vr.jpg',
      resolution: '8192 x 4096 (8K Equirectangular)',
      fileSize: '6.1 MB',
      hotspots: [
        VrHotspotItem(
          id: 'hs_4',
          title: 'Bảo Tháp Xá Lợi 7 Tầng',
          yaw: 28.0,
          pitch: 22.0,
          description: 'Ngọn tháp cao 28 mét với 7 tầng thờ phụng gần 200 vị Phật và Bồ Tát linh thiêng.',
          type: 'INFO',
          audioUrl: 'https://storage.googleapis.com/smarttravel-audio/thap_xa_loi.mp3',
          videoUrl: 'https://storage.googleapis.com/smarttravel-video/thap_xa_loi.mp4',
          nextSceneTitle: '',
        ),
        VrHotspotItem(
          id: 'hs_5',
          title: 'Chuông Đồng Cổ Thời Nguyễn',
          yaw: -70.0,
          pitch: 8.0,
          description: 'Đại hồng chung đúc bằng đồng nguyên chất phát ra âm thanh vang vọng khắp vùng Non Nước.',
          type: 'AUDIO',
          audioUrl: 'https://storage.googleapis.com/smarttravel-audio/chuong_dong_linh_ung.mp3',
          videoUrl: '',
          nextSceneTitle: '',
        ),
      ],
    ),
    VrSceneItem(
      id: 'vr_vong_hai_dai',
      title: 'Vọng Hải Đài (Toàn Cảnh Biển Non Nước)',
      zone: 'Thủy Sơn',
      imageUrl: 'https://storage.googleapis.com/smarttravel-vr/vong_hai_dai_vr.jpg',
      resolution: '8192 x 4096 (8K Equirectangular)',
      fileSize: '4.9 MB',
      hotspots: [
        VrHotspotItem(
          id: 'hs_6',
          title: 'Hướng Nhìn Quần Đảo Cù Lao Chàm',
          yaw: 85.0,
          pitch: 5.0,
          description: 'Điểm nhìn xa nhất về phía đông, nơi có thể quan sát quần đảo Cù Lao Chàm vào những ngày trời trong xanh.',
          type: 'INFO',
          audioUrl: '',
          videoUrl: '',
          nextSceneTitle: '',
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final activeScene = _scenes[_selectedSceneIndex];

    return TourismCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ─────────────────────────────────────────────────────────
          Row(
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quản Trị VR360 & Trình Biên Tập Hotspot Tương Tác (FE-18, Epic 4)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Cấu hình tọa độ Hotspot (Yaw/Pitch), gắn Audio Thuyết Minh đa ngữ, Video clip & Tour theo tuyến',
                    style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                  ),
                ],
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _openAddSceneDialog(context),
                icon: const Icon(Icons.cloud_upload_rounded, size: 18),
                label: const Text('+ Tải Lên Ảnh 360 Mới'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Scene Selector Tabs ─────────────────────────────────────────────
          Row(
            children: [
              for (int i = 0; i < _scenes.length; i++)
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: ChoiceChip(
                    label: Text(_scenes[i].title),
                    selected: i == _selectedSceneIndex,
                    selectedColor: AppColors.primarySurface,
                    labelStyle: TextStyle(
                      fontWeight: i == _selectedSceneIndex ? FontWeight.w800 : FontWeight.w600,
                      color: i == _selectedSceneIndex ? AppColors.primary : AppColors.textPrimary,
                      fontSize: 13,
                    ),
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedSceneIndex = i);
                    },
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),

          // ── Active Scene Preview & Hotspot Editor ───────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Scene Info & Spec
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 190,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            const Icon(Icons.threesixty_rounded, size: 64, color: Colors.white38),
                            Positioned(
                              bottom: 12,
                              left: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.7),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '${activeScene.resolution} • ${activeScene.fileSize}',
                                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 12,
                              right: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF16A34A),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.check_circle_rounded, size: 14, color: Colors.white),
                                    SizedBox(width: 4),
                                    Text('WebXR / Equirectangular Ready', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(activeScene.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                      Text('Khu vực: ${activeScene.zone} • ${activeScene.hotspots.length} điểm tương tác Hotspot đã gắn', style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                const SizedBox(width: 20),

                // Hotspots List & Add Hotspot Button
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('Danh Sách Hotspot Tương Tác (${activeScene.hotspots.length})', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                          const Spacer(),
                          ElevatedButton.icon(
                            onPressed: () => _openAddEditHotspotDialog(context, activeScene, null),
                            icon: const Icon(Icons.add_circle_outline_rounded, size: 16),
                            label: const Text('+ Thêm Hotspot'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (activeScene.hotspots.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(24),
                          child: Center(child: Text('Chưa có Hotspot nào trên ảnh 360 này.')),
                        )
                      else
                        for (final hs in activeScene.hotspots)
                          Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: _hotspotColor(hs.type).withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(_hotspotIcon(hs.type), size: 18, color: _hotspotColor(hs.type)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(hs.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Tọa độ: Yaw ${hs.yaw}°, Pitch ${hs.pitch}° • Loại: ${hs.type}${hs.audioUrl.isNotEmpty ? " • Có Audio" : ""}${hs.nextSceneTitle.isNotEmpty ? " • Chuyển tới: ${hs.nextSceneTitle}" : ""}',
                                        style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                                  onPressed: () => _openAddEditHotspotDialog(context, activeScene, hs),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                                  onPressed: () {
                                    setState(() => activeScene.hotspots.remove(hs));
                                  },
                                ),
                              ],
                            ),
                          ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _hotspotIcon(String type) {
    switch (type) {
      case 'AUDIO':
        return Icons.headphones_rounded;
      case 'VIDEO':
        return Icons.play_circle_fill_rounded;
      case 'SCENE_TRANSITION':
        return Icons.turn_right_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  Color _hotspotColor(String type) {
    switch (type) {
      case 'AUDIO':
        return const Color(0xFF0D9488); // Teal
      case 'VIDEO':
        return const Color(0xFFDC2626); // Red
      case 'SCENE_TRANSITION':
        return const Color(0xFF2563EB); // Blue
      default:
        return AppColors.primary;
    }
  }

  void _openAddSceneDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final zoneCtrl = TextEditingController(text: 'Thủy Sơn');
    final urlCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tải Lên File Ảnh VR360 Panorama Mới (FE-18)'),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Tên Cảnh VR360*', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: zoneCtrl, decoration: const InputDecoration(labelText: 'Phân Vùng / Điểm Đến*', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: urlCtrl, decoration: const InputDecoration(labelText: 'URL Ảnh Equirectangular Panorama (2:1)*', border: OutlineInputBorder())),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              if (titleCtrl.text.isNotEmpty) {
                setState(() {
                  _scenes.add(
                    VrSceneItem(
                      id: 'vr_${DateTime.now().millisecondsSinceEpoch}',
                      title: titleCtrl.text,
                      zone: zoneCtrl.text,
                      imageUrl: urlCtrl.text.isNotEmpty ? urlCtrl.text : 'https://storage.googleapis.com/smarttravel-vr/new_scene.jpg',
                      resolution: '8192 x 4096 (8K Equirectangular)',
                      fileSize: '5.2 MB',
                      hotspots: [],
                    ),
                  );
                  _selectedSceneIndex = _scenes.length - 1;
                });
              }
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            child: const Text('Tải Lên'),
          ),
        ],
      ),
    );
  }

  void _openAddEditHotspotDialog(BuildContext context, VrSceneItem scene, VrHotspotItem? existing) {
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final yawCtrl = TextEditingController(text: existing != null ? existing.yaw.toString() : '0.0');
    final pitchCtrl = TextEditingController(text: existing != null ? existing.pitch.toString() : '0.0');
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    final audioCtrl = TextEditingController(text: existing?.audioUrl ?? '');
    final videoCtrl = TextEditingController(text: existing?.videoUrl ?? '');
    final nextSceneCtrl = TextEditingController(text: existing?.nextSceneTitle ?? '');
    String type = existing?.type ?? 'INFO';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(existing == null ? 'Cấu Hình Hotspot Mới Trên Ảnh 360' : 'Chỉnh Sửa Hotspot: ${existing.title}'),
          content: SizedBox(
            width: 580,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Tiêu Đề Hotspot*', border: OutlineInputBorder())),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: yawCtrl,
                          decoration: const InputDecoration(labelText: 'Góc Ngang Yaw (-180° đến 180°)*', border: OutlineInputBorder()),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: pitchCtrl,
                          decoration: const InputDecoration(labelText: 'Góc Dọc Pitch (-90° đến 90°)*', border: OutlineInputBorder()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: type,
                    decoration: const InputDecoration(labelText: 'Loại Tương Tác Hotspot*', border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: 'INFO', child: Text('Thông Tin Di Sản (Text & Popup)')),
                      DropdownMenuItem(value: 'AUDIO', child: Text('Thuyết Minh Audio Guide')),
                      DropdownMenuItem(value: 'VIDEO', child: Text('Video Clip Ngắn')),
                      DropdownMenuItem(value: 'SCENE_TRANSITION', child: Text('Chuyển Sang Cảnh 360 Kế Tiếp (Tour Tuyến)')),
                    ],
                    onChanged: (v) {
                      if (v != null) setDialogState(() => type = v);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(controller: descCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Mô Tả Chi Tiết', border: OutlineInputBorder())),
                  const SizedBox(height: 12),
                  TextField(controller: audioCtrl, decoration: const InputDecoration(labelText: 'URL File Audio Guide (mp3/aac)', border: OutlineInputBorder())),
                  const SizedBox(height: 12),
                  if (type == 'VIDEO')
                    TextField(controller: videoCtrl, decoration: const InputDecoration(labelText: 'URL Video Ngắn (mp4)', border: OutlineInputBorder())),
                  if (type == 'SCENE_TRANSITION')
                    TextField(controller: nextSceneCtrl, decoration: const InputDecoration(labelText: 'Tên Cảnh VR360 Tiếp Theo', border: OutlineInputBorder())),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
            ElevatedButton(
              onPressed: () {
                final yaw = double.tryParse(yawCtrl.text) ?? 0.0;
                final pitch = double.tryParse(pitchCtrl.text) ?? 0.0;
                if (existing != null) {
                  setState(() {
                    existing.title = titleCtrl.text;
                    existing.yaw = yaw;
                    existing.pitch = pitch;
                    existing.type = type;
                    existing.description = descCtrl.text;
                    existing.audioUrl = audioCtrl.text;
                    existing.videoUrl = videoCtrl.text;
                    existing.nextSceneTitle = nextSceneCtrl.text;
                  });
                } else {
                  setState(() {
                    scene.hotspots.add(
                      VrHotspotItem(
                        id: 'hs_${DateTime.now().millisecondsSinceEpoch}',
                        title: titleCtrl.text.isNotEmpty ? titleCtrl.text : 'Hotspot mới',
                        yaw: yaw,
                        pitch: pitch,
                        description: descCtrl.text,
                        type: type,
                        audioUrl: audioCtrl.text,
                        videoUrl: videoCtrl.text,
                        nextSceneTitle: nextSceneCtrl.text,
                      ),
                    );
                  });
                }
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              child: const Text('Lưu Hotspot'),
            ),
          ],
        ),
      ),
    );
  }
}
