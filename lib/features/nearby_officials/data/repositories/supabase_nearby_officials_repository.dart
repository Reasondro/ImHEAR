import 'package:komunika/features/nearby_officials/domain/entities/nearby_official.dart';
import 'package:komunika/features/nearby_officials/domain/repositories/nearby_officials_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseNearbyOfficialsRepository extends NearbyOfficialsRepository {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  @override
  Future<List<NearbyOfficial>> findNearbyOfficials({
    required double latitude,
    required double longitude,
    required double radius,
  }) async {
    try {
      final List<dynamic> response = await _supabaseClient.rpc(
        'find_nearby_officials',
        params: {
          'user_lat': latitude,
          'user_lon': longitude,
          'search_radius_meters': radius,
        },
      );

      // print("Response: $response");
      final List<NearbyOfficial> officials =
          response.map((rawData) {
            // ? cast rawData to the expected Map type
            final data = rawData as Map<String, dynamic>;
            // ? perform the mapping from Map keys (function return column names)
            //? to NearbyOfficial fields. Handle types carefully.
            return NearbyOfficial(
              // ? ensure keys match EXACTLY the column names returned by the function
              locationId: data['location_id'] as int,
              subSpaceId: data['sub_space_id'] as String,
              officialUserId: data['official_user_id'] as String,
              officialUserName:
                  data['official_username']
                      as String, //? assume non-null based on entity
              officialFullName:
                  data['official_full_name']
                      as String, //? asssume non-null based on entity
              locationName: data['location_name'] as String,
              // ? handle nullable description - use `as String?`
              locationDescription: data['description'] as String?,
              // ? ensure distance is parsed as double
              distanceMeters: (data['distance_meters'] as num).toDouble(),
            );
          }).toList(); //?  convert the mapped iterable back to a List

      // print("Fetched ${officials.length} nearby officials.");
      return officials;
    } on PostgrestException catch (e) {
      // print("Supabase Error fetching nearby officials: ${e.message}");
      // Rethrow a more specific or generic exception for the Cubit to catch
      throw Exception("Database error: ${e.message}");
    } catch (e) {
      // Handle any other unexpected errors during the process
      // print("Unexpected Error fetching nearby officials: $e"); // Debug log
      throw Exception("Failed to fetch nearby officials: $e");
    }
  }
}
