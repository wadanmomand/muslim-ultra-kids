import 'package:flutter/widgets.dart';

/// Supported UI languages. Full trilingual EN/UR/AR with RTL (locked 2026-10-12).
enum KidsLang { en, ur, ar }

extension KidsLangX on KidsLang {
  String get code => switch (this) {
        KidsLang.en => 'en',
        KidsLang.ur => 'ur',
        KidsLang.ar => 'ar',
      };

  TextDirection get direction =>
      this == KidsLang.en ? TextDirection.ltr : TextDirection.rtl;

  String get label => switch (this) {
        KidsLang.en => 'English',
        KidsLang.ur => 'اردو',
        KidsLang.ar => 'العربية',
      };
}

/// Minimal string table. Phase 1 covers shell + engine-facing strings;
/// lesson content ships its own trilingual fields in JSON.
class KidsStrings {
  final KidsLang lang;
  const KidsStrings(this.lang);

  static const _t = <String, Map<KidsLang, String>>{
    'appName': {
      KidsLang.en: 'Muslim Ultra Kids',
      KidsLang.ur: 'مسلم الٹرا کڈز',
      KidsLang.ar: 'مسلم ألترا كيدز',
    },
    'start': {
      KidsLang.en: 'Start',
      KidsLang.ur: 'شروع کریں',
      KidsLang.ar: 'ابدأ',
    },
    'continue': {
      KidsLang.en: 'Continue',
      KidsLang.ur: 'جاری رکھیں',
      KidsLang.ar: 'تابع',
    },
    'listen': {
      KidsLang.en: 'Listen',
      KidsLang.ur: 'سنیں',
      KidsLang.ar: 'استمع',
    },
    'repeatAfterMe': {
      KidsLang.en: 'Repeat after me',
      KidsLang.ur: 'میرے بعد دہرائیں',
      KidsLang.ar: 'ردد بعدي',
    },
    'wellDone': {
      KidsLang.en: 'Well done!',
      KidsLang.ur: 'شاباش!',
      KidsLang.ar: 'أحسنت!',
    },
    'tryAgain': {
      KidsLang.en: 'Try again',
      KidsLang.ur: 'دوبارہ کوشش کریں',
      KidsLang.ar: 'حاول مجددًا',
    },
    'stars': {
      KidsLang.en: 'Stars',
      KidsLang.ur: 'ستارے',
      KidsLang.ar: 'نجوم',
    },
    'settings': {
      KidsLang.en: 'Settings',
      KidsLang.ur: 'ترتیبات',
      KidsLang.ar: 'الإعدادات',
    },
    'forParents': {
      KidsLang.en: 'For Parents',
      KidsLang.ur: 'والدین کے لیے',
      KidsLang.ar: 'للآباء',
    },
    'ayahOfTheDay': {
      KidsLang.en: 'Ayah of the Day',
      KidsLang.ur: 'آج کی آیت',
      KidsLang.ar: 'آية اليوم',
    },
  };

  String get(String key) => _t[key]?[lang] ?? _t[key]?[KidsLang.en] ?? key;

  /// All keys must exist for all languages (checked in tests).
  @visibleForTesting
  static Map<String, Map<KidsLang, String>> get table => _t;
}
