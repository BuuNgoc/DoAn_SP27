import '../entities/destination.dart';

/// [FE-02] Hợp đồng tầng domain cho khám phá điểm đến.
abstract class DestinationRepository {
  Future<List<Destination>> getDestinations({DestinationCategory? category, String? query});

  Future<Destination> getDestinationById(String id);

  /// Danh sách id yêu thích – đọc từ bộ nhớ cục bộ nên hoạt động khi ngoại tuyến.
  Future<Set<String>> getFavoriteIds();

  /// Trả về trạng thái mới (true = đã lưu).
  Future<bool> toggleFavorite(String destinationId);

  /// Danh sách id điểm đến vừa xem gần đây (mới nhất lên đầu, tối đa 10 mục) – lưu cục bộ trong Hive.
  Future<List<String>> getRecentlyViewedIds();

  /// Ghi nhận điểm đến vừa mở và trả về danh sách id cập nhật.
  Future<List<String>> addRecentlyViewed(String destinationId);

  /// Xóa toàn bộ lịch sử xem gần đây trên thiết bị.
  Future<void> clearRecentlyViewed();
}
