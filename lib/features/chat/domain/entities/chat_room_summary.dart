// import 'package:equatable/equatable.dart';

// TODO : DEVELOP OFFICIAL INTEGRATION
// ! not needed for the version we have
// class ChatRoomSummary extends Equatable {
//   final int roomId;
//   final String subSpaceId;
//   final String deafUserId;
//   final String? deafUserName; // Fetched via join
//   final String? deafUserAvatarUrl; // Fetched via join
//   final String? lastMessageSnippet;
//   final DateTime? lastMessageTimestamp;
//   final int unreadCount; // For official

//   const ChatRoomSummary({
//     required this.roomId,
//     required this.subSpaceId,
//     required this.deafUserId,
//     this.deafUserName,
//     this.deafUserAvatarUrl,
//     this.lastMessageSnippet,
//     this.lastMessageTimestamp,
//     this.unreadCount = 0,
//   });

//   factory ChatRoomSummary.fromMap(Map<String, dynamic> map) {
//     // This mapping depends on your Supabase query result
//     return ChatRoomSummary(
//       roomId: map['id'] as int, // Assuming 'id' is room_id from chat_rooms
//       subSpaceId: map['sub_space_id'] as String,
//       deafUserId: map['deaf_user_id'] as String,
//       deafUserName:
//           map['deaf_user_profile']?['full_name'] as String? ??
//           map['deaf_user_profile']?['username'] as String?,
//       // lastMessageSnippet: map['latest_message']?['content'] as String?,
//       // lastMessageTimestamp: map['latest_message']?['created_at'] != null
//       //     ? DateTime.parse(map['latest_message']['created_at'])
//       //     : null,
//       // unreadCount: map['unread_messages_count'] as int? ?? 0,
//     );
//   }
//   @override
//   List<Object?> get props => [
//     roomId,
//     subSpaceId,
//     deafUserId,
//     deafUserName,
//     lastMessageSnippet,
//     unreadCount,
//   ];
// }
