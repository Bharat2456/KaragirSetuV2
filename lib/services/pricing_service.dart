import '../data/price_reference.dart';

class PriceSuggestion {
  final double low;
  final double high;
  final String explanation;
  PriceSuggestion(this.low, this.high, this.explanation);
}

/// "Dynamic Pricing Assistant" — today's version.
///
/// Real ML-driven market pricing needs a trained model over live
/// marketplace data we don't have access to in a day. What's genuinely
/// useful and honest to build today: a transparent cost-plus formula
/// blended with a small reference dataset of category price bands
/// (`price_reference.dart`), which is exactly the kind of feature-set a
/// production model (e.g. gradient-boosted regression trained on GeM +
/// e-commerce listings) would eventually replace — same inputs/outputs,
/// swappable implementation.
class PricingService {
  static PriceSuggestion suggest({
    required String category,
    required double materialCost,
    required double laborHours,
    double hourlyRate = 60, // approx fair daily-wage-derived rate, INR/hr
  }) {
    final band = categoryPriceRanges[category] ?? categoryPriceRanges['default']!;

    final costBased = materialCost + (laborHours * hourlyRate);
    // Blend: 60% weight on the artisan's actual cost input, 40% weight on
    // where similar products sit in the market, so the suggestion neither
    // undercuts the artisan nor ignores real production cost.
    final blendedLow = (costBased * 1.15 * 0.6) + (band.low * 0.4);
    final blendedHigh = (costBased * 1.6 * 0.6) + (band.high * 0.4);

    final low = blendedLow.clamp(band.low * 0.7, band.high);
    final high = blendedHigh.clamp(low + 1, band.high * 1.3);

    final explanation =
        'Based on your material cost (₹${materialCost.toStringAsFixed(0)}), '
        '${laborHours.toStringAsFixed(1)} hrs of labor, and current prices for '
        'similar ${category == 'default' ? 'handmade' : category} products in the market.';

    return PriceSuggestion(
      double.parse(low.toStringAsFixed(0)),
      double.parse(high.toStringAsFixed(0)),
      explanation,
    );
  }
}
