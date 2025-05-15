import 'package:equatable/equatable.dart';

class HearAiResult extends Equatable {
  const HearAiResult({
    required this.transcription,
    required this.eventType,
    required this.details,
    required this.timestamp,
  });
  final String transcription;
  final String eventType;
  final String details;
  final DateTime timestamp;

  @override
  List<Object?> get props => ([transcription, eventType, details, timestamp]);
}
