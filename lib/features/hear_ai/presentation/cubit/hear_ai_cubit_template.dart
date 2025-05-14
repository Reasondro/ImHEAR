// // features/hear_ai/presentation/cubit/hear_ai_cubit.dart
// import 'dart:async';
// import 'dart:io';
// import 'dart:typed_data';

// import 'package:bloc/bloc.dart';
// import 'package:equatable/equatable.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:google_generative_ai/google_generative_ai.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:record/record.dart';

// part 'hear_ai_state.dart';

// class HearAICubit extends Cubit<HearAIState> {
//   final AudioRecorder _audioRecorder = AudioRecorder();
//   String? _currentRecordingPath;
//   final GenerativeModel _model;

//   HearAICubit()
//     : _model = GenerativeModel(
//         // Ensure your model name is correct and supports audio
//         model: "gemini-1.5-flash-latest", // Or your chosen model from testing
//         apiKey: dotenv.env["GEMINI_API_KEY"]!,
//       ),
//       super(HearAIInitial()) {
//     _initialize(); // Initialize and check permissions when cubit is created
//   }

//   Future<void> _initialize() async {
//     bool hasPermission = await Permission.microphone.isGranted;
//     if (!hasPermission) {
//       emit(
//         const HearAIPermissionNeeded(
//           "Microphone permission is required to start listening.",
//         ),
//       );
//     } else {
//       emit(HearAIReadyToRecord());
//     }
//   }

//   Future<void> requestMicrophonePermission() async {
//     PermissionStatus status = await Permission.microphone.request();
//     if (status.isGranted) {
//       emit(HearAIReadyToRecord());
//     } else if (status.isPermanentlyDenied) {
//       emit(
//         const HearAIPermissionNeeded(
//           "Microphone permission is permanently denied. Please enable it in app settings.",
//           isPermanentlyDenied: true,
//         ),
//       );
//       // Consider openAppSettings();
//     } else {
//       emit(const HearAIPermissionNeeded("Microphone permission denied."));
//     }
//   }

//   Future<void> startRecording() async {
//     // Ensure permission is granted before starting
//     if (state is HearAIPermissionNeeded &&
//         !(await Permission.microphone.isGranted)) {
//       await requestMicrophonePermission(); // Try requesting again
//       if (!(state is HearAIReadyToRecord)) return; // If still not ready, exit
//     }
//     if (state is HearAIRecording) return; // Already recording

//     try {
//       final Directory tempDir = await getTemporaryDirectory();
//       // Using opus as it's generally efficient and well-supported.
//       // Ensure Gemini supports opus, or use AAC/FLAC/WAV.
//       // Let's stick to your 'audio/opus' which implies opus encoder.
//       _currentRecordingPath = "${tempDir.path}/hear_ai_chunk.opus";

//       await _audioRecorder.start(
//         const RecordConfig(
//           encoder: AudioEncoder.opus,
//         ), // You used opus, stick with it if it worked
//         path: _currentRecordingPath!,
//       );
//       emit(HearAIRecording());
//       print("HearAICubit: Recording started to $_currentRecordingPath");
//     } catch (e) {
//       print("HearAICubit: Error starting recording - $e");
//       emit(HearAIError("Failed to start recording: ${e.toString()}"));
//     }
//   }

//   Future<void> stopAndProcessRecording() async {
//     if (!(state is HearAIRecording)) return; // Not recording

//     try {
//       final String? path = await _audioRecorder.stop();
//       print("HearAICubit: Recording stopped. File at: $path");

//       if (path != null) {
//         final File audioFile = File(path);
//         if (await audioFile.exists()) {
//           final Uint8List fileBytes = await audioFile.readAsBytes();
//           await audioFile.delete(); // Clean up temp file
//           print(
//             "HearAICubit: Audio file read (${fileBytes.length} bytes), deleted. Processing...",
//           );

//           emit(HearAIProcessing());
//           await _processAudioWithGemini(fileBytes);
//         } else {
//           throw Exception("Recorded audio file not found at $path");
//         }
//       } else {
//         throw Exception("Stopping recording did not return a file path.");
//       }
//     } catch (e) {
//       print("HearAICubit: Error stopping/processing recording - $e");
//       emit(HearAIError("Processing failed: ${e.toString()}"));
//       // Optionally, revert to HearAIReadyToRecord if appropriate
//       if (await Permission.microphone.isGranted) {
//         emit(HearAIReadyToRecord());
//       } else {
//         emit(
//           const HearAIPermissionNeeded(
//             "Microphone permission might be needed.",
//           ),
//         );
//       }
//     }
//   }

//   Future<void> _processAudioWithGemini(Uint8List audioBytes) async {
//     // Your existing _processAudioWithGemini logic, but emitting states
//     // const String mimeType = "audio/opus"; // As you used opus encoder
//     // For Gemini, "audio/ogg" (if opus is in ogg container) or a more generic one might be safer
//     // Let's try with a common one Gemini lists, ensure your recording matches or can be converted/identified.
//     // The record package with AudioEncoder.opus on Android/iOS often produces .opus or .ogg
//     // If your file is .opus, MIME type 'audio/opus' or 'audio/ogg;codecs=opus'
//     const String mimeType =
//         "audio/opus"; // Stick to what you tested if it worked!

//     try {
//       final DataPart audioDataPart = DataPart(mimeType, audioBytes);
//       final String soundCategories = [
//         /* ... your categories list ... */
//       ].join(", ");
//       final TextPart promptPart = TextPart(/* ... your detailed prompt ... */);

//       print("HearAICubit: Sending audio to Gemini...");
//       final GenerateContentResponse response = await _model.generateContent([
//         Content.multi([promptPart, audioDataPart]),
//       ]);

//       if (isClosed) return; // Check if cubit was closed during async operation

//       if (response.text != null) {
//         String rawResponseText = response.text!;
//         String eventType = "UNKNOWN";
//         String transcription = "N/A";
//         String details = "";

//         final List<String> lines = rawResponseText.split('\n');
//         for (String line in lines) {
//           if (line.startsWith("EVENT_TYPE:")) {
//             eventType = line.substring("EVENT_TYPE:".length).trim();
//           } else if (line.startsWith("TRANSCRIPTION:")) {
//             transcription = line.substring("TRANSCRIPTION:".length).trim();
//           } else if (line.startsWith("DETAILS:")) {
//             details = line.substring("DETAILS:".length).trim();
//           }
//         }
//         print(
//           "HearAICubit: Processed - EventType='$eventType', Transcription='$transcription', Details='$details'",
//         );
//         emit(
//           HearAISuccess(
//             transcription: transcription,
//             eventType: eventType,
//             details: details,
//           ),
//         );
//       } else {
//         throw Exception("No response text from AI.");
//       }
//     } catch (e) {
//       print("HearAICubit: Error processing with Gemini - $e");
//       if (!isClosed) {
//         emit(HearAIError("AI processing failed: ${e.toString()}"));
//       }
//     }
//   }

//   @override
//   Future<void> close() {
//     _audioRecorder.dispose();
//     print("HearAICubit disposed, audio recorder disposed.");
//     return super.close();
//   }
// }
