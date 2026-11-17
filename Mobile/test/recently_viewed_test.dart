import 'package:flutter_test/flutter_test.dart';
import 'package:smart_travel_app/features/destination_discovery/data/datasources/destination_data_sources.dart';
import 'package:smart_travel_app/features/destination_discovery/domain/entities/destination.dart';
import 'package:smart_travel_app/features/destination_discovery/domain/repositories/destination_repository.dart';
import 'package:smart_travel_app/features/destination_discovery/domain/usecases/destination_usecases.dart';
import 'package:smart_travel_app/features/destination_discovery/presentation/bloc/destination_cubits.dart';

class _InMemoryDestinationRepository implements DestinationRepository {
  List<String> _recentIds = const [];

  @override
  Future<List<String>> getRecentlyViewedIds() async => _recentIds;

  @override
  Future<List<String>> addRecentlyViewed(String destinationId) async {
    _recentIds = RecentlyViewedLocalDataSource.computeUpdatedIds(_recentIds, destinationId);
    return _recentIds;
  }

  @override
  Future<void> clearRecentlyViewed() async {
    _recentIds = const [];
  }

  @override
  Future<Destination> getDestinationById(String id) => throw UnimplementedError();

  @override
  Future<List<Destination>> getDestinations({DestinationCategory? category, String? query}) =>
      throw UnimplementedError();

  @override
  Future<Set<String>> getFavoriteIds() async => const {};

  @override
  Future<bool> toggleFavorite(String destinationId) async => false;
}

void main() {
  group('RecentlyViewedLocalDataSource.computeUpdatedIds', () {
    test('mới nhất lên đầu và không trùng lặp khi mở lại điểm đến cũ', () {
      var list = <String>[];
      list = RecentlyViewedLocalDataSource.computeUpdatedIds(list, 'dong_huyen_khong');
      list = RecentlyViewedLocalDataSource.computeUpdatedIds(list, 'chua_linh_ung');
      list = RecentlyViewedLocalDataSource.computeUpdatedIds(list, 'lang_da_non_nuoc');

      expect(list, ['lang_da_non_nuoc', 'chua_linh_ung', 'dong_huyen_khong']);

      // Mở lại điểm đến cũ -> nhảy lên đầu, không bị lặp
      list = RecentlyViewedLocalDataSource.computeUpdatedIds(list, 'dong_huyen_khong');
      expect(list, ['dong_huyen_khong', 'lang_da_non_nuoc', 'chua_linh_ung']);
    });

    test('giới hạn tối đa 10 mục, tự động đẩy mục cũ nhất ra ngoài', () {
      var list = <String>[];
      for (var i = 1; i <= 12; i++) {
        list = RecentlyViewedLocalDataSource.computeUpdatedIds(list, 'dest_$i');
      }

      expect(list.length, RecentlyViewedLocalDataSource.maxItems);
      expect(list.first, 'dest_12');
      expect(list.last, 'dest_3');
      expect(list.contains('dest_1'), isFalse);
      expect(list.contains('dest_2'), isFalse);
    });
  });

  group('RecentlyViewedCubit', () {
    late _InMemoryDestinationRepository repo;
    late RecentlyViewedCubit cubit;

    setUp(() {
      repo = _InMemoryDestinationRepository();
      cubit = RecentlyViewedCubit(
        getIds: GetRecentlyViewedIdsUseCase(repo),
        add: AddRecentlyViewedUseCase(repo),
        clear: ClearRecentlyViewedUseCase(repo),
      );
    });

    tearDown(() => cubit.close());

    test('add, deduplicate, cap 10 và clear hoạt động đúng', () async {
      await cubit.load();
      expect(cubit.state, isEmpty);

      await cubit.add('a');
      await cubit.add('b');
      await cubit.add('c');
      expect(cubit.state, ['c', 'b', 'a']);

      // Mở lại 'a' -> nhảy lên đầu
      await cubit.add('a');
      expect(cubit.state, ['a', 'c', 'b']);

      // Xóa lịch sử
      await cubit.clear();
      expect(cubit.state, isEmpty);
    });
  });
}
