import 'package:equatable/equatable.dart';

class NearbyOfficial extends Equatable {
  const NearbyOfficial({
    required this.locationID,
    required this.officialUserId,
    required this.officialUserName,
    required this.officialFullName,
    required this.locationName,
    this.locationDescription,
    required this.distanceMeters,
  });

  final int locationID;
  final String officialUserId;
  final String officialUserName;
  final String officialFullName;
  final String locationName;
  final String? locationDescription;
  final double distanceMeters;

  @override
  List<Object?> get props => [
    locationID,
    officialUserId,
    officialUserName,
    officialFullName,
    locationName,
    locationDescription,
    distanceMeters,
  ];
}
