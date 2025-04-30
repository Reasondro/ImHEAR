import 'package:komunika/features/nearby_officials/domain/entities/nearby_official.dart';
import 'package:komunika/features/nearby_officials/domain/repositories/nearby_officials_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseNearbyOfficialsRepository extends NearbyOfficialsRepository {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  Future<List<NearbyOfficial>> findNearbyOfficials({
    required double latitude,
    required double longitude,
    required double radius,
  }) async {
    try {
      // final List<dynamic> response = await _supabaseClient.rpc(
      final dynamic response = await _supabaseClient.rpc(
        "find_nearby_officials",
        params: {
          "user_lon": longitude,
          "user_lat": latitude,
          "search_radius_meters": radius,
        },
      );
      print(response);
      final List<NearbyOfficial> nearbyOfficials = [];
      return nearbyOfficials;
    } catch (e) {
      print("Error getting nearby officials $e ");
    }
    return [];
  }
}
