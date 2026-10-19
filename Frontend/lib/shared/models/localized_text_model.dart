/// Model supporting 4 languages (LI-06: vi, en, ko, zh)
class LocalizedTextModel {
  final String vi;
  final String en;
  final String ko;
  final String zh;

  const LocalizedTextModel({
    required this.vi,
    required this.en,
    required this.ko,
    required this.zh,
  });

  factory LocalizedTextModel.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return const LocalizedTextModel(vi: '', en: '', ko: '', zh: '');
    }
    return LocalizedTextModel(
      vi: map['vi'] as String? ?? '',
      en: map['en'] as String? ?? '',
      ko: map['ko'] as String? ?? '',
      zh: map['zh'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'vi': vi,
      'en': en,
      'ko': ko,
      'zh': zh,
    };
  }

  String getLocalized(String languageCode) {
    switch (languageCode) {
      case 'en':
        return en.isNotEmpty ? en : vi;
      case 'ko':
        return ko.isNotEmpty ? ko : (en.isNotEmpty ? en : vi);
      case 'zh':
        return zh.isNotEmpty ? zh : (en.isNotEmpty ? en : vi);
      case 'vi':
      default:
        return vi;
    }
  }
}
