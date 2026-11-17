import '../entities/zone_entities.dart';
import '../repositories/zone_repository.dart';

class GetZoneOverviewUseCase {
  const GetZoneOverviewUseCase(this._r);
  final ZoneRepository _r;
  Future<ZoneOverview> call(ZoneType zone) => _r.getZoneOverview(zone);
}

class GetAirportWelcomeUseCase {
  const GetAirportWelcomeUseCase(this._r);
  final ZoneRepository _r;
  Future<AirportWelcomeContent> call({String? campaignId}) => _r.getAirportWelcome(campaignId: campaignId);
}
