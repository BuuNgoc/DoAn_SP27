import 'package:equatable/equatable.dart';

/// [FE-03] Một điểm tương tác (hotspot) trong ảnh 360°.
class Vr360Hotspot extends Equatable {
  const Vr360Hotspot({
    required this.id,
    required this.label,
    required this.description,
    required this.latitude,
    required this.longitude,
    this.targetSceneId,
  });

  final String id;
  final String label;
  final String description;

  /// Vị trí trên mặt cầu, đơn vị độ (vĩ độ -90..90, kinh độ -180..180).
  final double latitude;
  final double longitude;

  /// Nếu khác null: chạm vào để chuyển sang góc nhìn khác.
  final String? targetSceneId;

  @override
  List<Object?> get props => [id];
}

/// [FE-03] Một góc nhìn 360° tại điểm đến.
class Vr360Scene extends Equatable {
  const Vr360Scene({
    required this.id,
    required this.destinationId,
    required this.title,
    required this.subtitle,
    required this.panoramaImage,
    this.initialLongitude = 0,
    this.hotspots = const [],
  });

  final String id;
  final String destinationId;
  final String title;
  final String subtitle;
  final String panoramaImage;
  final double initialLongitude;
  final List<Vr360Hotspot> hotspots;

  @override
  List<Object?> get props => [id];
}

/// Bốn ngôn ngữ thuyết minh được hỗ trợ.
enum AudioLanguage {
  vi('vi', 'Tiếng Việt', '🇻🇳'),
  en('en', 'English', '🇬🇧'),
  ko('ko', '한국어', '🇰🇷'),
  zh('zh', '中文', '🇨🇳');

  const AudioLanguage(this.code, this.label, this.flag);
  final String code;
  final String label;
  final String flag;
}

/// [FE-03] Bài thuyết minh tự động của một điểm đến.
class AudioGuide extends Equatable {
  const AudioGuide({
    required this.id,
    required this.destinationId,
    required this.title,
    required this.durationSeconds,
    required this.transcripts,
    this.audioUrls = const {},
    this.narrator = 'Thuyết minh viên SmartTravel',
  });

  final String id;
  final String destinationId;
  final String title;
  final int durationSeconds;

  /// Nội dung chữ theo mã ngôn ngữ (vi/en/ko/zh).
  final Map<String, String> transcripts;

  /// URL tệp âm thanh theo ngôn ngữ (Firebase Storage) – rỗng khi chạy dữ liệu mẫu.
  final Map<String, String> audioUrls;
  final String narrator;

  bool hasLanguage(AudioLanguage lang) => transcripts.containsKey(lang.code);

  /// Trả về bản dịch, nếu chưa có thì dùng tiếng Việt.
  String transcriptFor(AudioLanguage lang) => transcripts[lang.code] ?? transcripts['vi'] ?? '';

  @override
  List<Object?> get props => [id];
}
