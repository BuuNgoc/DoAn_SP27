import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/destination.dart';
import '../../domain/repositories/destination_repository.dart';
import '../datasources/destination_data_sources.dart';
import '../models/destination_model.dart';

class DestinationRepositoryImpl implements DestinationRepository {
  DestinationRepositoryImpl({required this.remote, required this.favorites});

  final DestinationRemoteDataSource remote;
  final FavoritesLocalDataSource favorites;

  List<DestinationModel>? _cache;

  Future<List<DestinationModel>> _all() async => _cache ??= await remote.fetchDestinations();

  @override
  Future<List<Destination>> getDestinations({DestinationCategory? category, String? query}) async {
    final q = _normalize(query ?? '');
    return (await _all()).where((d) {
      final matchesCategory = category == null || d.category == category;
      final matchesQuery = q.isEmpty ||
          _normalize(d.name).contains(q) ||
          _normalize(d.shortDescription).contains(q) ||
          d.tags.any((t) => _normalize(t).contains(q));
      return matchesCategory && matchesQuery;
    }).toList();
  }

  @override
  Future<Destination> getDestinationById(String id) async {
    final all = await _all();
    return all.firstWhere(
      (d) => d.id == id,
      orElse: () => throw const ServerException('Không tìm thấy điểm đến.'),
    );
  }

  @override
  Future<Set<String>> getFavoriteIds() async => favorites.getIds();

  @override
  Future<bool> toggleFavorite(String destinationId) => favorites.toggle(destinationId);

  /// Tìm kiếm không phân biệt dấu tiếng Việt ("dong huyen khong" ↔ "Động Huyền Không").
  static String _normalize(String input) {
    const groups = {
      'a': 'àáạảãâầấậẩẫăằắặẳẵ',
      'e': 'èéẹẻẽêềếệểễ',
      'i': 'ìíịỉĩ',
      'o': 'òóọỏõôồốộổỗơờớợởỡ',
      'u': 'ùúụủũưừứựửữ',
      'y': 'ỳýỵỷỹ',
      'd': 'đ',
    };
    var s = input.toLowerCase().trim();
    groups.forEach((base, chars) {
      for (final ch in chars.split('')) {
        s = s.replaceAll(ch, base);
      }
    });
    return s;
  }
}
