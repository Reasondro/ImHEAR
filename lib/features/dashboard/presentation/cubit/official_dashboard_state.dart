// import 'package:equatable/equatable.dart';
// import 'package:komunika/features/chat/domain/entities/chat_room_summary.dart';
// import 'package:komunika/features/chat/domain/entities/sub_space.dart';

// abstract class OfficialDashboardState extends Equatable {
//   const OfficialDashboardState();
//   @override
//   List<Object?> get props => [];
// }

// class OfficialDashboardInitial extends OfficialDashboardState {}

// class OfficialDashboardLoadingSubSpaces extends OfficialDashboardState {
//   final List<SubSpace> availableSubSpaces;
//   final SubSpace? selectedSubSpace;
//   final bool isBroadcasting;
//   final List<ChatRoomSummary> activeChats; // Keep existing chats if any
//   const OfficialDashboardLoadingSubSpaces({
//     required this.availableSubSpaces,
//     this.selectedSubSpace,
//     required this.isBroadcasting,
//     required this.activeChats,
//   });
//   @override
//   List<Object?> get props => [
//     availableSubSpaces,
//     selectedSubSpace,
//     isBroadcasting,
//     activeChats,
//   ];
// }

// class OfficialDashboardSubSpacesLoaded extends OfficialDashboardState {
//   final List<SubSpace> availableSubSpaces;
//   final SubSpace? selectedSubSpace;
//   final bool isBroadcasting;
//   final List<ChatRoomSummary> activeChats;
//   const OfficialDashboardSubSpacesLoaded({
//     required this.availableSubSpaces,
//     this.selectedSubSpace,
//     required this.isBroadcasting,
//     required this.activeChats,
//   });
//   @override
//   List<Object?> get props => [
//     availableSubSpaces,
//     selectedSubSpace,
//     isBroadcasting,
//     activeChats,
//   ];
// }

// class OfficialDashboardLoading extends OfficialDashboardState {
//   // General loading for broadcast/chats
//   final List<SubSpace> availableSubSpaces;
//   final SubSpace? selectedSubSpace;
//   final bool isBroadcasting; // usually true if stopping, false if starting
//   final List<ChatRoomSummary> activeChats;
//   const OfficialDashboardLoading({
//     required this.availableSubSpaces,
//     this.selectedSubSpace,
//     required this.isBroadcasting,
//     required this.activeChats,
//   });
//   @override
//   List<Object?> get props => [
//     availableSubSpaces,
//     selectedSubSpace,
//     isBroadcasting,
//     activeChats,
//   ];
// }

// class OfficialDashboardLoaded extends OfficialDashboardState {
//   // Main loaded state with chats
//   final List<SubSpace> availableSubSpaces;
//   final SubSpace? selectedSubSpace;
//   final bool isBroadcasting;
//   final List<ChatRoomSummary> activeChats;
//   const OfficialDashboardLoaded({
//     required this.availableSubSpaces,
//     required this.selectedSubSpace,
//     required this.isBroadcasting,
//     required this.activeChats,
//   });
//   @override
//   List<Object?> get props => [
//     availableSubSpaces,
//     selectedSubSpace,
//     isBroadcasting,
//     activeChats,
//   ];
// }

// class OfficialDashboardError extends OfficialDashboardState {
//   final String message;
//   const OfficialDashboardError(this.message);
//   @override
//   List<Object?> get props => [message];
// }
