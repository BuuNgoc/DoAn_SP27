import '../entities/map_poi.dart';

/// [FE-04] Hợp đồng truy xuất dữ liệu bản đồ.
abstract class MapRepository {
  Future<List<MapPoi>> getPois();
}
