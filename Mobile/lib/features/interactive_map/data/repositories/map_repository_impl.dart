import '../../domain/entities/map_poi.dart';
import '../../domain/repositories/map_repository.dart';
import '../datasources/map_data_source.dart';

class MapRepositoryImpl implements MapRepository {
  MapRepositoryImpl(this._remote);

  final MapRemoteDataSource _remote;
  List<MapPoi>? _cache;

  @override
  Future<List<MapPoi>> getPois() async {
    // Giữ bộ nhớ đệm trong phiên để bản đồ vẫn hiển thị khi mất mạng (LI-05).
    try {
      _cache = await _remote.fetchPois();
    } catch (_) {
      if (_cache == null) rethrow;
    }
    return _cache!;
  }
}
