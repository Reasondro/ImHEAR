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
  final String senderId;
  final String content;
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, roomId, senderId, content, createdAt];

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map["id"] as int,
      roomId: map["roomId"] as int,
      senderId: map["senderId"] as String,
      content: map["content"] as String,
      createdAt: DateTime.parse(map["createdAt"] as String),
    );
  }
}

// features/chat/domain/entities/message.dart
// Should have fields like: id (int), roomId (int), senderId (String), content (String), createdAt (DateTime)
// Remember to use Equatable!
