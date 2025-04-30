import 'package:komunika/features/nearby_officials/domain/entities/nearby_official.dart';

abstract class NearbyOfficialsRepository {
  Future<List<NearbyOfficial>> findNearbyOfficials({
    required double latitude,
    required double longitude,
    required double radius,
  });
}
