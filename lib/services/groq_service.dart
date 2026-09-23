import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class GroqGeneratedListing {
  final String title;
  final String tagline;
  final String productStory;
  final String culturalStory;
  final String materials;
  final String craftProcess;
  final String whySpecial;
  final String artisanNote;

  const GroqGeneratedListing({
    required this.title,
    required this.tagline,
    required this.productStory,
    required this.culturalStory,
    required this.materials,
    required this.craftProcess,
    required this.whySpecial,
    required this.artisanNote,
  });

  factory GroqGeneratedListing.fromJson(Map<String, dynamic> json) {
    String value(String key, String fallback) {
      final v = json[key];
      return v is String && v.trim().isNotEmpty ? v.trim() : fallback;
    }

    return GroqGeneratedListing(
      title: value('title', 'Handcrafted Indian Heritage Piece'),
      tagline: value('tagline', 'A handmade story from India'),
      productStory: value('product_story', 'A unique handmade product created with care by an Indian artisan.'),
      culturalStory: value('cultural_story', 'This piece reflects the living craft traditions of India and the knowledge passed from artisan to artisan.'),
      materials: value('materials', 'Traditional craft materials'),
      craftProcess: value('craft_process', 'Handmade using traditional techniques.'),
      whySpecial: value('why_special', 'Every handmade piece carries the touch and character of its maker.'),
      artisanNote: value('artisan_note', 'Made by hand, with patience, skill and pride.'),
    );
  }
}

class GroqService {
  static const _endpoint = 'https://api.groq.com/openai/v1/chat/completions';
  // Current Groq multimodal model. The app uses the user's own API key.
  static const _model = 'qwen/qwen3.6-27b';

  static Future<GroqGeneratedListing> generateListing({
    required String apiKey,
    required String imagePath,
    required String artisanDescription,
    String outputLanguage = 'English',
    int retryCount = 0,
  }) async {
    final bytes = await File(imagePath).readAsBytes();
    final base64Image = base64Encode(bytes);
    final mime = _mimeType(imagePath);

    final systemPrompt = '''You are Karigar Setu, an AI catalog assistant for Indian artisans.
Create a beautiful, respectful product landing page from the product photo and the artisan's own description.
The final output MUST be written entirely in $outputLanguage. Preserve the artisan's meaning; do not translate names, measurements or proper nouns unnecessarily.
Your writing should make the product appealing to a buyer while preserving Indian cultural context.
Never invent a specific state, tribe, community, GI tag, festival, historical claim, or traditional origin unless the artisan description or visible evidence supports it. If the exact regional origin is unknown, say it reflects Indian craft traditions generally.
Do not call the artisan poor, marginalized, backward, or use charity language. Center skill, dignity, craftsmanship and cultural heritage.
Return exactly 8 plain-text lines using these labels, in this exact order:
TITLE:
TAGLINE:
STORY:
CULTURE:
MATERIALS:
CRAFT:
SPECIAL:
ARTISAN:
Keep every line concise. TITLE and TAGLINE max 12 words; every other line max 32 words. Use no JSON, markdown, bullets, or extra lines. Never leave a label empty.''';

    final userText = '''Create the landing page copy for this product.

Artisan's description (keep its meaning even if it is in an Indian language):
$artisanDescription

Use the image to understand the product, visible materials, colors and craft details. Be honest about uncertainty.''';

    final response = await http.post(
      Uri.parse(_endpoint),
      headers: {
        'Authorization': 'Bearer ${apiKey.trim()}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': _model,
        'temperature': 0.35,
        'max_tokens': 360,
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          {
            'role': 'user',
            'content': [
              {'type': 'text', 'text': userText},
              {
                'type': 'image_url',
                'image_url': {'url': 'data:$mime;base64,$base64Image'},
              },
            ],
          },
        ],
      }),
    );

    if (response.statusCode == 401) {
      throw Exception('The Groq API key was rejected. Please check the key and try again.');
    }
    if (response.statusCode == 429) {
      if (retryCount >= 1) {
        throw Exception('Groq is temporarily rate-limited. Please wait about a minute and try again.');
      }
      // Groq's on-demand tier can briefly hit the per-minute output-token limit.
      await Future<void>.delayed(const Duration(seconds: 45));
      return generateListing(
        apiKey: apiKey,
        imagePath: imagePath,
        artisanDescription: artisanDescription,
        outputLanguage: outputLanguage,
        retryCount: retryCount + 1,
      );
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      String detail = 'Groq returned HTTP ${response.statusCode}.';
      try {
        final body = jsonDecode(response.body);
        final message = body['error']?['message'];
        if (message is String && message.isNotEmpty) detail = message;
      } catch (_) {}
      throw Exception(detail);
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final content = decoded['choices']?[0]?['message']?['content'];
    if (content is! String || content.trim().isEmpty) {
      throw Exception('Groq returned an empty response. Please try again.');
    }

    final parsed = _parseModelContent(content);
    if (parsed == null) {
      throw Exception('The AI response could not be understood. Please try again.');
    }
    return GroqGeneratedListing.fromJson(parsed);
  }

  /// Parse model output defensively. Models can occasionally add markdown,
  /// put multiple fields on one line, or return plain prose even when asked
  /// for labels. The prototype should still produce a usable page.
  static Map<String, dynamic>? _parseModelContent(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return null;

    // First try JSON, including JSON embedded in markdown/code fences.
    final jsonStart = value.indexOf('{');
    final jsonEnd = value.lastIndexOf('}');
    if (jsonStart >= 0 && jsonEnd > jsonStart) {
      try {
        final decoded = jsonDecode(value.substring(jsonStart, jsonEnd + 1));
        if (decoded is Map<String, dynamic>) return decoded;
      } catch (_) {
        // Continue with labelled/plain-text parsing.
      }
    }

    const labels = <String, String>{
      'TITLE': 'title',
      'TAGLINE': 'tagline',
      'STORY': 'product_story',
      'CULTURE': 'cultural_story',
      'MATERIALS': 'materials',
      'CRAFT': 'craft_process',
      'SPECIAL': 'why_special',
      'ARTISAN': 'artisan_note',
    };

    final result = <String, dynamic>{};

    // Handle labels whether they are on separate lines, bolded, bulletized,
    // or accidentally placed together. A non-greedy capture stops at the next
    // known label instead of depending on newline formatting.
    final re = RegExp(
      r'(?:^|\n|\r)\s*(?:[-*•]\s*)?(?:\*\*)?('
      r'TITLE|TAGLINE|STORY|CULTURE|MATERIALS|CRAFT|SPECIAL|ARTISAN'
      r')(?:\*\*)?\s*[:\-]\s*(.*?)(?=\s*(?:\n|\r)\s*(?:[-*•]\s*)?(?:\*\*)?(?:'
      r'TITLE|TAGLINE|STORY|CULTURE|MATERIALS|CRAFT|SPECIAL|ARTISAN'
      r')(?:\*\*)?\s*[:\-]|\s*$)',
      caseSensitive: false,
      multiLine: true,
      dotAll: true,
    );

    for (final match in re.allMatches(value)) {
      final label = match.group(1)?.toUpperCase();
      final text = match.group(2)?.trim();
      final key = label == null ? null : labels[label];
      if (key != null && text != null && text.isNotEmpty) {
        result[key] = text.replaceAll(RegExp(r'\s+'), ' ');
      }
    }

    // If enough fields were understood, use them and let the model class
    // provide sensible fallbacks for anything missing.
    if (result.length >= 2) return result;

    // Last-resort fallback: never strand the artisan on an error screen just
    // because the model ignored formatting. Treat its response as the story.
    final clean = value
        .replaceAll(RegExp(r'```[\w-]*'), '')
        .replaceAll('```', '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (clean.isEmpty) return null;

    final sentences = clean.split(RegExp(r'(?<=[.!?])\s+'));
    final title = sentences.isNotEmpty
        ? _shortenWords(sentences.first, 12)
        : 'Handcrafted Indian Heritage Piece';
    final story = _shortenWords(clean, 32);

    return <String, dynamic>{
      'title': title.isEmpty ? 'Handcrafted Indian Heritage Piece' : title,
      'tagline': 'Made by hand, rooted in Indian craft',
      'product_story': story,
      'cultural_story': 'This piece celebrates the living craft traditions of India and the knowledge carried through generations of making.',
      'materials': 'Materials are presented based on the artisan description and visible details in the product image.',
      'craft_process': 'Handcrafted with care, skill and attention to detail.',
      'why_special': 'Every handmade piece carries the character and touch of its maker.',
      'artisan_note': 'Made by hand with patience, skill and pride.',
    };
  }

  static String _shortenWords(String text, int maxWords) {
    final words = text.trim().split(RegExp(r'\s+'));
    if (words.length <= maxWords) return text.trim();
    return '${words.take(maxWords).join(' ')}…';
  }

  static String _mimeType(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }
  static Future<String> generateTextListing({
    required String apiKey,
    required String productName,
    required String category,
    required String details,
    required String materials,
    required String price,
    required String capacity,
    required String days,
    required String outputLanguage,
  }) async {
    final system = '''You are KarigarSetu, an ethical Indian artisan-commerce listing assistant.
Create a buyer-ready product listing using ONLY the facts provided by the artisan. Never invent a location, tribe, community, GI tag, certification, historical claim, material, or cultural origin.
The artisan may write or speak in any language. Understand it without requiring English. Return the final answer entirely in $outputLanguage.
Use these sections: TITLE, TAGLINE, DESCRIPTION, ARTISAN STORY, MATERIALS, MAKING PROCESS, CARE, CUSTOMIZATION, CAPACITY, LEAD TIME.
Keep it warm, clear, respectful and factual. Do not add markdown bullets or commentary.''';
    final user = '''Product name: $productName
Category: $category
Artisan description: $details
Materials: $materials
Price in INR: $price
Production capacity: $capacity units
Lead time: $days days''';
    final response = await http.post(
      Uri.parse(_endpoint),
      headers: {'Authorization':'Bearer ${apiKey.trim()}','Content-Type':'application/json'},
      body: jsonEncode({'model':'llama-3.3-70b-versatile','temperature':0.35,'max_tokens':900,'messages':[{'role':'system','content':system},{'role':'user','content':user}]}),
    ).timeout(const Duration(seconds:45));
    if(response.statusCode==401) throw Exception('The Groq API key was rejected. Please check the key and try again.');
    if(response.statusCode==429) throw Exception('Groq is temporarily rate-limited. Please wait and try again.');
    if(response.statusCode<200||response.statusCode>=300){
      String detail='Groq returned HTTP ${response.statusCode}.';
      try{final body=jsonDecode(response.body);final msg=body['error']?['message'];if(msg is String&&msg.isNotEmpty)detail=msg;}catch(_){}
      throw Exception(detail);
    }
    final decoded=jsonDecode(response.body) as Map<String,dynamic>;
    final content=decoded['choices']?[0]?['message']?['content'];
    if(content is! String||content.trim().isEmpty) throw Exception('Groq returned an empty listing. Please try again.');
    return content.trim();
  }

}
