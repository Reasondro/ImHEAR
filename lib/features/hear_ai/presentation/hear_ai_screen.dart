import 'package:flutter/material.dart';
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_isRecording)
              const Column(
                children: [
                  Icon(Icons.mic, color: Colors.red, size: 64.0),
                  SizedBox(height: 8),
                  Text(
                    "Recording...",
                    style: TextStyle(fontSize: 18, color: Colors.red),
                  ),
                ],
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
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _isRecording
                        ? Colors.redAccent
                        : Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 20,
                ),
                textStyle: const TextStyle(fontSize: 18),
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
            if (_audioPath != null && !_isRecording)
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Text(
                  "Last recording saved (and deleted after processing):\n$_audioPath",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: Colors.green),
                ),
              ),
            if (_recordedAudioBytes != null && !_isRecording)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  "Processed Bytes: ${_recordedAudioBytes!.length} bytes",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: Colors.blue),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
