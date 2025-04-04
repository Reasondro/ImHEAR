import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';

sealed class UserLocationState extends Equatable {
  const UserLocationState();

  @override
  List<Object?> get props => [];
}

final class UserLocationInitial extends UserLocationState {}

final class UserLocationLoading extends UserLocationState {}

final class UserLocationServiceDisabled extends UserLocationState {}

final class UserLocationPermissionDenied extends UserLocationState {}

final class UserLocationPermissionDeniedForever extends UserLocationState {}

final class UserLocationTracking extends UserLocationState {
  final Position position;

  const UserLocationTracking({required this.position});

  @override
  List<Object?> get props => [position];

  @override
  String toString() {
    return "UserLocationTracking(Latitude: ${position.latitude}, Longitude: ${position.longitude})";
  }
}

final class UserLocationError extends UserLocationState {
  final String message;

  const UserLocationError({required this.message});

  @override
  List<Object?> get props => [message];
}
