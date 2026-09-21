import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import '../data/description_templates.dart';
import '../data/price_reference.dart';

class GeneratedListing {
  final String category;
  final String titleEnglish;
  final String descriptionEnglish;
  final String descriptionHindi;

  GeneratedListing({
    required this.category,
    required this.titleEnglish,
    required this.descriptionEnglish,
    required this.descriptionHindi,
  });
}

/// "Multilingual Auto-Cataloger" — today's version.
///
/// Real, working pieces:
///   1. Category / material / color are extracted from the artisan's
///      transcribed voice note via keyword matching.
///   2. An English description is assembled from a small set of
///      SEO-oriented templates (stand-in for an LLM call — swap in
///      Claude/GPT/IndicTrans2 later without touching the rest of the app).
///   3. The English text is translated to Hindi using Google ML Kit's
///      on-device translator, which is free and works offline once the
///      language model is downloaded (see README).
class DescriptionService {
  static Future<GeneratedListing> generate(String transcript) async {
    final lower = transcript.toLowerCase();

    final category = _detectCategory(lower);
    final material = _detectFromList(lower, knownMaterials) ?? 'traditional materials';
    final color = _detectFromList(lower, knownColors) ?? 'richly detailed';
    final productName = categoryDisplayName[category] ?? categoryDisplayName['default']!;

    final template = englishTemplates[DateTime.now().millisecond % englishTemplates.length];
    final descriptionEnglish = template
        .replaceAll('{material}', material)
        .replaceAll('{color}', color)
        .replaceAll('{product}', productName.toLowerCase());

    final titleEnglish = '$color $productName ($material)'
        .replaceAll('richly detailed ', '')
        .trim();

    final descriptionHindi = await _translateToHindi(descriptionEnglish, category, color, productName, material);

    return GeneratedListing(
      category: category,
      titleEnglish: _capitalize(titleEnglish),
      descriptionEnglish: descriptionEnglish,
      descriptionHindi: descriptionHindi,
    );
  }

  static String _detectCategory(String lower) {
    for (final entry in categoryKeywords.entries) {
      for (final kw in entry.value) {
        if (lower.contains(kw.toLowerCase())) return entry.key;
      }
    }
    return 'default';
  }

  static String? _detectFromList(String lower, List<String> options) {
    for (final o in options) {
      if (lower.contains(o.toLowerCase())) return o;
    }
    return null;
  }

  static Future<String> _translateToHindi(
    String english,
    String category,
    String color,
    String productName,
    String material,
  ) async {
    OnDeviceTranslator? translator;
    try {
      translator = OnDeviceTranslator(
        sourceLanguage: TranslateLanguage.english,
        targetLanguage: TranslateLanguage.hindi,
      );
      final result = await translator.translateText(english);
      return result;
    } catch (_) {
      // Model not downloaded yet, or ML Kit unavailable on this device —
      // fall back to a hardcoded Hindi template so the demo never breaks.
      final fallback = hindiFallbackTemplates.first
          .replaceAll('{material}', material)
          .replaceAll('{color}', color)
          .replaceAll('{product}', productName);
      return fallback;
    } finally {
      translator?.close();
    }
  }

  static String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

/// Call this once (e.g. from a settings screen or on app start with
/// internet available) to download the Hindi<->English model so
/// on-device translation works offline during the live demo.
Future<void> predownloadHindiModel() async {
  final manager = OnDeviceTranslatorModelManager();
  await manager.downloadModel(TranslateLanguage.hindi.bcpCode);
  await manager.downloadModel(TranslateLanguage.english.bcpCode);
}
