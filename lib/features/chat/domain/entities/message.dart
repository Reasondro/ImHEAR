import 'package:equatable/equatable.dart';

class Message extends Equatable {
  const Message({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.content,
    required this.createdAt,
  });

  final int id;
  final int roomId;
  final String? senderId;
  final String content;
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, roomId, senderId, content, createdAt];

  factory Message.fromMap(Map<String, dynamic> map) {
    try {
      // !  THIS IS IMPORTANT ==>  Perform null and type checks before casting
      final id = map['id'];
      final roomId = map['room_id'];
      final senderId = map['sender_id']; //?  can be null
      final content = map['content'];
      final createdAtStr = map['created_at'];

      //  !  THIS IS IMPORTANT ==>   --- Validation ---
      if (id == null || id is! int) {
        throw FormatException(
          "Invalid or missing 'id' ($id) in message map: $map",
        );
      }
      if (roomId == null || roomId is! int) {
        throw FormatException(
          "Invalid or missing 'room_id' ($roomId) in message map: $map",
        );
      }
      //  !  THIS IS IMPORTANT ==>  senderId can be null, but check if it's a String if present
      if (senderId != null && senderId is! String) {
        throw FormatException(
          "Invalid 'sender_id' type (${senderId.runtimeType}) in message map: $map",
        );
      }

      if (content == null || content is! String) {
        throw FormatException(
          "Invalid or missing 'content' ($content) in message map: $map",
        );
      }
      if (createdAtStr == null || createdAtStr is! String) {
        throw FormatException(
          "Invalid or missing 'created_at' ($createdAtStr) in message map: $map",
        );
      }
      // !  THIS IS IMPORTANT ==> End Validation ---

      return Message(
        id: id,
        roomId: roomId,
        senderId: senderId,
        content: content,
        createdAt:
            DateTime.parse(
              createdAtStr,
            ).toLocal(), // //!  THIS IS IMPORTANT  Parse and convert to local time
      );
    } catch (e) {
      print("Error parsing message map: $map");
      print("Parsing Error: $e");
      // //!  THIS IS IMPORTANT  Rethrow a more informative error or handle differently
      throw Exception("Failed to parse message data: $e");
    }
  }

  // ? BELOW METHOD STILL WORKS FOR SOME REASON. BUT NEVER BE SO SURE. USE THE MOST SAFEST METHOD ABOVE
  // factory Message.fromMap(Map<String, dynamic> map) {
  //   final id = map['id'] as int;
  //   final roomId = map['room_id'] as int;
  //   final senderId = map['sender_id'] as String;
  //   final content = map['content'] as String;
  //   final createdAtStr = map['created_at'] as String;
  //   return Message(
  //     id: id,
  //     roomId: roomId,
  //     senderId: senderId,
  //     content: content,
  //     createdAt: DateTime.parse(createdAtStr).toLocal(),
  //   );
  // }

  // ! DON'T USE THIS METHOD. DOES NOT WORK. NULL / INT ERROR SHENANIGNAS.
  // factory Message.fromMap(Map<String, dynamic> map) {
  //   return Message(
  //     id: map["id"] as int,
  //     roomId: map["roomId"] as int,
  //     senderId: map["senderId"] as String,
  //     content: map["content"] as String,
  //     createdAt: DateTime.parse(map["createdAt"] as String),
  //   );
  // }
}
