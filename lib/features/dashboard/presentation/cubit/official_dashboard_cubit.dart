// // --- Placeholder OfficialDashboardCubit & State ---
// // You would build this out properly
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:komunika/features/chat/domain/repositories/chat_repository.dart';
// import 'package:komunika/features/user_location/presentation/cubit/user_location_cubit.dart';

// class OfficialDashboardCubit extends Cubit<OfficialDashboardState> {
//   final SubSpaceRepository subSpaceRepository;
//   final OfficialLocationRepository officialLocationRepository;
//   final ChatRepository chatRepository; // For fetching chats for a sub space
//   final UserLocationCubit userLocationCubit; // To get current location for broadcasting
//   final String officialId;
//   final String? managingOrgAdminId;


//   StreamSubscription? _chatRoomsSubscription;

//   OfficialDashboardCubit({
//     required this.subSpaceRepository,
//     required this.officialLocationRepository,
//     required this.chatRepository,
//     required this.userLocationCubit,
//     required this.officialId,
//     this.managingOrgAdminId,
//   }) : super(OfficialDashboardInitial()) {
//     _fetchAvailableSubSpaces();
//     _checkInitialBroadcastStatus(); // Check if already broadcasting
//   }

//   List<SubSpace> _availableSubSpaces = [];
//   SubSpace? _selectedSubSpace;
//   bool _isBroadcasting = false;
//   String? _currentBroadcastId; // from official_locations table PK

//   Future<void> _fetchAvailableSubSpaces() async {
//     if (managingOrgAdminId == null) {
//       emit(OfficialDashboardError("Not linked to an organization admin."));
//       return;
//     }
//     emit(OfficialDashboardLoadingSubSpaces(
//         isBroadcasting: _isBroadcasting,
//         selectedSubSpace: _selectedSubSpace,
//         availableSubSpaces: _availableSubSpaces,
//         activeChats: state is OfficialDashboardLoaded ? (state as OfficialDashboardLoaded).activeChats : []));
//     try {
//       _availableSubSpaces = await subSpaceRepository.getSubSpacesForOrgAdmin(orgAdminId: managingOrgAdminId!);
//       emit(OfficialDashboardSubSpacesLoaded(
//         availableSubSpaces: _availableSubSpaces,
//         selectedSubSpace: _selectedSubSpace, // Might be null initially
//         isBroadcasting: _isBroadcasting,
//         activeChats: state is OfficialDashboardLoaded ? (state as OfficialDashboardLoaded).activeChats : []
//       ));
//     } catch (e) {
//       emit(OfficialDashboardError("Failed to load sub spaces: $e"));
//     }
//   }

//   void selectSubSpace(SubSpace? subSpace) {
//     _selectedSubSpace = subSpace;
//     // Re-emit a state that reflects the selection, but not necessarily "Loaded" unless data is loaded
//      if (state is OfficialDashboardSubSpacesLoaded || state is OfficialDashboardLoaded || state is OfficialDashboardInitial) {
//         emit(OfficialDashboardSubSpacesLoaded( // Or a more generic "ReadyToBroadcast" state
//             availableSubSpaces: _availableSubSpaces,
//             selectedSubSpace: _selectedSubSpace,
//             isBroadcasting: _isBroadcasting,
//             activeChats: state is OfficialDashboardLoaded ? (state as OfficialDashboardLoaded).activeChats : []
//         ));
//     }
//   }
  
//   Future<void> _checkInitialBroadcastStatus() async {
//     // TODO: Query official_locations to find if this officialId is broadcasting
//     // If yes, set _isBroadcasting = true, _selectedSubSpace, _currentBroadcastId
//     // and call _fetchActiveChatsForSubSpace(_selectedSubSpace!.id)
//   }


//   Future<void> toggleBroadcast() async {
//     if (_isBroadcasting) { // Stop broadcasting
//       try {
//         emit(OfficialDashboardLoading(isBroadcasting: true, selectedSubSpace: _selectedSubSpace, availableSubSpaces: _availableSubSpaces, activeChats: state is OfficialDashboardLoaded ? (state as OfficialDashboardLoaded).activeChats : []));
//         await officialLocationRepository.stopBroadcasting(officialId: officialId, broadcastId: _currentBroadcastId);
//         _isBroadcasting = false;
//         _chatRoomsSubscription?.cancel();
//         emit(OfficialDashboardLoaded(
//             availableSubSpaces: _availableSubSpaces,
//             selectedSubSpace: _selectedSubSpace,
//             isBroadcasting: _isBroadcasting,
//             activeChats: const [] // Clear chats
//         ));
//       } catch (e) {
//         emit(OfficialDashboardError("Failed to stop broadcast: $e"));
//       }
//     } else { // Start broadcasting
//       if (_selectedSubSpace == null) {
//         emit(OfficialDashboardError("Please select a sub space first."));
//         // Re-emit previous loaded state if possible to keep UI consistent
//          if (state is OfficialDashboardSubSpacesLoaded || state is OfficialDashboardLoaded){
//             emit(OfficialDashboardSubSpacesLoaded(availableSubSpaces: _availableSubSpaces, selectedSubSpace: _selectedSubSpace, isBroadcasting: _isBroadcasting, activeChats: state is OfficialDashboardLoaded ? (state as OfficialDashboardLoaded).activeChats : []));
//         }
//         return;
//       }

//       final locState = userLocationCubit.state;
//       if (locState is! UserLocationTracking) {
//         userLocationCubit.startTracking(); // Attempt to start if not already
//         emit(OfficialDashboardError("Acquiring your location. Please try 'Go Live' again shortly."));
//          if (state is OfficialDashboardSubSpacesLoaded || state is OfficialDashboardLoaded){
//             emit(OfficialDashboardSubSpacesLoaded(availableSubSpaces: _availableSubSpaces, selectedSubSpace: _selectedSubSpace, isBroadcasting: _isBroadcasting, activeChats: state is OfficialDashboardLoaded ? (state as OfficialDashboardLoaded).activeChats : []));
//         }
//         return;
//       }
//       emit(OfficialDashboardLoading(isBroadcasting: false, selectedSubSpace: _selectedSubSpace, availableSubSpaces: _availableSubSpaces, activeChats: []));
//       try {
//         _currentBroadcastId = await officialLocationRepository.startBroadcasting(
//           officialId: officialId,
//           subSpaceId: _selectedSubSpace!.id,
//           locationName: _selectedSubSpace!.name, // Ensure SubSpace entity has name
//           position: locState.position,
//         );
//         _isBroadcasting = true;
//         _fetchActiveChatsForSubSpace(_selectedSubSpace!.id); // Fetches and emits OfficialDashboardLoaded
//       } catch (e) {
//         emit(OfficialDashboardError("Failed to start broadcast: $e"));
//       }
//     }
//   }

//   void _fetchActiveChatsForSubSpace(String subSpaceId) {
//     _chatRoomsSubscription?.cancel();
//     // Assume getChatRoomsForSubSpaceStream is similar to the one for deaf user,
//     // but might fetch more details or be filtered differently.
//     // For now, we assume it returns List<ChatRoomSummary>
//     _chatRoomsSubscription = chatRepository
//         .getChatRoomsForSubSpaceStream(subSpaceId: subSpaceId)
//         .listen((chats) {
//       if (!isClosed) {
//         emit(OfficialDashboardLoaded(
//             availableSubSpaces: _availableSubSpaces,
//             selectedSubSpace: _selectedSubSpace,
//             isBroadcasting: _isBroadcasting,
//             activeChats: chats));
//       }
//     }, onError: (e) {
//       if (!isClosed) {
//         emit(OfficialDashboardError("Failed to load chats: $e"));
//       }
//     });
//   }

//   @override
//   Future<void> close() {
//     _chatRoomsSubscription?.cancel();
//     return super.close();
//   }
// }
