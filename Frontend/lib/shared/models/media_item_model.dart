class MediaItemModel {
  final String id;
  final String url;
  final String type; // 'image', 'video', 'vr360', 'audio'
  final String? caption;

  const MediaItemModel({
    required this.id,
    required this.url,
    required this.type,
    this.caption,
  });

  factory MediaItemModel.fromMap(Map<String, dynamic> map) {
    return MediaItemModel(
      id: map['id'] ?? '',
      url: map['url'] ?? '',
      type: map['type'] ?? 'image',
      caption: map['caption'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'url': url,
      'type': type,
      'caption': caption,
    };
  }
}
