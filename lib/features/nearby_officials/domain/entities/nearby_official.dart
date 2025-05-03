import 'package:equatable/equatable.dart';

class NearbyOfficial extends Equatable {
  const NearbyOfficial({
    required this.locationId,
    required this.subSpaceId,
    required this.officialUserId,
    required this.officialUserName,
    required this.officialFullName,
    required this.locationName,
    this.locationDescription,
    required this.distanceMeters,
  });

  final int locationId;
  final String subSpaceId;
  final String officialUserId;
  final String officialUserName;
  final String officialFullName;
  final String locationName;
  final String? locationDescription;
  final double distanceMeters;

  @override
  List<Object?> get props => [
    locationId,
    officialUserId,
    officialUserName,
    officialFullName,
    locationName,
    locationDescription,
    distanceMeters,
  ];
}
