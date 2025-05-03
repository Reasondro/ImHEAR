part of 'chat_cubit.dart';

sealed class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object> get props => [];
}

final class ChatInitial extends ChatState {}

final class ChatLoading extends ChatState {}

final class ChatSending extends ChatState {} //TODO maybe incoportate this

final class ChatLoaded extends ChatState {
  const ChatLoaded({required this.messages});

  final List<Message> messages;

  @override
  List<Object> get props => [messages];
}

final class ChatError extends ChatState {
  const ChatError({required this.message});

  final String message;

  @override
  List<Object> get props => [message];
}
