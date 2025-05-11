import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
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
    required Position position,
    double radius = 100,
  }) async {
    if (state is NearbyOfficialsLoading) {
      return;
    }
    print(
      "NearbyOfficialCubit: Fetching officials around Lat(Y): ${position.latitude}, Lon(X): ${position.longitude} with radius $radius",
    );

    emit(NearbyOfficialsLoading());
    try {
      List<NearbyOfficial> nearbyOfficials = await _nearbyOfficialRepository
          .findNearbyOfficials(
            latitude: position.latitude,
            longitude: position.longitude,
            radius: radius,
          );
      if (!isClosed) {
        print(
          "NearbyOfficialsCubit: Sucesfully loaded ${nearbyOfficials.length} officials",
        );
        print("Nearby officials from repo: \n $nearbyOfficials");
        emit(NearbyOfficialsLoaded(officials: nearbyOfficials));
      }
    } catch (e) {
      if (!isClosed) {
        print("NearbyOfficialsCubit: Error fetching officials - $e");
        emit(NearbyOfficialsError(message: "NearbyOfficialsCubit error: $e"));
      }
    }
  }

  void clearOfficials() {
    if (!isClosed) {
      emit(NearbyOfficialsInitial());
    }
  }
}
