/// Rough reference price bands (in INR) for common handicraft categories.
/// In production these would come from a live scrape / API of GeM,
/// Amazon Karigar, Etsy and similar marketplaces, refreshed periodically
/// and fed into a regression model. For today's prototype they are a
/// small static dataset so the Pricing Assistant has something real
/// to reason from instead of a placeholder number.
class CategoryPriceRange {
  final double low;
  final double high;
  const CategoryPriceRange(this.low, this.high);
}

const Map<String, CategoryPriceRange> categoryPriceRanges = {
  'saree': CategoryPriceRange(1500, 6500),
  'textile': CategoryPriceRange(600, 3500),
  'pottery': CategoryPriceRange(250, 1800),
  'basket': CategoryPriceRange(200, 1200),
  'jewelry': CategoryPriceRange(300, 4000),
  'woodcraft': CategoryPriceRange(400, 5000),
  'painting': CategoryPriceRange(800, 8000),
  'metalcraft': CategoryPriceRange(500, 6000),
  'default': CategoryPriceRange(300, 2500),
};

/// Keywords used to guess a product's category from the artisan's
/// transcribed voice note. Very small hackathon stand-in for a proper
/// NLP classifier.
const Map<String, List<String>> categoryKeywords = {
  'saree': ['saree', 'sari', 'साड़ी'],
  'textile': ['cloth', 'fabric', 'shawl', 'stole', 'dupatta', 'कपड़ा', 'चादर'],
  'pottery': ['pot', 'clay', 'terracotta', 'pottery', 'मिट्टी', 'बर्तन'],
  'basket': ['basket', 'bamboo', 'cane', 'टोकरी', 'बांस'],
  'jewelry': ['jewelry', 'jewellery', 'necklace', 'earring', 'bangle', 'गहने'],
  'woodcraft': ['wood', 'wooden', 'carving', 'लकड़ी'],
  'painting': ['painting', 'art', 'madhubani', 'warli', 'चित्रकला'],
  'metalcraft': ['brass', 'copper', 'metal', 'धातु', 'पीतल'],
};
