import 'package:flutter/material.dart';
import '../services/groq_service.dart';
import '../theme/app_theme.dart';
import 'landing_page_screen.dart';

class ProcessingScreen extends StatefulWidget {
  final String imagePath;
  final String transcript;
  final String groqApiKey;
  const ProcessingScreen({super.key, required this.imagePath, required this.transcript, required this.groqApiKey});

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  String _status = 'Understanding your product photo';
  bool _failed = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    try {
      setState(() => _status = 'Reading the craft details');
      await Future.delayed(const Duration(milliseconds: 400));
      setState(() => _status = 'Combining your voice with the product photo');
      final generated = await GroqService.generateListing(apiKey: widget.groqApiKey, imagePath: widget.imagePath, artisanDescription: widget.transcript);
      if (!mounted) return;
      setState(() => _status = 'Designing your shareable product page');
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => LandingPageScreen(imagePath: widget.imagePath, rawTranscript: widget.transcript, generated: generated)));
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _failed = true;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.indigo,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: _failed ? _errorView() : Column(mainAxisSize: MainAxisSize.min, children: [
              const CircularProgressIndicator(color: Colors.white),
              const SizedBox(height: 28),
              const Text('Karigar Setu AI is crafting your story', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              Text(_status, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 28),
              const Icon(Icons.auto_awesome, color: AppColors.gold, size: 42),
            ]),
          ),
        ),
      );

  Widget _errorView() => Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.error_outline_rounded, color: Colors.white, size: 56),
        const SizedBox(height: 18),
        const Text('We could not generate the page', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        Text(_error ?? 'Unknown error', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, height: 1.4)),
        const SizedBox(height: 24),
        ElevatedButton.icon(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.arrow_back), label: const Text('Try again')),
      ]);
}
