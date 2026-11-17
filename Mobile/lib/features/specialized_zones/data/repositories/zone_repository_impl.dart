import '../../domain/entities/zone_entities.dart';
import '../../domain/repositories/zone_repository.dart';
import '../datasources/zone_remote_data_source.dart';

class ZoneRepositoryImpl implements ZoneRepository {
  const ZoneRepositoryImpl(this._remote);
  final ZoneRemoteDataSource _remote;

  @override
  Future<ZoneOverview> getZoneOverview(ZoneType zone) => _remote.getZoneOverview(zone);

  @override
  Future<AirportWelcomeContent> getAirportWelcome({String? campaignId}) =>
      _remote.getAirportWelcome(campaignId: campaignId);
}
