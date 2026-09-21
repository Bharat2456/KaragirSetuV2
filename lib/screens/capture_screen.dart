import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../theme/app_theme.dart';
import 'processing_screen.dart';

class CaptureScreen extends StatefulWidget {
  final String groqApiKey;
  const CaptureScreen({super.key, required this.groqApiKey});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  final ImagePicker _picker = ImagePicker();
  final stt.SpeechToText _speech = stt.SpeechToText();
  File? _image;
  String _transcript = '';
  bool _speechReady = false;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    _speechReady = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          if (mounted) setState(() => _isListening = false);
        }
      },
      onError: (_) {
        if (mounted) setState(() => _isListening = false);
      },
    );
    if (mounted) setState(() {});
  }

  Future<void> _takePhoto() async {
    final photo = await _picker.pickImage(source: ImageSource.camera, imageQuality: 88);
    if (photo != null) setState(() => _image = File(photo.path));
  }

  Future<void> _toggleListening() async {
    if (!_speechReady) return;
    if (_isListening) {
      await _speech.stop();
      if (mounted) setState(() => _isListening = false);
      return;
    }
    setState(() => _isListening = true);
    await _speech.listen(onResult: (result) {
      if (mounted) setState(() => _transcript = result.recognizedWords);
    });
  }

  bool get _canGenerate => _image != null && _transcript.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Create Product Page')),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text('Make your craft discoverable', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text('No forms. Just show us the product and tell its story in your own voice.', style: TextStyle(color: Colors.black.withOpacity(.6), height: 1.4)),
            const SizedBox(height: 24),
            _sectionLabel('1. Photograph your product'),
            const SizedBox(height: 10),
            _buildPhotoPicker(),
            const SizedBox(height: 28),
            _sectionLabel('2. Tell its story in your own voice'),
            const SizedBox(height: 10),
            _buildVoiceRecorder(),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Generate Product Page'),
              onPressed: _canGenerate
                  ? () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProcessingScreen(imagePath: _image!.path, transcript: _transcript.trim(), groqApiKey: widget.groqApiKey)))
                  : null,
            ),
            const SizedBox(height: 10),
            Text('Your Groq key is used only for this AI generation request.', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: Colors.black.withOpacity(.45))),
          ],
        ),
      );

  Widget _sectionLabel(String text) => Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700));

  Widget _buildPhotoPicker() => GestureDetector(
        onTap: _takePhoto,
        child: Container(
          height: 220,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.terracotta.withOpacity(.4), width: 2)),
          clipBehavior: Clip.antiAlias,
          child: _image == null
              ? const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.camera_alt_rounded, size: 48, color: AppColors.terracotta), SizedBox(height: 10), Text('Tap to take a photo', style: TextStyle(color: AppColors.terracottaDark, fontWeight: FontWeight.w600))])
              : Stack(fit: StackFit.expand, children: [Image.file(_image!, fit: BoxFit.cover), Positioned(right: 8, bottom: 8, child: CircleAvatar(backgroundColor: Colors.black54, child: IconButton(icon: const Icon(Icons.refresh, color: Colors.white), onPressed: _takePhoto)))],),
        ),
      );

  Widget _buildVoiceRecorder() => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Column(children: [
          GestureDetector(
            onTap: _speechReady ? _toggleListening : null,
            child: CircleAvatar(radius: 38, backgroundColor: _isListening ? AppColors.terracotta : AppColors.indigo, child: Icon(_isListening ? Icons.stop_rounded : Icons.mic_rounded, color: Colors.white, size: 34)),
          ),
          const SizedBox(height: 10),
          Text(_isListening ? 'Listening… tap to stop' : (_speechReady ? 'Tap and speak naturally — any supported language' : 'Initializing microphone…'), textAlign: TextAlign.center, style: TextStyle(color: Colors.black.withOpacity(.6), fontSize: 13)),
          if (_transcript.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.cream, borderRadius: BorderRadius.circular(12)), child: Text('“$_transcript”', style: const TextStyle(fontStyle: FontStyle.italic))),
          ],
        ]),
      );
}
