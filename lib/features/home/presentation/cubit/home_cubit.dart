import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

class HomeCubit extends Cubit<Position> {
  HomeCubit(super.initialState);

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission locationPermission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return Future.error("Location services are disabled");
    }
    locationPermission = await Geolocator.checkPermission();

    if (locationPermission == LocationPermission.denied) {
      locationPermission = await Geolocator.requestPermission();

      if (locationPermission == LocationPermission.denied) {
        return Future.error("Location permissions are denied");
      }
    }
    if (locationPermission == LocationPermission.deniedForever) {
      return Future.error(
        "Location permissions are permanently denied, we cannot request permissions",
      );
    }
    return await Geolocator.getCurrentPosition();
  }

  void updateLocation() async {
    final Position position = await _determinePosition();
    emit(position);
  }
}
