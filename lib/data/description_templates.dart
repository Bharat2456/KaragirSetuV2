/// Simple keyword lists used to pull attributes out of the artisan's
/// raw transcript, plus template sentences to assemble a listing.
/// This stands in for an LLM call so the app works fully offline and
/// for free — swap `DescriptionService` for a real LLM/IndicTrans2 call
/// later without touching the rest of the app.

const List<String> knownMaterials = [
  'cotton', 'silk', 'wool', 'jute', 'bamboo', 'clay', 'terracotta', 'brass',
  'copper', 'wood', 'cane', 'wax', 'thread', 'leather',
  'सूती', 'रेशम', 'बांस', 'मिट्टी', 'पीतल', 'लकड़ी',
];

const List<String> knownColors = [
  'red', 'blue', 'green', 'yellow', 'orange', 'white', 'black', 'pink',
  'purple', 'maroon', 'golden', 'multicolor',
  'लाल', 'नीला', 'हरा', 'पीला', 'सफ़ेद', 'काला',
];

const Map<String, String> categoryDisplayName = {
  'saree': 'Handwoven Saree',
  'textile': 'Handcrafted Textile',
  'pottery': 'Handmade Terracotta Piece',
  'basket': 'Handwoven Basket',
  'jewelry': 'Handcrafted Jewelry',
  'woodcraft': 'Hand-carved Wooden Craft',
  'painting': 'Traditional Folk Painting',
  'metalcraft': 'Handcrafted Metal Ware',
  'default': 'Handmade Craft Product',
};

/// English description templates, {material}/{color}/{product} get
/// substituted in by DescriptionService.
const List<String> englishTemplates = [
  'Beautifully handcrafted {product}, made with {material} by skilled '
      'local artisans using traditional techniques passed down through '
      'generations. This {color} piece brings authentic Indian craftsmanship '
      'into your home. Every piece is unique and supports a marginalized '
      'artisan community directly.',
  'This {color} {product} is handmade using {material}, reflecting rich '
      'regional heritage and fine craftsmanship. A one-of-a-kind piece, '
      'perfect as a gift or for everyday use, crafted by artisans as part '
      'of a government-supported livelihood program.',
];

/// Hindi fallback templates used only if on-device translation is
/// unavailable (e.g. language model not yet downloaded).
const List<String> hindiFallbackTemplates = [
  'यह {color} {product} कुशल कारीगरों द्वारा {material} से हाथ से बनाया गया है। '
      'यह पारंपरिक शिल्पकला का एक सुंदर उदाहरण है और हर टुकड़ा अनोखा है।',
];
