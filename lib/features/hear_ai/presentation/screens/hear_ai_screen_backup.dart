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

class HearAiScreenBackup extends StatefulWidget {
  const HearAiScreenBackup({super.key});

  @override
  State<HearAiScreenBackup> createState() => _HearAiScreenBackupState();
}

class _HearAiScreenBackupState extends State<HearAiScreenBackup> {
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  String? _audioPath;
  List<int>? _recordedAudioBytes;

  // ? ai stuffs
  String _transcribedText = "";
  String _analysisCategory = "";
  String _eventDetails = "";
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
      _eventDetails = "";
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
      // model: "gemini-2.0-flash", //? for testing
      // model: "gemini-2.5-flash-preview-04-17", // ? for testing
      apiKey: apiKey,
    );

    try {
      final DataPart audioDataPart = DataPart(
        mimeType,
        Uint8List.fromList(_recordedAudioBytes!),
      );

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
        // "SOUND_SIREN", //? this is error prone
        "SOUND_VEHICLE_HORN",
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
      // ? OLD "DETAILS: [If speech, the specific tone/intent words like 'urgent question' or 'happy statement'. If an environmental sound, the name of the sound like 'CAR_HORN' or 'LOUD_IMPACT'. If AMBIENT_NOISE_ONLY, 'Low ambient noise' or similar.]",

      print("Sending audio to Gemini for processing ...".toUpperCase());
      final GenerateContentResponse response = await model.generateContent([
        Content.multi([promptPart, audioDataPart]), //? order matters
      ]);
      print("Gemini Raw Response: ${response.text}");

      if (response.text != null) {
        String rawResponseText = response.text!;
        String eventType = "UNKNOWN";
        String transcription = "N/A";
        String details = "";

        //? split by lines and parse
        final List<String> lines = rawResponseText.split('\n');
        for (String line in lines) {
          if (line.startsWith("EVENT_TYPE:")) {
            eventType = line.substring("EVENT_TYPE:".length).trim();
          } else if (line.startsWith("TRANSCRIPTION:")) {
            transcription = line.substring("TRANSCRIPTION:".length).trim();
          } else if (line.startsWith("DETAILS:")) {
            details = line.substring("DETAILS:".length).trim();
          }
        }

        if (mounted) {
          setState(() {
            //? eventType for vibration logic,
            //?  transcription to display (if not "N/A")
            //? details for additional info or display
            _transcribedText = transcription;

            _analysisCategory = eventType; //? holds SPEECH_ or SOUND_ category
            _eventDetails = details;
            _isProcessingAI = false;
          });

          print(
            "Processed: EventType='$eventType', Transcription='$transcription', Details='$details'",
          );

          // TODO LATER: Based on _analysisCategory, send command to ESP32
          //      // e.g., if (_analysisCategory == "URGENT_STATEMENT") {
          //    //   context.read<CustomBluetoothService>().sendCommand("VIB_URGENT");
          //  // }
          // send a command to ESP32 based on eventType
          // if (eventType == "SOUND_CAR_HORN") {
          //   context.read<CustomBluetoothService>().sendCommand("VIB_CAR_HORN"); // Define this command
          // } else if (eventType == "SPEECH_URGENT_IMPORTANT") {
          //   context.read<CustomBluetoothService>().sendCommand("VIB_URGENT");
          // } // etc.
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
      if (mounted) {
        context.customShowErrorSnackBar("Microphone permission is required.");
      }
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
        child: SingleChildScrollView(
          child:
          // ListView( //? for later use if want to use list view
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 150),
              if (_isRecording)
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.8, end: 1.2),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeInOut,
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
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.blueGrey,
                    ),
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
                          "Sound Category: $_analysisCategory",
                          style: const TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        //? display details if available and not "N/A"
                        if (_eventDetails.isNotEmpty && _eventDetails != "N/A")
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              "Details: $_eventDetails",
                              style: const TextStyle(fontSize: 14),
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
        ),
      ),
    );
  }
}
