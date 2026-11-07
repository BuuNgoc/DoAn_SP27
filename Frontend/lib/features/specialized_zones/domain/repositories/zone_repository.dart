import '../entities/zone_entities.dart';

abstract class ZoneRepository {
  Future<ZoneOverview> getZoneOverview(ZoneType zone);
  Future<AirportWelcomeContent> getAirportWelcome({String? campaignId});
}
