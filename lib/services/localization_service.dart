import 'package:flutter/material.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

class AppLanguage {
  final String code;
  final String name;
  final String nativeName;
  final TranslateLanguage? mlKit;
  const AppLanguage(this.code, this.name, this.nativeName, [this.mlKit]);
}

/// Indian language support. ML Kit provides on-device translation for the
/// languages marked with an ML Kit mapping. The remaining scheduled Indian
/// languages are kept in the selector for future translation packs rather
/// than pretending that English is a translated UI.
class AppLanguages {
  static const supported = <AppLanguage>[
    AppLanguage('en', 'English', 'English'),
    AppLanguage('as', 'Assamese', 'অসমীয়া'),
    AppLanguage('bn', 'Bengali', 'বাংলা', TranslateLanguage.bengali),
    AppLanguage('brx', 'Bodo', 'बर’'),
    AppLanguage('doi', 'Dogri', 'डोगरी'),
    AppLanguage('gu', 'Gujarati', 'ગુજરાતી', TranslateLanguage.gujarati),
    AppLanguage('hi', 'Hindi', 'हिन्दी', TranslateLanguage.hindi),
    AppLanguage('kn', 'Kannada', 'ಕನ್ನಡ', TranslateLanguage.kannada),
    AppLanguage('ks', 'Kashmiri', 'कॉशुर'),
    AppLanguage('kok', 'Konkani', 'कोंकणी'),
    AppLanguage('mai', 'Maithili', 'मैथिली'),
    AppLanguage('ml', 'Malayalam', 'മലയാളം', null),
    AppLanguage('mni', 'Meitei (Manipuri)', 'মৈতৈলোন্'),
    AppLanguage('mr', 'Marathi', 'मराठी', TranslateLanguage.marathi),
    AppLanguage('ne', 'Nepali', 'नेपाली'),
    AppLanguage('or', 'Odia', 'ଓଡ଼ିଆ'),
    AppLanguage('pa', 'Punjabi', 'ਪੰਜਾਬੀ', null),
    AppLanguage('sa', 'Sanskrit', 'संस्कृतम्'),
    AppLanguage('sat', 'Santali', 'ᱥᱟᱱᱛᱟᱲᱤ'),
    AppLanguage('sd', 'Sindhi', 'سنڌي'),
    AppLanguage('ta', 'Tamil', 'தமிழ்', TranslateLanguage.tamil),
    AppLanguage('te', 'Telugu', 'తెలుగు', TranslateLanguage.telugu),
    AppLanguage('ur', 'Urdu', 'اردو', TranslateLanguage.urdu),
  ];
}

class AppLocale {
  static String code = 'en';
  static final ValueNotifier<String> notifier = ValueNotifier(code);
  static void set(String value) {
    code = value;
    notifier.value = value;
  }
  static AppLanguage get current => AppLanguages.supported.firstWhere(
        (l) => l.code == code,
        orElse: () => AppLanguages.supported.first,
      );
  static bool get isRtl => code == 'ur' || code == 'sd' || code == 'ks';
}

class L10n {
  static final Map<String, Map<String, String>> _cache = {'en': {}};
  static final Map<String, Future<void>> _inFlight = {};
  static String t(String key) => _cache[AppLocale.code]?[key] ?? key;

  /// Translates one UI string on-device for ML Kit-supported Indian languages.
  /// Strings are cached for the rest of the session, so the same label is
  /// never translated twice.
  static Future<void> translate(String key) async {
    final target = AppLocale.current.mlKit;
    if (target == null || AppLocale.code == 'en' || key.trim().isEmpty) return;
    final lang = AppLocale.code;
    _cache.putIfAbsent(lang, () => {});
    if (_cache[lang]!.containsKey(key)) return;
    final token = '$lang::$key';
    if (_inFlight.containsKey(token)) return _inFlight[token]!;
    final future = _translate(key, target, lang);
    _inFlight[token] = future;
    await future;
    _inFlight.remove(token);
  }

  static Future<void> _translate(String key, TranslateLanguage target, String lang) async {
    OnDeviceTranslator? translator;
    try {
      translator = OnDeviceTranslator(
        sourceLanguage: TranslateLanguage.english,
        targetLanguage: target,
      );
      final result = await translator.translateText(key);
      if (result.trim().isNotEmpty) _cache[lang]![key] = result;
    } catch (_) {
      // The UI remains functional if the model is unavailable. A missing
      // translation is deliberately not persisted as fake translated text.
    } finally {
      translator?.close();
    }
  }

  static Future<void> prepareLanguage(String code) async {
    final language = AppLanguages.supported.firstWhere(
      (l) => l.code == code,
      orElse: () => AppLanguages.supported.first,
    );
    if (language.mlKit == null || code == 'en') return;
    try {
      final manager = OnDeviceTranslatorModelManager();
      await manager.downloadModel(TranslateLanguage.english.bcpCode);
      await manager.downloadModel(language.mlKit!.bcpCode);
    } catch (_) {}
  }

  /// The visible UI strings used by the app. They are prewarmed after a
  /// language is selected so the interface does not progressively reveal
  /// English labels while a translation model is being prepared.
  static const uiStrings = <String>[
    'Dashboard','Analytics','Products','Orders','Marketplace','Settings','Home','Markets',
    'Create a product','Create product listing','View analytics','View page','All orders',
    'Sales at a glance','Needs your attention','Revenue · 30 days','Orders · 30 days',
    'Active products','Orders to prepare','Compared with previous 30 days · demo data',
    'Your business, at a glance','Understand what sells, where it sells, and what you earn.',
    '30 days','1 year','Gross sales','Estimated profit','Orders','Average order','Sales trend',
    'Monthly sales · sample','Daily/weekly sales · sample','Product performance','Marketplace comparison',
    'Illustrative demo figures. Profit estimates exclude platform-specific fee verification.',
    'Your products','Your craft catalog, ready to improve and share.','Search your products',
    'Demo catalog','listings','Create Product Page','Make your craft discoverable',
    'No forms. Just show us the product and tell its story in your own voice.',
    'Voice input language','Take photo','Upload photos','Craft details','Product name (optional)',
    'Category','Tell us about the product','What is it? How is it made? What makes it special?',
    'Materials (if known)','Price & production','Your selling price (₹)','Units you can make','In how many days?',
    'Generate Product Page','Your Groq key is used only for this AI generation request.','Speak',
    'Listening… tap to stop','Tap and speak naturally — any supported language','Initializing microphone…',
    'Tap to take a photo','Orders','Filter orders','Update order status','Quantity','Order total','Prepare by',
    'Paid','Payment pending','New','In progress','Ready','Delivered','Marketplaces',
    'Choose where you want to offer your craft.','Enabled destinations','Settings','Save profile',
    'Artisan profile','Your name','Business / craft name','Contact number','Location','About your craft / business',
    'AI configuration','Groq API key','Apply API keys','AI keys set in memory for this session.',
    'About KaragirSetu','Log out','Welcome back','Sign in','Username','Password','Language',
    'Your craft. Your story. Your marketplace.','Sign in to your artisan workspace.','DEMO ACCESS',
    'Prototype account only. Replace demo authentication before real deployment.',
    'Made for the people behind the craft ✦','Check the demo username and password.',
    'NAMASTE, BHARAT 👋','Your craft is going places.','Here’s what’s happening in your artisan business.',
    'Buyer preview','Preview listing','Share product page','Publish (demo)','AI-crafted listing','Share Page',
    'Share listing','Close','Cancel','Save product','Save','Your Product Page','The story','Rooted in India',
    'Made by hand','Why it is special','INDIAN CRAFT • HANDMADE','Powered by Karigar Setu • AI-assisted storytelling',
    'Product page saved to your Karigar Setu shop.','Try again','We could not generate the page',
    'Karigar Setu AI is crafting your story','Product saved in this demo session.','Shareable product page',
    'AI-enhanced photo','Review Listing','Suggested Price','Final price: ₹','Publish to Marketplace',
    'Published!','Back to My Shop','Demo publish','Simulate publish','Demo publish recorded locally. No external marketplace was contacted.',
    'Welcome to Karigar Setu','Enter Karigar Setu','Prototype mode: your key is not written into the APK or committed to GitHub.',
    'Groq is the only AI provider used by this build. Your key is kept in app memory for this session.',
    'Generates the listing in your selected UI language.','Please enter your Groq API key to continue.','Use another Groq key','Add a few details about your craft first.','Add multiple photos. Video selection is not enabled in this prototype.','Bring your own Groq API key. It stays in this app session and is used only when you generate a product page.','Buyer:','Connect demo','Connection and publishing are simulated in this build. Live connections require each marketplace’s seller approval, API access, and credentials.','Create a Product Page','Designed to help artisans tell the story behind their work and manage a growing digital catalog.','Groq AI','Made to order: up to','Made with care','Photo + your voice → an AI-powered product landing page you can share.','Take a photo, describe the craft in your own voice, and let Karigar Setu create a beautiful story around it.','The app will show the stated production time; shipping estimates must come from the marketplace.','Turn your craft into a story','Version 2 · SIH prototype build','You can create a Groq key from the Groq Console. Keep it private and do not paste it into GitHub.','Your first product page starts here','Your product is now live on the digital marketplace and visible to buyers year-round — not just during the next mela.','Simulated GeM / ONDC listing for demo purposes','Full on-device UI translation is available for 10 Indian languages in this build. The other scheduled languages remain listed for future Indic translation packs.','KaragirSetu','Karigar Setu','Materials','Profile saved for this session.','Create product','Namaste, artisan 👋','Made to order: up to','Your craft is going places.','NAMASTE, BHARAT 👋','A shareable public URL will be available when hosted publishing is connected.','KaragirSetu demo listing',
  ];

  static Future<void> warmLanguage(String code) async {
    final language = AppLanguages.supported.firstWhere(
      (l) => l.code == code,
      orElse: () => AppLanguages.supported.first,
    );
    await prepareLanguage(code);
    if (code == 'en' || language.mlKit == null) return;
    _cache.putIfAbsent(code, () => {});
    OnDeviceTranslator? translator;
    try {
      translator = OnDeviceTranslator(
        sourceLanguage: TranslateLanguage.english,
        targetLanguage: language.mlKit!,
      );
      for (final key in uiStrings) {
        if (_cache[code]!.containsKey(key)) continue;
        try {
          final result = await translator.translateText(key);
          if (result.trim().isNotEmpty) _cache[code]![key] = result;
        } catch (_) {}
      }
    } catch (_) {}
    finally { translator?.close(); }
  }

  static Future<void> warmCurrentLanguage() async {
    final code = AppLocale.code;
    await warmLanguage(code);
    AppLocale.notifier.value = code;
  }
}

class LText extends StatefulWidget {
  final String data;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  const LText(this.data, {super.key, this.style, this.textAlign, this.maxLines, this.overflow});
  @override State<LText> createState() => _LTextState();
}

class _LTextState extends State<LText> {
  void _onLocaleChanged() {
    if (mounted) setState(() {});
    L10n.translate(widget.data).then((_) { if (mounted) setState(() {}); });
  }

  @override
  void initState() {
    super.initState();
    AppLocale.notifier.addListener(_onLocaleChanged);
    L10n.translate(widget.data).then((_) { if (mounted) setState(() {}); });
  }

  @override
  void didUpdateWidget(covariant LText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      L10n.translate(widget.data).then((_) { if (mounted) setState(() {}); });
    }
  }

  @override
  void dispose() {
    AppLocale.notifier.removeListener(_onLocaleChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Text(
        L10n.t(widget.data),
        style: widget.style,
        textAlign: widget.textAlign,
        maxLines: widget.maxLines,
        overflow: widget.overflow,
      );
}
