import 'dart:io';
import 'package:flutter/material.dart';
import '../data/listing_store.dart';
import '../models/product_listing.dart';
import '../theme/app_theme.dart';
import 'capture_screen.dart';
import 'api_key_screen.dart';
import '../services/localization_service.dart';

class HomeScreen extends StatelessWidget {
  final String groqApiKey;
  const HomeScreen({super.key, required this.groqApiKey});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const LText('Karigar Setu'),
        actions: [
          IconButton(
            tooltip: L10n.t('Use another Groq key'),
            icon: const Icon(Icons.key_rounded),
            onPressed: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const ApiKeyScreen()),
            ),
          ),
        ],
      ),
      body: ValueListenableBuilder<List<ProductListing>>(
        valueListenable: ListingStore.instance.listings,
        builder: (context, listings, _) {
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(listings.length)),
              if (listings.isEmpty)
                SliverToBoxAdapter(child: _buildEmptyState())
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => _ListingCard(listing: listings[listings.length - 1 - i]),
                      childCount: listings.length,
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
        width: double.infinity,
        height: 64,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.add_a_photo_rounded, size: 26),
            label: const LText('Create a Product Page'),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => CaptureScreen(groqApiKey: groqApiKey, outputLanguage: AppLocale.current.name)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(int count) => Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        decoration: const BoxDecoration(
          color: AppColors.terracotta,
          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28)),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LText('Namaste, artisan 👋', style: TextStyle(color: Colors.white70, fontSize: 15)),
            SizedBox(height: 4),
            LText('Turn your craft into a story', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
            SizedBox(height: 10),
            LText('Photo + your voice → an AI-powered product landing page you can share.', style: TextStyle(color: Colors.white, height: 1.4)),
          ],
        ),
      );

  Widget _buildEmptyState() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Column(
          children: [
            const Icon(Icons.storefront_rounded, size: 72, color: AppColors.terracottaDark),
            const SizedBox(height: 16),
            const LText('Your first product page starts here', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            LText('Take a photo, describe the craft in your own voice, and let Karigar Setu create a beautiful story around it.', textAlign: TextAlign.center, style: TextStyle(color: Colors.black.withOpacity(.6), height: 1.4)),
          ],
        ),
      );
}

class _ListingCard extends StatelessWidget {
  final ProductListing listing;
  const _ListingCard({required this.listing});

  @override
  Widget build(BuildContext context) => Card(
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            Image.file(File(listing.imagePath), width: 96, height: 96, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(width: 96, height: 96, color: Colors.grey.shade200, child: const Icon(Icons.image_not_supported_outlined))),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(listing.titleEnglish, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 5),
                  Text(listing.tagline, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: Colors.black.withOpacity(.55))),
                  const SizedBox(height: 5),
                  const Row(children: [Icon(Icons.public, size: 14, color: AppColors.success), SizedBox(width: 4), LText('Shareable product page', style: TextStyle(fontSize: 12, color: AppColors.success))]),
                ]),
              ),
            ),
          ],
        ),
      );
}
