part of 'hear_ai_cubit.dart';

sealed class HearAiState extends Equatable {
  const HearAiState();

  @override
  List<Object> get props => [];
}

final class HearAiInitial extends HearAiState {}

final class HearAiPermissionNeeded extends HearAiState {
  final String message;
  final bool isPermanentlyDenied;

  const HearAiPermissionNeeded({
    required this.message,
    this.isPermanentlyDenied = false, //? default value
  });

  @override
  List<Object> get props => [message, isPermanentlyDenied];
}

final class HearAiReadyToRecord extends HearAiState {}

final class HearAiRecording extends HearAiState {}

final class HearAiProcessing extends HearAiState {}

final class HearAiSuccess extends HearAiState {
  final String transcription;
  final String eventType;
  final String details;

  const HearAiSuccess({
    required this.transcription,
    required this.eventType,
    required this.details,
  });

  @override
  List<Object> get props => [transcription, eventType, details];
}

class HearAIError extends HearAiState {
  final String message;
  const HearAIError(this.message);

  @override
  List<Object> get props => [message];
}
