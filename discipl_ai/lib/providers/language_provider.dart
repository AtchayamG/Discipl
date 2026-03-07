import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AppLanguage — Supported languages
// ─────────────────────────────────────────────────────────────────────────────
class AppLanguage {
  final String code;        // e.g. 'en', 'hi'
  final String name;        // English display name
  final String nativeName;  // Native script name
  final String flag;        // Flag emoji
  final String greeting;    // "Good morning" in that language

  const AppLanguage({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flag,
    required this.greeting,
  });

  static const List<AppLanguage> all = [
    AppLanguage(code: 'en', name: 'English',   nativeName: 'English',    flag: '🇬🇧', greeting: 'Good morning'),
    AppLanguage(code: 'hi', name: 'Hindi',     nativeName: 'हिन्दी',    flag: '🇮🇳', greeting: 'सुप्रभात'),
    AppLanguage(code: 'kn', name: 'Kannada',   nativeName: 'ಕನ್ನಡ',     flag: '🇮🇳', greeting: 'ಶುಭೋದಯ'),
    AppLanguage(code: 'ml', name: 'Malayalam', nativeName: 'മലയാളം',   flag: '🇮🇳', greeting: 'സുപ്രഭാതം'),
    AppLanguage(code: 'ta', name: 'Tamil',     nativeName: 'தமிழ்',     flag: '🇮🇳', greeting: 'காலை வணக்கம்'),
    AppLanguage(code: 'te', name: 'Telugu',    nativeName: 'తెలుగు',    flag: '🇮🇳', greeting: 'శుభోదయం'),
  ];

  static AppLanguage fromCode(String code) =>
      all.firstWhere((l) => l.code == code, orElse: () => all.first);
}

// ─────────────────────────────────────────────────────────────────────────────
// LanguageProvider
// ─────────────────────────────────────────────────────────────────────────────
class LanguageProvider extends ChangeNotifier {
  AppLanguage _current = AppLanguage.all.first; // English default
  AppLanguage get current => _current;

  static const _prefKey = 'selected_language';

  LanguageProvider() {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_prefKey) ?? 'en';
      _current = AppLanguage.fromCode(code);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> setLanguage(AppLanguage lang) async {
    if (_current.code == lang.code) return;
    _current = lang;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, lang.code);
    } catch (_) {}
  }

  // ── Translated strings ────────────────────────────────────────────────────
  // Add more keys as your app grows. Each returns the string in the current language.
  String get appName => _t(const {
    'en': 'Discipl.AI', 'hi': 'Discipl.AI', 'kn': 'Discipl.AI',
    'ml': 'Discipl.AI', 'ta': 'Discipl.AI', 'te': 'Discipl.AI',
  });

  String get dashboard => _t(const {
    'en': 'Dashboard', 'hi': 'डैशबोर्ड', 'kn': 'ಡ್ಯಾಶ್‌ಬೋರ್ಡ್',
    'ml': 'ഡാഷ്‌ബോർഡ്', 'ta': 'டாஷ்போர்டு', 'te': 'డాష్‌బోర్డ్',
  });

  String get habits => _t(const {
    'en': 'Habits', 'hi': 'आदतें', 'kn': 'ಅಭ್ಯಾಸಗಳು',
    'ml': 'ശീലങ്ങൾ', 'ta': 'பழக்கங்கள்', 'te': 'అలవాట్లు',
  });

  String get workouts => _t(const {
    'en': 'Workouts', 'hi': 'वर्कआउट', 'kn': 'ವ್ಯಾಯಾಮ',
    'ml': 'വ്യായാമങ്ങൾ', 'ta': 'உடற்பயிற்சி', 'te': 'వర్కౌట్లు',
  });

  String get community => _t(const {
    'en': 'Community', 'hi': 'समुदाय', 'kn': 'ಸಮುದಾಯ',
    'ml': 'കമ്മ്യൂണിറ്റി', 'ta': 'சமூகம்', 'te': 'సంఘం',
  });

  String get profile => _t(const {
    'en': 'Profile', 'hi': 'प्रोफ़ाइल', 'kn': 'ಪ್ರೊಫೈಲ್',
    'ml': 'പ്രൊഫൈൽ', 'ta': 'சுயவிவரம்', 'te': 'ప్రొఫైల్',
  });

  String get settings => _t(const {
    'en': 'Settings', 'hi': 'सेटिंग्स', 'kn': 'ಸೆಟ್ಟಿಂಗ್‌ಗಳು',
    'ml': 'ക്രമീകരണങ്ങൾ', 'ta': 'அமைப்புகள்', 'te': 'సెట్టింగులు',
  });

  String get language => _t(const {
    'en': 'Language', 'hi': 'भाषा', 'kn': 'ಭಾಷೆ',
    'ml': 'ഭാഷ', 'ta': 'மொழி', 'te': 'భాష',
  });

  String get selectLanguage => _t(const {
    'en': 'Select Language', 'hi': 'भाषा चुनें', 'kn': 'ಭಾಷೆ ಆಯ್ಕೆಮಾಡಿ',
    'ml': 'ഭാഷ തിരഞ്ഞെടുക്കുക', 'ta': 'மொழியை தேர்ந்தெடுக்கவும்', 'te': 'భాషను ఎంచుకోండి',
  });

  String get chooseLanguageSubtitle => _t(const {
    'en': 'Choose your preferred language for the app',
    'hi': 'ऐप के लिए अपनी पसंदीदा भाषा चुनें',
    'kn': 'ಅಪ್ಲಿಕೇಶನ್‌ಗಾಗಿ ನಿಮ್ಮ ಆದ್ಯತೆಯ ಭಾಷೆಯನ್ನು ಆಯ್ಕೆಮಾಡಿ',
    'ml': 'ആപ്പിനായി നിങ്ങളുടെ ഇഷ്ടപ്പെട്ട ഭാഷ തിരഞ്ഞെടുക്കുക',
    'ta': 'பயன்பாட்டிற்கான உங்கள் விருப்பமான மொழியை தேர்ந்தெடுக்கவும்',
    'te': 'యాప్ కోసం మీకు నచ్చిన భాషను ఎంచుకోండి',
  });

  String get goodMorning => _t(const {
    'en': 'Good morning', 'hi': 'सुप्रभात', 'kn': 'ಶುಭೋದಯ',
    'ml': 'സുപ്രഭാതം', 'ta': 'காலை வணக்கம்', 'te': 'శుభోదయం',
  });

  String get todaysHabits => _t(const {
    'en': "Today's Habits", 'hi': 'आज की आदतें', 'kn': 'ಇಂದಿನ ಅಭ್ಯಾಸಗಳು',
    'ml': 'ഇന്നത്തെ ശീലങ്ങൾ', 'ta': 'இன்றைய பழக்கங்கள்', 'te': 'నేటి అలవాట్లు',
  });

  String get signOut => _t(const {
    'en': 'Sign Out', 'hi': 'साइन आउट', 'kn': 'ಸೈನ್ ಔಟ್',
    'ml': 'സൈൻ ഔട്ട്', 'ta': 'வெளியேறு', 'te': 'సైన్ అవుట్',
  });

  String get appearance => _t(const {
    'en': 'Appearance', 'hi': 'रूप-रंग', 'kn': 'ಗೋಚರಿಕೆ',
    'ml': 'രൂപഭാവം', 'ta': 'தோற்றம்', 'te': 'రూపం',
  });

  String get notifications => _t(const {
    'en': 'Notifications', 'hi': 'सूचनाएं', 'kn': 'ಅಧಿಸೂಚನೆಗಳು',
    'ml': 'അറിയിപ്പുകൾ', 'ta': 'அறிவிப்புகள்', 'te': 'నోటిఫికేషన్లు',
  });

  String get privacy => _t(const {
    'en': 'Privacy', 'hi': 'गोपनीयता', 'kn': 'ಗೌಪ್ಯತೆ',
    'ml': 'സ്വകാര്യത', 'ta': 'தனியுரிமை', 'te': 'గోప్యత',
  });

  // ── Internal helper ───────────────────────────────────────────────────────
  String _t(Map<String, String> map) => map[_current.code] ?? map['en'] ?? '';
}
