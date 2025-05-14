import 'dart:io';
import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

part 'hear_ai_state.dart';

class HearAiCubit extends Cubit<HearAiState> {
  final AudioRecorder _audioRecorder = AudioRecorder();
  String? _currentRecordingPath;
  final GenerativeModel _model = GenerativeModel(
    model: "gemini-2.0-flash-lite",
    // model: "gemini-2.0-flash",
    // model: "gemini-2.5-flash-preview-04-17",
    apiKey: dotenv.env["GEMINI_API_KEY"]!,
  );
  HearAiCubit() : super(HearAiInitial()) {
    initializeAndCheckPermission();
  }

  Future<void> initializeAndCheckPermission() async {
    bool hasPermission = await Permission.microphone.isGranted;

    if (!hasPermission) {
      emit(const HearAiPermissionNeeded(message: "message"));
    } else {
      emit(HearAiReadyToRecord());
    }
  }

  Future<void> requestMicrophonePermission() async {
    PermissionStatus status = await Permission.microphone.request();

    if (status.isGranted) {
      emit(HearAiReadyToRecord());
    } else if (status.isPermanentlyDenied) {
      emit(
        const HearAiPermissionNeeded(
          message:
              "Microphone permission is permanently denied. Please enable it in app settings.",
          isPermanentlyDenied: true,
        ),
      );
      // await openAppSettings(); //? maybe add this ?
    } else {
      emit(
        const HearAiPermissionNeeded(message: "Microphone permission denied."),
      );
    }
  }

  Future<void> startRecording() async {
    // ? ensure permission is granted before starting
    if (state is HearAiPermissionNeeded &&
        !(await Permission.microphone.isLimited)) {
      await requestMicrophonePermission(); //? requesting again

      if (state is! HearAiReadyToRecord) {
        return; //? if still not ready
      }
    }
    if (state is HearAiRecording) {
      return;
    }

    try {
      final Directory tempDir = await getTemporaryDirectory();

      _currentRecordingPath = "${tempDir.path}/hear_ai_chunk.ogg";

      await _audioRecorder.start(
        const RecordConfig(encoder: AudioEncoder.opus),
        path: _currentRecordingPath!,
      );

      emit(HearAiRecording());
      print("HearAiCubit: Recording started to $_currentRecordingPath");
    } catch (e) {
      emit(HearAIError("Failed to start recording: $e"));
      print("HearAiCubit: Error starting recording - $e");
    }
  }

  Future<void> stopAndProcessRecording() async {
    if (state is! HearAiRecording) //? not recording
    {
      return;
    }

    try {
      final String? path = await _audioRecorder.stop();
      print("HearAiCubit: Recording stopped. File at $path");

      if (path != null) {
        final File audioFile = File(path);
        if (await audioFile.exists()) {
          final Uint8List fileBytes = await audioFile.readAsBytes();
          await audioFile.delete(); //? cleanu temp
          print("HearAiCubit: Audio file read (${fileBytes.length} bytes)");
          emit(HearAiProcessing());
          await _processAudioWithGemini(fileBytes);
        } else {
          throw Exception("Recorded audio file not found at $path");
        }
      } else {
        throw Exception("Stopping recording did not return a file path.");
      }
    } catch (e) {
      emit(
        HearAIError("HearAiCubit: Erorr stopping/processing recording - $e"),
      );
      print("HearAICubit: Error stopping/processing recording - $e");

      // ? optional, revert to ready to record again
      if (await Permission.microphone.isGranted) {
        emit(HearAiReadyToRecord());
      } else {
        emit(
          const HearAiPermissionNeeded(
            message: "Microphone permission might be needed",
          ),
        );
      }
    }
  }

  Future<void> _processAudioWithGemini(Uint8List audioBytes) async {
    const String mimeType = "audio/opus";

    try {
      final DataPart audioDataPart = DataPart(mimeType, audioBytes);
      final String soundCategories = [
        // ? speech
        "SPEECH_NEUTRAL", "SPEECH_QUESTION", "SPEECH_HAPPY_EXCITED",
        "SPEECH_ANGRY_STRESSED",
        "SPEECH_URGENT_IMPORTANT",
        "SPEECH_INSTRUCTION",
        "SPEECH_SAD",
        "SPEECH_UNCLEAR",
        //? sounds
        "SOUND_ALARM",
        // "SOUND_SIREN", //? this shit always take the spot
        // "SOUND_CAR_HORN",
        "SOUND_VEHICLE_HORN",
        // "SOUND_ALARM_FIRE",
        // "SOUND_ALARM_SMOKE",
        "SOUND_DOORBELL_KNOCK",
        "SOUND_PHONE_RINGING",
        "SOUND_CROWD_NOISE",
        "SOUND_PERSON_COUGH_SNEEZE",
        "SOUND_ANIMAL_SOUND",
        "SOUND_LOUD_IMPACT",
        "SOUND_EXPLOSION",
        "SOUND_BABY_CRYING",
        "SOUND_MUSIC",
        //? fallbacks
        "SOUND_GENERAL_LOUD", "AMBIENT_NOISE",
      ].join(", ");

      final TextPart promptPart = TextPart(
        "Analyze the provided audio. "
        "1. If clear human speech is present, transcribe it. Also determine its dominant tone/intent. "
        "2. Independently, listen for any of the following specific environmental sounds if they are prominent:ALARM,VEHICLE_HORN ,DOORBELL_KNOCK,PHONE_RINGING,CROWD_NOISE,PERSON_COUGH_SNEEZE ,ANIMAL_SOUND, LOUD_IMPACT, EXPLOSION,BABY_CRYING,MUSIC ,GENERAL_LOUD, AMBIENT_NOISE"
        "3. Determine the single most significant event or type of speech from the audio. "
        "4. Classify this primary event into ONE of these categories: $soundCategories. "
        "Output your response STRICTLY in the following format, ensuring each field is on a new line: "
        "EVENT_TYPE: [THE CHOSEN CATEGORY FROM THE LIST ABOVE] "
        "TRANSCRIPTION: [The transcribed speech if EVENT_TYPE starts with 'SPEECH_', otherwise 'N/A'] "
        "DETAILS: [If speech, provide a concise description of the speaker's tone, intent, or emotion (e.g., 'questioning', 'urgent', 'happy', 'annoyed'). If an environmental sound, provide any further context or nuance if discernible (e.g., 'distant siren', 'intermittent barking', 'loud continuous alarm'); if no further specific context, output 'N/A'. If AMBIENT_NOISE, describe the nature of the ambient noise (e.g., 'quiet room', 'wind noise', 'traffic rumble'). If the primary event is UNCLEAR, provide a brief reason if possible (e.g., 'muffled sound', 'overlapping sounds'), otherwise 'N/A'.]",
      );

      final GenerateContentResponse response = await _model.generateContent([
        Content.multi([promptPart, audioDataPart]),
      ]);

      if (isClosed) {
        return; //? safe check if cubit was closed
      }

      if (response.text != null) {
        String rawResponseText = response.text!;
        String eventType = "UNKNOWN";
        String transcription = "N/A";
        String details = "";

        final List<String> lines = rawResponseText.split("\n");

        for (String line in lines) {
          if (line.startsWith("EVENT_TYPE:")) {
            eventType = line.substring("EVENT_TYPE:".length).trim();
          } else if (line.startsWith("TRANSCRIPTION:")) {
            transcription = line.substring("TRANSCRIPTION:".length).trim();
          } else if (line.startsWith("DETAILS:")) {
            details = line.substring("DETAILS:".length).trim();
          }
        }
        print(
          "HearAICubit: Processed - EventType='$eventType', Transcription='$transcription', Details='$details'",
        );
        emit(
          HearAiSuccess(
            transcription: transcription,
            eventType: eventType,
            details: details,
          ),
        );
      } else {
        throw Exception("No response text from AI");
      }
    } catch (e) {
      print("HearAiCubit: Error processing with gemini - $e");
      if (!isClosed) {
        emit(HearAIError("AI processing failed: $e"));
      }
    }
  }

  @override
  Future<void> close() {
    _audioRecorder.dispose();
    print("HearAiCubit disposed, audio recorder disposed.");
    return super.close();
  }
}
