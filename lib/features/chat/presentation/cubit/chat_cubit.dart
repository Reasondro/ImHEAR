import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:komunika/features/chat/domain/entities/message.dart';
import 'package:komunika/features/chat/domain/repositories/chat_repository.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepository _chatRepository;
  final int _roomId;

  StreamSubscription<List<Message>>? _messageSubscription;

  ChatCubit({required ChatRepository chatRepository, required int roomId})
    : _chatRepository = chatRepository,
      _roomId = roomId,
      super(ChatInitial()) {
    _subscribeToMessages();
  }

  void _subscribeToMessages() {
    if (state is ChatInitial && !isClosed) {
      emit(ChatLoading());
    }
    _messageSubscription?.cancel();
    _messageSubscription = _chatRepository
        .getMessagesStream(roomId: _roomId)
        .listen(
          (messages) {
            if (!isClosed) {
              print(
                "ChatCubit: Recevied ${messages.length} messages for room $_roomId",
              );
              emit(ChatLoaded(messages: messages));
            }
          },
          onError: (error) {
            print("ChatCubit stream error for room $_roomId: $error");
            if (!isClosed) {
              emit(
                ChatError(
                  message: "Error loading messages: ${error.toString()}",
                ),
              );
            }
          },
          onDone: () {
            if (!isClosed) {
              emit(ChatError(message: "Message stream closed unexpectedly"));
            }
          },
        );
  }

  Future<void> sendMessage(String content) async {
    final String trimmedContent = content.trim();

    if (trimmedContent.isEmpty) {
      return;
    }

    try {
      await _chatRepository.sendMessage(
        roomId: _roomId,
        content: trimmedContent,
      );
      print("ChatCubit: Message sent for room $_roomId");
    } catch (e) {
      print("ChatCubit send message error for room $_roomId: $e");

      if (!isClosed) {
        emit(ChatError(message: "Failed to send message: ${e.toString()}"));
      }
    }
  }

  @override
  Future<void> close() {
    print("ChatCubit closing subscription for room $_roomId");
    _messageSubscription?.cancel();
    return super.close();
  }
}
