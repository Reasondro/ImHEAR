import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:komunika/app/themes/app_colors.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:komunika/core/extensions/snackbar_extension.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

class HearAIScreen extends StatefulWidget {
  const HearAIScreen({super.key});

  @override
  State<HearAIScreen> createState() => _HearAIScreenState();
}

class _HearAIScreenState extends State<HearAIScreen> {
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  String? _audioPath;
  List<int>? _recordedAudioBytes;

  // ? ai stuffs
  String _transcribedText = "";
  String _analysisCategory = "";
  bool _isProcessingAI = false;

  Future<void> _processAudioWithGemini() async {
    if (_recordedAudioBytes == null || _recordedAudioBytes!.isEmpty) {
      print("No recorded audio to process.".toUpperCase());
      if (mounted) {
        context.customShowErrorSnackBar("Please record audio first");
      }
      return;
    }
    setState(() {
      _isProcessingAI = true;
      _transcribedText = "";
      _analysisCategory = "";
    });

    const String mimeType = "audio/opus";
    final String? apiKey = dotenv.env["GEMINI_API_KEY"];

    if (apiKey == null) {
      print("API Key not found!".toUpperCase());

      if (mounted) {
        setState(() {
          _isProcessingAI = false;
          _transcribedText = "Error: API Key missing";
        });
      }
      return;
    }
    final GenerativeModel model = GenerativeModel(
      model: "gemini-2.0-flash-lite",
      apiKey: apiKey,
    );

    try {
      final DataPart audioDataPart = DataPart(
        mimeType,
        Uint8List.fromList(_recordedAudioBytes!),
      );
      const String categories =
          "NEUTRAL, URGENT_QUESTION, URGENT_STATEMENT, HAPPY_EXCLAMATION, GENERAL_QUESTION, ANNOYED_STATEMENT";
      final TextPart promptPart = TextPart(
        "Transcribe the following audio. "
        "Then, analyze the speaker's likely intent and emotional tone. "
        "Classify the overall tone into ONE of these categories: $categories. "
        "Format your response EXACTLY like this: "
        "Transcription: [The transcribed text here] "
        "ToneCategory: [ONE_OF_THE_CATEGORIES_ABOVE]",
      );

      print("Sending audio to Gemini for processing ...".toUpperCase());
      final GenerateContentResponse response = await model.generateContent([
        Content.multi([promptPart, audioDataPart]), //? order matters
      ]);
      print("Gemini Raw Response: ${response.text}");

      if (response.text != null) {
        // ? start basic parsing
        String rawResponseText = response.text!;
        String transcription =
            "Could not parse transcription"; //? default value
        String tone = "Could not parse tone"; //? default value

        final RegExp transRegExp = RegExp(
          r"Transcription:\s*(.*?)(\s*ToneCategory:|$)",
        );
        final RegExp toneRegExp = RegExp(r"ToneCategory:\s*(\w+)");
        final RegExpMatch? transMatch = transRegExp.firstMatch(rawResponseText);
        if (transMatch != null && transMatch.group(1) != null) {
          transcription = transMatch.group(1)!.trim();
        }

        final RegExpMatch? toneMatch = toneRegExp.firstMatch(rawResponseText);

        if (toneMatch != null && toneMatch.group(1) != null) {
          tone = toneMatch.group(1)!.trim();
        }
        // ? end basic parsing

        if (mounted) {
          setState(() {
            _transcribedText = transcription;
            _analysisCategory = tone;
            _isProcessingAI = false;
          });
          print(
            "Processed: Transcription='$_transcribedText', Tone='$_analysisCategory'",
          );

          // TODO LATER: Based on _analysisCategory, send command to ESP32
          // e.g., if (_analysisCategory == "URGENT_STATEMENT") {
          //   context.read<CustomBluetoothService>().sendCommand("VIB_URGENT");
          // }
        }
      } else {
        if (mounted) {
          setState(() {
            _transcribedText = "No response text from AI";
            _isProcessingAI = false;
          });
        }
      }
    } catch (e) {
      print("Error processing audio with Gemini $e");

      if (mounted) {
        setState(() {
          _transcribedText = "Error $e";
          _isProcessingAI = false;
        });
      }
    }
  }

  void disposeAudioRecorder() {
    _audioRecorder.dispose();
  }

  Future<bool> _requestMicrophonePermission() async {
    PermissionStatus status = await Permission.microphone.request();

    if (status.isGranted) {
      return true;
    } else {
      print("Microphone permission denied");
      if (status.isPermanentlyDenied) {
        openAppSettings();
      }
      return false;
    }
  }

  Future<void> startRecording() async {
    if (_isRecording) return;
    bool hasPermission = await _requestMicrophonePermission();
    if (!hasPermission) {
      context.customShowErrorSnackBar("Microphone permission is required.");
      return;
    }
    try {
      // ? get temp directory
      final Directory tempDir = await getTemporaryDirectory();
      final String filePath = "${tempDir.path}/temp_audio_chunk.ogg";

      // ? start recording
      await _audioRecorder.start(
        const RecordConfig(encoder: AudioEncoder.opus),
        path: filePath,
      );

      setState(() {
        _isRecording = true;
        _audioPath = filePath;
        _recordedAudioBytes = null;
        print("Recording started: $filePath");
      });
    } catch (e) {
      print("Error starting recording: $e");
      setState(() {
        _isRecording = false;
      });
    }
  }

  Future<void> stopRecordingAndGetFile() async {
    if (!_isRecording) return;

    try {
      final String? path = await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
        _audioPath = path; //? update path just in case it chagne
        print("Recording stopped. File saved at $path".toUpperCase());
      });

      if (path != null) {
        final File audioFile = File(path);
        if (await audioFile.exists()) {
          final Uint8List fileBytes = await audioFile.readAsBytes();

          setState(() {
            _recordedAudioBytes = fileBytes;
          });
          print(
            "Audio file read into bytes. Length: ${fileBytes.length}"
                .toUpperCase(),
          );

          // ? now _recordedaudiobytes is ready to sent to gemini
          // ? might want to delete the temp file after processing
          await audioFile.delete();
        } else {
          print("Error: Recorded audio file not found at $path".toUpperCase());
          setState(() => _recordedAudioBytes = null);
        }
      } else {
        print("Error: Stopping recording, didn't return a path".toUpperCase());
        setState(() => _recordedAudioBytes = null);
      }
    } catch (e) {
      print("Error stopping recording: $e".toUpperCase());
      setState(() {
        _isRecording = false;
        _recordedAudioBytes = null;
      });
    }
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        // child: SingleChildScrollView(
        child:
        // ListView(
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 150),
            if (_isRecording)
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.8, end: 1.2),
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeInOut, // Added a curve
                builder: (context, scale, child) {
                  return Transform.scale(scale: scale, child: child);
                },
                child: const Column(
                  children: [
                    Icon(Icons.mic, color: Colors.red, size: 64.0),
                    SizedBox(height: 8),
                    Text(
                      "Recording...",
                      style: TextStyle(fontSize: 18, color: Colors.red),
                    ),
                  ],
                ),
              )
            else
              const Column(
                children: [
                  Icon(Icons.mic_none, color: Colors.grey, size: 64.0),
                  SizedBox(height: 8),
                  Text(
                    "Tap to start recording",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _isRecording
                        ? Colors.redAccent
                        : Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
                textStyle: const TextStyle(fontSize: 16),
              ),
              onPressed: () {
                if (_isRecording) {
                  stopRecordingAndGetFile();
                } else {
                  startRecording();
                }
              },
              child: Text(
                _isRecording ? "Stop Recording" : "Start Recording",
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),

            // ? process with Gemini AI
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.bittersweet,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
                textStyle: const TextStyle(fontSize: 16),
              ),
              onPressed:
                  (_isRecording ||
                          _isProcessingAI ||
                          _recordedAudioBytes == null)
                      ? null //?  disabled if recording, processing, or no audio bytes
                      : _processAudioWithGemini,
              child:
                  _isProcessingAI
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.columbiaBlue,
                          ),
                        ),
                      )
                      : const Text(
                        "Process with HearAI",
                        style: TextStyle(color: Colors.white),
                      ),
            ),
            const SizedBox(height: 20),

            //? display audio path and bytes (for debugging/info)
            if (_audioPath != null && !_isRecording)
              Padding(
                padding: const EdgeInsets.only(top: 10.0, bottom: 5.0),
                child: Text(
                  "Last recording path (temp):\n$_audioPath",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ),
            if (_recordedAudioBytes != null &&
                !_isRecording &&
                !_isProcessingAI)
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Text(
                  "Audio Bytes Ready: ${_recordedAudioBytes!.length} bytes",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 10, color: Colors.blueGrey),
                ),
              ),

            //? display AI Response
            if (_transcribedText.isNotEmpty && !_isProcessingAI) ...[
              const SizedBox(height: 10),
              Card(
                //? added Card for better visual separation
                elevation: 2.0,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "HearAI Analysis:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Transcription: $_transcribedText",
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Tone Category: $_analysisCategory",
                        style: const TextStyle(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ] else if (_isProcessingAI) ...[
              //? default  message while processing
              const SizedBox(height: 20),
              const Text(
                "HearAI is thinking...",
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            ],
          ],
        ),
        // ),
      ),
    );
  }
}
