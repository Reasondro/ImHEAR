import 'package:komunika/features/chat/domain/entities/message.dart';

abstract class ChatRepository {
  // ? finds an existing chat room between the current user and the given subSpaceId,
  // ? or creates a new one if it doesn't exist.
  // ? returns the unique ID of the chat room.
  // ? throws an exception on failure.
  Future<int> getOrCreateChatRoom({required String subSpaceId});

  // ? gets a stream of messages for the specified chat room, ordered by creation time.
  // ? the stream should automatically update when new messages arrive via Realtime.
  // ? [roomId] is the ID obtained from getOrCreateChatRoom.
  Stream<List<Message>> getMessagesStream({required int roomId});

  // ? Sends a new text message to the specified chat room.
  // ? [roomId] is the ID of the room.
  // ? [content] is the text message content.
  // ? Throws an exception on failure.
  Future<void> sendMessage({required int roomId, required String content});

  // Potential future methods: markAsRead, loadMoreMessages, etc.
}
