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
  final List<HearAiResult> resultsHistory;
  final HearAiResult latestResult;

  const HearAiSuccess({
    required this.resultsHistory,
    required this.latestResult,
  });

  @override
  List<Object> get props => [resultsHistory, latestResult];
}

class HearAiError extends HearAiState {
  final String message;
  const HearAiError(this.message);

  @override
  List<Object> get props => [message];
}
