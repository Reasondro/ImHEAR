part of 'nearby_officials_cubit.dart';

sealed class NearbyOfficialsState extends Equatable {
  const NearbyOfficialsState();

  @override
  List<Object> get props => [];
}

final class NearbyOfficialsInitial extends NearbyOfficialsState {}

final class NearbyOfficialsLoading extends NearbyOfficialsState {}

final class NearbyOfficialsLoaded extends NearbyOfficialsState {
  const NearbyOfficialsLoaded({required this.officials});

  final List<NearbyOfficial> officials;

  @override
  List<Object> get props => [officials];

  @override
  String toString() {
    return "NearbyOfficialsLoaded(count: ${officials.length})";
  }
}

final class NearbyOfficialsError extends NearbyOfficialsState {
  const NearbyOfficialsError({required this.message});

  final String message;

  @override
  List<Object> get props => [message];

  @override
  String toString() {
    return "NearbyOfficialError(message: $message)";
  }
}
