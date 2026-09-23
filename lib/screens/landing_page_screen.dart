import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../data/listing_store.dart';
import '../models/product_listing.dart';
import '../services/groq_service.dart';
import '../theme/app_theme.dart';
import '../services/localization_service.dart';

class LandingPageScreen extends StatelessWidget {
  final String imagePath;
  final String rawTranscript;
  final GroqGeneratedListing generated;

  const LandingPageScreen({super.key, required this.imagePath, required this.rawTranscript, required this.generated});

  Future<void> _share(BuildContext context) async {
    final text = '''${generated.title}\n${generated.tagline}\n\n${generated.productStory}\n\nCultural roots\n${generated.culturalStory}\n\nMaterials\n${generated.materials}\n\nCraft process\n${generated.craftProcess}\n\nWhy it is special\n${generated.whySpecial}\n\n${generated.artisanNote}\n\nCreated with Karigar Setu.''';
    await Share.shareXFiles([XFile(imagePath)], text: text, subject: generated.title);
  }

  void _save(BuildContext context) {
    final listing = ProductListing(
      imagePath: imagePath,
      rawTranscript: rawTranscript,
      category: 'craft',
      titleEnglish: generated.title,
      tagline: generated.tagline,
      descriptionEnglish: generated.productStory,
      descriptionHindi: generated.productStory,
      culturalStory: generated.culturalStory,
      materials: generated.materials,
      craftProcess: generated.craftProcess,
      whySpecial: generated.whySpecial,
      artisanNote: generated.artisanNote,
      suggestedPriceLow: 0,
      suggestedPriceHigh: 0,
    );
    ListingStore.instance.add(listing);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: LText('Product page saved to your Karigar Setu shop.')));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFFF7F0E7),
        appBar: AppBar(title: const LText('Your Product Page'), actions: [IconButton(onPressed: () => _share(context), icon: const Icon(Icons.share_rounded))]),
        body: ListView(
          padding: EdgeInsets.zero,
          children: [
            Image.file(File(imagePath), height: 310, width: double.infinity, fit: BoxFit.cover),
            Container(
              transform: Matrix4.translationValues(0, -22, 0),
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 34),
              decoration: const BoxDecoration(color: Color(0xFFFFFCF7), borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _pill('INDIAN CRAFT • HANDMADE'),
                const SizedBox(height: 14),
                LText(generated.title, style: const TextStyle(fontSize: 29, height: 1.08, fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                LText(generated.tagline, style: const TextStyle(fontSize: 16, color: AppColors.terracottaDark, fontWeight: FontWeight.w600, height: 1.4)),
                const SizedBox(height: 24),
                _section('The story', generated.productStory, Icons.auto_stories_rounded),
                _section('Rooted in India', generated.culturalStory, Icons.temple_hindu_rounded),
                _section('Materials', generated.materials, Icons.handyman_rounded),
                _section('Made by hand', generated.craftProcess, Icons.design_services_rounded),
                _section('Why it is special', generated.whySpecial, Icons.favorite_border_rounded),
                Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: AppColors.cream, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.gold.withOpacity(.35))), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Icon(Icons.format_quote_rounded, color: AppColors.gold), const SizedBox(width: 10), Expanded(child: LText(generated.artisanNote, style: const TextStyle(fontStyle: FontStyle.italic, height: 1.45)))])),
                const SizedBox(height: 24),
                Row(children: [Expanded(child: ElevatedButton.icon(onPressed: () => _share(context), icon: const Icon(Icons.share_rounded), label: const LText('Share Page'))), const SizedBox(width: 10), IconButton.filled(onPressed: () => _save(context), icon: const Icon(Icons.bookmark_add_outlined), tooltip: 'Save')]),
                const SizedBox(height: 14),
                Center(child: LText('Powered by Karigar Setu • AI-assisted storytelling', style: TextStyle(fontSize: 11, color: Colors.black.withOpacity(.45))),),
              ]),
            ),
          ],
        ),
      );

  Widget _pill(String text) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: AppColors.terracotta.withOpacity(.1), borderRadius: BorderRadius.circular(30)), child: const LText('INDIAN CRAFT • HANDMADE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: .7, color: AppColors.terracottaDark)));

  Widget _section(String title, String body, IconData icon) => Padding(padding: const EdgeInsets.only(bottom: 22), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Icon(icon, size: 19, color: AppColors.indigo), const SizedBox(width: 8), LText(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800))]), const SizedBox(height: 7), LText(body, style: const TextStyle(fontSize: 14.5, height: 1.55))]));
}
