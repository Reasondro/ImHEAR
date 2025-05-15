import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:komunika/features/hear_ai/domain/entities/hear_ai_result.dart';
import 'package:komunika/features/hear_ai/presentation/widgets/hear_ai_processing_ui.dart';
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

  // ? state variables for contionus mode
  bool _isContinuousListeningActive = false;
  Timer? _continuousListenTimer; //? mamnage periodic recording

  // ? configurable duration
  final Duration _continuousChunkDuration = const Duration(seconds: 5);

  // ? list to store results for continuous mode
  List<HearAiResult> _currentResultsHistory = [];

  HearAiCubit() : super(HearAiInitial()) {
    initializeAndCheckPermission();
  }

  Future<void> initializeAndCheckPermission() async {
    bool hasPermission = await Permission.microphone.isGranted;

    if (!hasPermission) {
      emit(
        const HearAiPermissionNeeded(
          message: "Microphone permission is required to start listening.",
        ),
      );
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
    // if (state is HearAiRecording) {
    //   return;
    // } //? remove for continujous

    try {
      final Directory tempDir = await getTemporaryDirectory();

      _currentRecordingPath = "${tempDir.path}/hear_ai_chunk.ogg";

      await _audioRecorder.start(
        const RecordConfig(encoder: AudioEncoder.opus),
        path: _currentRecordingPath!,
      );

      if (isClosed) {
        return;
      }
      emit(HearAiRecording());
      print("HearAiCubit: Recording started to $_currentRecordingPath");
    } catch (e) {
      if (isClosed) {
        return;
      }
      emit(HearAiError("Failed to start recording: $e"));
      print("HearAiCubit: Error starting recording - $e");
    }
  }

  Future<void> stopAndProcessRecording() async {
    if (state is! HearAiRecording) //? not recording
    {
      print("HearAICubit: stopAndProcess called but not in recording state.");
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

          if (isClosed) {
            return;
          }
          emit(HearAiProcessing());
          await _processAudioWithGemini(fileBytes);
        } else {
          throw Exception("Recorded audio file not found at $path");
        }
      } else {
        throw Exception("Stopping recording did not return a file path.");
      }
    } catch (e) {
      if (isClosed) {
        return;
      }
      emit(
        HearAiError("HearAiCubit: Erorr stopping/processing recording - $e"),
      );
      print("HearAICubit: Error stopping/processing recording - $e");

      // ? if in continuous mode, the loop will try to restart
      // ? if not in continuous mode, reverting to Ready or PermissionNeeded makes sense(?)
      // ? loop itself in _triggerNextContinuousChunk will reevaluate permissions before starting next recording
      // ? soooo.. this specific fallback here might only be relevant for MANUAL stopAndProcess calls.
      if (!_isContinuousListeningActive) {
        //? only do this if not in continuous mode
        // ? optional, revert to ready to record again
        if (await Permission.microphone.isGranted) {
          if (isClosed) return;
          emit(HearAiReadyToRecord());
        } else {
          if (isClosed) return;
          emit(
            const HearAiPermissionNeeded(
              message: "Microphone permission might be needed",
            ),
          );
        }
      }
    }
  }

  Future<void> _processAudioWithGemini(Uint8List audioBytes) async {
    const String mimeType = "audio/opus";

    try {
      final DataPart audioDataPart = DataPart(mimeType, audioBytes);
      final String soundCategories = [
        // ? speech
        "SPEECH_NEUTRAL",
        "SPEECH_QUESTION",
        "SPEECH_HAPPY_EXCITED",
        "SPEECH_ROMANTIC",
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
        "SOUND_PERSON_SCREAMING",
        "SOUND_MUSIC",
        //? fallbacks
        "SOUND_GENERAL_LOUD", "AMBIENT_NOISE",
      ].join(", ");

      final TextPart promptPart = TextPart(
        "Analyze the provided audio. "
        "1. If clear human speech is present, transcribe it. Also determine its dominant tone/intent. "
        "2. Independently, listen for any of the following specific environmental sounds if they are prominent:ALARM,VEHICLE_HORN ,DOORBELL_KNOCK,PHONE_RINGING,CROWD_NOISE,PERSON_COUGH_SNEEZE ,ANIMAL_SOUND, LOUD_IMPACT, EXPLOSION,BABY_CRYING,PERSON_SCREAMING,MUSIC ,GENERAL_LOUD, AMBIENT_NOISE"
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
        final HearAiResult newResult = HearAiResult(
          transcription: transcription,
          eventType: eventType,
          details: details,
          timestamp: DateTime.now(),
        );

        if (_isContinuousListeningActive) {
          _currentResultsHistory.insert(
            0,
            newResult,
          ); //? add to top (kinda like stack)
          emit(
            HearAiSuccess(
              resultsHistory: _currentResultsHistory,
              latestResult: newResult,
            ),
          );
        } else {
          _currentResultsHistory = [newResult];
          emit(
            HearAiSuccess(
              resultsHistory: _currentResultsHistory,
              latestResult: newResult,
            ),
          );
        }
      } else {
        throw Exception("No response text from AI");
      }
    } catch (e) {
      print("HearAiCubit: Error processing with gemini - $e");
      if (!isClosed) {
        emit(HearAiError("AI processing failed: $e"));
      }
    }
  }

  Future<void> startContinuousListening() async {
    if (_isContinuousListeningActive) {
      return; //? already active
    }

    if (state is HearAiPermissionNeeded &&
        !(await Permission.microphone.isGranted)) {
      await requestMicrophonePermission();
      if (state is! HearAiReadyToRecord && state is! HearAiRecording) {
        print("HearAICubit: Permission not granted for contionus listening");
        return;
      }
    }
    if (state is HearAiRecording || state is HearAiProcessing) {
      print(
        "HearAICubit: Cannot start continuous listening while already recording or processing",
      );
      return;
    }
    print("HearAICubit: Starting continuous listening...");
    _isContinuousListeningActive = true;
    _currentResultsHistory = []; //? clear last history

    // ? could emit a state to indicate contionus mode here, if needed by ui
    //? for now / testing, just use the regular record mode
    if (isClosed) {
      return;
    }
    emit(HearAiReadyToRecord());
    _triggerNextContiunousChunk();
  }

  Future<void> stopContinuousListening() async {
    if (!_isContinuousListeningActive) {
      return; //? already not active
    }
    print("HearAICubit: Stopping continuous listening...");
    _isContinuousListeningActive = false;
    _continuousListenTimer?.cancel(); //? cancel any pending timer

    if (state is HearAiRecording) {
      try {
        await _audioRecorder.stop();
        print(
          "HearAICubit: Stopped ongoing recording due to continuous mode stop.",
        );
      } catch (e) {
        print(
          "HearAICubit: Error stopping recorder during continuous stop: $e",
        );
      }
    }

    // ? go back to ready / initial state
    if (await Permission.microphone.isGranted) {
      emit(HearAiReadyToRecord());
    } else {
      emit(
        const HearAiPermissionNeeded(message: "Microphone permission needed."),
      );
    }
  }

  //? method called when userf explicitly clears results or switches mode
  void clearResultsHistory() {
    _currentResultsHistory = [];

    if (!isClosed) {
      //? transition to an appropriate state, perhaps based on _isContinuousListeningActive (?)
      if (_isContinuousListeningActive) {
        emit(
          HearAiSuccess(
            resultsHistory: _currentResultsHistory,
            latestResult: _currentResultsHistory.first,
          ),
        );
      } else {
        if (!isClosed) emit(HearAiReadyToRecord());
      }
    }
  }

  void _triggerNextContiunousChunk() async {
    if (!_isContinuousListeningActive || isClosed) {
      return; //? stop if mode alreayd deactivate or cubit is closed
    }

    //? start recording
    await startRecording();

    //? if start recoding failed or permission issue, emiet error / different state

    if (state is! HearAiRecording) {
      _isContinuousListeningActive = false; //? stop the loop instantl
      print(
        "HearAicubit: Halting continuous loop as recording could not start",
      );
      return;
    }

    //? set timer for chunk duration
    _continuousListenTimer?.cancel(); //? cancel any existing timer
    _continuousListenTimer = Timer(_continuousChunkDuration, () async {
      if (!_isContinuousListeningActive ||
          isClosed ||
          state is! HearAiRecording) {
        // ! basically double checking, in case mode was stopped during the delay or state chagne
        print(
          "HearAICubit: Continuous mode stopped or state changed during timer wait.",
        );
        return;
      }
      // ? stop and process the recording (will emit HearAiProcessing then Sucess/Error)
      print("HearAICubit: Chunk duration ended, stopping and processing.");
      await stopAndProcessRecording();

      // ? if still continuous mode, trigger next chunk (recursive basically)
      if (_isContinuousListeningActive && !isClosed) {
        print(
          "HearAICubit: Processing finished, triggering next continuous chunk.",
        );
        _triggerNextContiunousChunk();
      } else {
        print(
          "HearAICubit: Continuous mode was stopped during/after processing, not looping.",
        );
      }
    });
  }

  @override
  Future<void> close() {
    _audioRecorder.dispose();
    print("HearAiCubit disposed, audio recorder disposed.");
    return super.close();
  }
}
