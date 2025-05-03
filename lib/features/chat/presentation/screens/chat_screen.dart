import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komunika/features/chat/domain/repositories/chat_repository.dart';
import 'package:komunika/features/chat/presentation/cubit/chat_cubit.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({
    required this.roomId,
    required this.subSpaceName,
    super.key,
  });

  final int roomId;
  final String subSpaceName;
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) => ChatCubit(
            chatRepository: context.read<ChatRepository>(),
            roomId: roomId,
          ),
      child: Scaffold(
        appBar: AppBar(title: Text(subSpaceName)),
        body: Center(
          child: Text("Chat Screen for Room ID: $roomId\nContent coming soon!"),
          // TODO implment BlocBuilder<ChatCubit,ChatState> here later
          // TODO add message list and input field here later
        ),
      ),
    );
  }
}
