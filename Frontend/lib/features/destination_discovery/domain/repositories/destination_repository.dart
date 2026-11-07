import '../entities/destination.dart';

/// [FE-02] Hợp đồng tầng domain cho khám phá điểm đến.
abstract class DestinationRepository {
  Future<List<Destination>> getDestinations({DestinationCategory? category, String? query});

  Future<Destination> getDestinationById(String id);

  /// Danh sách id yêu thích – đọc từ bộ nhớ cục bộ nên hoạt động khi ngoại tuyến.
  Future<Set<String>> getFavoriteIds();

  /// Trả về trạng thái mới (true = đã lưu).
  Future<bool> toggleFavorite(String destinationId);
}
