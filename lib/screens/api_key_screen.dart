import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import '../services/localization_service.dart';

class ApiKeyScreen extends StatefulWidget {
  const ApiKeyScreen({super.key});

  @override
  State<ApiKeyScreen> createState() => _ApiKeyScreenState();
}

class _ApiKeyScreenState extends State<ApiKeyScreen> {
  final _controller = TextEditingController();
  bool _obscure = true;

  void _continue() {
    final key = _controller.text.trim();
    if (key.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: LText('Please enter your Groq API key to continue.')),
      );
      return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => HomeScreen(groqApiKey: key)),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 48, 24, 32),
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: AppColors.terracotta.withOpacity(.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome, color: AppColors.terracotta, size: 38),
            ),
            const SizedBox(height: 24),
            const LText('Welcome to Karigar Setu', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            LText(
              'Bring your own Groq API key. It stays in this app session and is used only when you generate a product page.',
              style: TextStyle(fontSize: 15, height: 1.5, color: Colors.black.withOpacity(.65)),
            ),
            const SizedBox(height: 28),
            TextField(
              controller: _controller,
              obscureText: _obscure,
              autocorrect: false,
              enableSuggestions: false,
              decoration: InputDecoration(
                labelText: L10n.t('Groq API key'),
                hintText: L10n.t('gsk_…'),
                prefixIcon: const Icon(Icons.key_rounded),
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _obscure = !_obscure),
                  icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                ),
              ),
              onSubmitted: (_) => _continue(),
            ),
            const SizedBox(height: 12),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.lock_outline, color: AppColors.indigo),
                    SizedBox(width: 12),
                    Expanded(child: LText('Prototype mode: your key is not written into the APK or committed to GitHub.')),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: _continue,
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const LText('Enter Karigar Setu'),
            ),
            const SizedBox(height: 18),
            LText(
              'You can create a Groq key from the Groq Console. Keep it private and do not paste it into GitHub.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.black.withOpacity(.5)),
            ),
          ],
        ),
      ),
    );
  }
}
