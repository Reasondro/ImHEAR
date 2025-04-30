import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:komunika/features/nearby_officials/domain/entities/nearby_official.dart';
import 'package:komunika/features/nearby_officials/domain/repositories/nearby_officials_repository.dart';

part 'nearby_officials_state.dart';

class NearbyOfficialsCubit extends Cubit<NearbyOfficialsState> {
  final NearbyOfficialsRepository _nearbyOfficialRepository;

  NearbyOfficialsCubit({
    required NearbyOfficialsRepository nearbyOfficialRepository,
  }) : _nearbyOfficialRepository = nearbyOfficialRepository,
       super(NearbyOfficialsInitial());

  Future<void> findNearbyOfficials({
    required double latitude,
    required double longitude,
    required double radius,
  }) async {
    List<NearbyOfficial> nearbyOfficials = await _nearbyOfficialRepository
        .findNearbyOfficials(
          latitude: latitude,
          longitude: longitude,
          radius: radius,
        );

    print("Nearby officials from repo: \n $nearbyOfficials");

    // return nearbyOfficials;
  }
}
