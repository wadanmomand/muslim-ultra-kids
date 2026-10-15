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
    'language': {
      KidsLang.en: 'Language',
      KidsLang.ur: 'زبان',
      KidsLang.ar: 'اللغة',
    },
    'darkMode': {
      KidsLang.en: 'Dark mode',
      KidsLang.ur: 'ڈارک موڈ',
      KidsLang.ar: 'الوضع الداكن',
    },
    'lightMode': {
      KidsLang.en: 'Light mode',
      KidsLang.ur: 'لائٹ موڈ',
      KidsLang.ar: 'الوضع الفاتح',
    },
    'downloadAudio': {
      KidsLang.en: 'Download audio',
      KidsLang.ur: 'آڈیو ڈاؤن لوڈ کریں',
      KidsLang.ar: 'تحميل الصوت',
    },
    'play': {
      KidsLang.en: 'Play',
      KidsLang.ur: 'کھیلیں',
      KidsLang.ar: 'العب',
    },
    'reciter': {
      KidsLang.en: 'Reciter',
      KidsLang.ur: 'قاری',
      KidsLang.ar: 'القارئ',
    },
    'dailyAyahReminder': {
      KidsLang.en: 'Daily Ayah reminder',
      KidsLang.ur: 'روزانہ آیت کی یاد دہانی',
      KidsLang.ar: 'تذكير آية اليوم',
    },
    'sendEveryMorning': {
      KidsLang.en: 'Send every morning',
      KidsLang.ur: 'ہر صبح بھیجیں',
      KidsLang.ar: 'أرسل كل صباح',
    },
    'about': {
      KidsLang.en: 'About',
      KidsLang.ur: 'تعارف',
      KidsLang.ar: 'حول',
    },
    'resetProgress': {
      KidsLang.en: 'Reset progress',
      KidsLang.ur: 'پیش رفت ری سیٹ کریں',
      KidsLang.ar: 'إعادة تعيين التقدم',
    },
    'resetConfirm': {
      KidsLang.en: 'Reset all progress?',
      KidsLang.ur: 'کیا تمام پیش رفت ری سیٹ کریں؟',
      KidsLang.ar: 'هل تريد إعادة تعيين كل التقدم؟',
    },
    'cancel': {
      KidsLang.en: 'Cancel',
      KidsLang.ur: 'منسوخ کریں',
      KidsLang.ar: 'إلغاء',
    },
    'reset': {
      KidsLang.en: 'Reset',
      KidsLang.ur: 'ری سیٹ',
      KidsLang.ar: 'إعادة تعيين',
    },
  };

  String get(String key) => _t[key]?[lang] ?? _t[key]?[KidsLang.en] ?? key;

  /// All keys must exist for all languages (checked in tests).
  @visibleForTesting
  static Map<String, Map<KidsLang, String>> get table => _t;
}
