class ProductListing {
  final String imagePath;
  final String rawTranscript;
  final String category;
  final String titleEnglish;
  final String tagline;
  final String descriptionEnglish;
  final String descriptionHindi;
  final String culturalStory;
  final String materials;
  final String craftProcess;
  final String whySpecial;
  final String artisanNote;
  final double suggestedPriceLow;
  final double suggestedPriceHigh;
  double finalPrice;
  bool published;

  ProductListing({
    required this.imagePath,
    required this.rawTranscript,
    required this.category,
    required this.titleEnglish,
    this.tagline = '',
    required this.descriptionEnglish,
    required this.descriptionHindi,
    this.culturalStory = '',
    this.materials = '',
    this.craftProcess = '',
    this.whySpecial = '',
    this.artisanNote = '',
    required this.suggestedPriceLow,
    required this.suggestedPriceHigh,
    double? finalPrice,
    this.published = true,
  }) : finalPrice = finalPrice ?? ((suggestedPriceLow + suggestedPriceHigh) / 2);
}
