import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Ayah of the Day: bundled list (no backend), picked by day-of-year.
/// Shown as a card on the map + a daily local notification.
class DailyAyah {
  final String text;
  final Map<String, String> meaning;
  final int globalAyahNumber;

  const DailyAyah({
    required this.text,
    required this.meaning,
    required this.globalAyahNumber,
  });

  String meaningIn(String lang) => meaning[lang] ?? meaning['en']!;
}

/// Full set: 30 ayahs from Juz Amma + Al-Fatiha (grows with content).
/// Full set: 30 ayahs from Juz Amma + Al-Fatiha (grows with content).
const List<DailyAyah> dailyAyahs = [
  DailyAyah(
    text: 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
    meaning: {
      'en': 'In the name of Allah, the Entirely Merciful, the Especially Merciful.',
      'ur': 'شروع الله کا نام لے کر جو بڑا مہربان نہایت رحم والا ہے',
    },
    globalAyahNumber: 1,
  ),
  DailyAyah(
    text: 'ٱلْحَمْدُ لِلَّهِ رَبِّ ٱلْعَٰلَمِينَ',
    meaning: {
      'en': '[All] praise is [due] to Allah, Lord of the worlds -',
      'ur': 'سب طرح کی تعریف خدا ہی کو (سزاوار) ہے جو تمام مخلوقات کا پروردگار ہے',
    },
    globalAyahNumber: 2,
  ),
  DailyAyah(
    text: 'سَبِّحِ ٱسْمَ رَبِّكَ ٱلْأَعْلَى',
    meaning: {
      'en': 'Exalt the name of your Lord, the Most High,',
      'ur': '(اے پیغمبر) اپنے پروردگار جلیل الشان کے نام کی تسبیح کرو',
    },
    globalAyahNumber: 5949,
  ),
  DailyAyah(
    text: 'هَلْ أَتَىٰكَ حَدِيثُ ٱلْغَٰشِيَةِ',
    meaning: {
      'en': 'Has there reached you the report of the Overwhelming [event]?',
      'ur': 'بھلا تم کو ڈھانپ لینے والی (یعنی قیامت کا) حال معلوم ہوا ہے',
    },
    globalAyahNumber: 5968,
  ),
  DailyAyah(
    text: 'وَٱلْفَجْرِ',
    meaning: {
      'en': 'By the dawn',
      'ur': 'فجر کی قسم',
    },
    globalAyahNumber: 5994,
  ),
  DailyAyah(
    text: 'لَآ أُقْسِمُ بِهَٰذَا ٱلْبَلَدِ',
    meaning: {
      'en': 'I swear by this city, Makkah -',
      'ur': 'ہمیں اس شہر (مکہ) کی قسم',
    },
    globalAyahNumber: 6024,
  ),
  DailyAyah(
    text: 'وَٱلشَّمْسِ وَضُحَىٰهَا',
    meaning: {
      'en': 'By the sun and its brightness',
      'ur': 'سورج کی قسم اور اس کی روشنی کی',
    },
    globalAyahNumber: 6044,
  ),
  DailyAyah(
    text: 'وَٱلَّيْلِ إِذَا يَغْشَىٰ',
    meaning: {
      'en': 'By the night when it covers',
      'ur': 'رات کی قسم جب (دن کو) چھپالے',
    },
    globalAyahNumber: 6059,
  ),
  DailyAyah(
    text: 'وَٱلضُّحَىٰ',
    meaning: {
      'en': 'By the morning brightness',
      'ur': 'آفتاب کی روشنی کی قسم',
    },
    globalAyahNumber: 6080,
  ),
  DailyAyah(
    text: 'أَلَمْ نَشْرَحْ لَكَ صَدْرَكَ',
    meaning: {
      'en': 'Did We not expand for you, [O Muhammad], your breast?',
      'ur': '(اے محمدﷺ) کیا ہم نے تمہارا سینہ کھول نہیں دیا؟ (بےشک کھول دیا)',
    },
    globalAyahNumber: 6091,
  ),
  DailyAyah(
    text: 'وَٱلتِّينِ وَٱلزَّيْتُونِ',
    meaning: {
      'en': 'By the fig and the olive',
      'ur': 'انجیر کی قسم اور زیتون کی',
    },
    globalAyahNumber: 6099,
  ),
  DailyAyah(
    text: 'ٱقْرَأْ بِٱسْمِ رَبِّكَ ٱلَّذِى خَلَقَ',
    meaning: {
      'en': 'Recite in the name of your Lord who created -',
      'ur': '(اے محمدﷺ) اپنے پروردگار کا نام لے کر پڑھو جس نے (عالم کو) پیدا کیا',
    },
    globalAyahNumber: 6107,
  ),
  DailyAyah(
    text: 'إِنَّآ أَنزَلْنَٰهُ فِى لَيْلَةِ ٱلْقَدْرِ',
    meaning: {
      'en': 'Indeed, We sent the Qur\'an down during the Night of Decree.',
      'ur': 'ہم نے اس (قرآن) کو شب قدر میں نازل (کرنا شروع) کیا',
    },
    globalAyahNumber: 6126,
  ),
  DailyAyah(
    text: 'لَمْ يَكُنِ ٱلَّذِينَ كَفَرُوا۟ مِنْ أَهْلِ ٱلْكِتَٰبِ وَٱلْمُشْرِكِينَ مُنفَكِّينَ حَتَّىٰ تَأْتِيَهُمُ ٱلْبَيِّنَةُ',
    meaning: {
      'en': 'Those who disbelieved among the People of the Scripture and the polytheists were not to be parted [from misbelief] until there came to them clear evidence -',
      'ur': 'جو لوگ کافر ہیں (یعنی) اہل کتاب اور مشرک وہ (کفر سے) باز رہنے والے نہ تھے جب تک ان کے پاس کھلی دلیل (نہ) آتی',
    },
    globalAyahNumber: 6131,
  ),
  DailyAyah(
    text: 'إِذَا زُلْزِلَتِ ٱلْأَرْضُ زِلْزَالَهَا',
    meaning: {
      'en': 'When the earth is shaken with its [final] earthquake',
      'ur': 'جب زمین بھونچال سے ہلا دی جائے گی',
    },
    globalAyahNumber: 6139,
  ),
  DailyAyah(
    text: 'وَٱلْعَٰدِيَٰتِ ضَبْحًۭا',
    meaning: {
      'en': 'By the racers, panting,',
      'ur': 'ان سرپٹ دوڑنے والے گھوڑوں کی قسم جو ہانپ اٹھتےہیں',
    },
    globalAyahNumber: 6147,
  ),
  DailyAyah(
    text: 'ٱلْقَارِعَةُ',
    meaning: {
      'en': 'The Striking Calamity -',
      'ur': 'کھڑ کھڑانے والی',
    },
    globalAyahNumber: 6158,
  ),
  DailyAyah(
    text: 'أَلْهَىٰكُمُ ٱلتَّكَاثُرُ',
    meaning: {
      'en': 'Competition in [worldly] increase diverts you',
      'ur': '(لوگو) تم کو (مال کی) بہت سی طلب نے غافل کر دیا',
    },
    globalAyahNumber: 6169,
  ),
  DailyAyah(
    text: 'وَٱلْعَصْرِ',
    meaning: {
      'en': 'By time,',
      'ur': 'عصر کی قسم',
    },
    globalAyahNumber: 6177,
  ),
  DailyAyah(
    text: 'وَيْلٌۭ لِّكُلِّ هُمَزَةٍۢ لُّمَزَةٍ',
    meaning: {
      'en': 'Woe to every scorner and mocker',
      'ur': 'ہر طعن آمیز اشارتیں کرنے والے چغل خور کی خرابی ہے',
    },
    globalAyahNumber: 6180,
  ),
  DailyAyah(
    text: 'أَلَمْ تَرَ كَيْفَ فَعَلَ رَبُّكَ بِأَصْحَٰبِ ٱلْفِيلِ',
    meaning: {
      'en': 'Have you not considered, [O Muhammad], how your Lord dealt with the companions of the elephant?',
      'ur': 'کیا تم نے نہیں دیکھا کہ تمہارے پروردگار نے ہاتھی والوں کے ساتھ کیا کیا',
    },
    globalAyahNumber: 6189,
  ),
  DailyAyah(
    text: 'لِإِيلَٰفِ قُرَيْشٍ',
    meaning: {
      'en': 'For the accustomed security of the Quraysh -',
      'ur': 'قریش کے مانوس کرنے کے سبب',
    },
    globalAyahNumber: 6194,
  ),
  DailyAyah(
    text: 'أَرَءَيْتَ ٱلَّذِى يُكَذِّبُ بِٱلدِّينِ',
    meaning: {
      'en': 'Have you seen the one who denies the Recompense?',
      'ur': 'بھلا تم نے اس شخص کو دیکھا جو (روزِ) جزا کو جھٹلاتا ہے؟',
    },
    globalAyahNumber: 6198,
  ),
  DailyAyah(
    text: 'إِنَّآ أَعْطَيْنَٰكَ ٱلْكَوْثَرَ',
    meaning: {
      'en': 'Indeed, We have granted you, [O Muhammad], al-Kawthar.',
      'ur': '(اے محمدﷺ) ہم نے تم کو کوثر عطا فرمائی ہے',
    },
    globalAyahNumber: 6205,
  ),
  DailyAyah(
    text: 'قُلْ يَٰٓأَيُّهَا ٱلْكَٰفِرُونَ',
    meaning: {
      'en': 'Say, "O disbelievers,',
      'ur': '(اے پیغمبر ان منکران اسلام سے) کہہ دو کہ اے کافرو!',
    },
    globalAyahNumber: 6208,
  ),
  DailyAyah(
    text: 'إِذَا جَآءَ نَصْرُ ٱللَّهِ وَٱلْفَتْحُ',
    meaning: {
      'en': 'When the victory of Allah has come and the conquest,',
      'ur': 'جب خدا کی مدد آ پہنچی اور فتح (حاصل ہو گئی)',
    },
    globalAyahNumber: 6214,
  ),
  DailyAyah(
    text: 'تَبَّتْ يَدَآ أَبِى لَهَبٍۢ وَتَبَّ',
    meaning: {
      'en': 'May the hands of Abu Lahab be ruined, and ruined is he.',
      'ur': 'ابولہب کے ہاتھ ٹوٹیں اور وہ ہلاک ہو',
    },
    globalAyahNumber: 6217,
  ),
  DailyAyah(
    text: 'قُلْ هُوَ ٱللَّهُ أَحَدٌ',
    meaning: {
      'en': 'Say, "He is Allah, [who is] One,',
      'ur': 'کہو کہ وہ (ذات پاک جس کا نام) الله (ہے) ایک ہے',
    },
    globalAyahNumber: 6222,
  ),
  DailyAyah(
    text: 'قُلْ أَعُوذُ بِرَبِّ ٱلْفَلَقِ',
    meaning: {
      'en': 'Say, "I seek refuge in the Lord of daybreak',
      'ur': 'کہو کہ میں صبح کے پروردگار کی پناہ مانگتا ہوں',
    },
    globalAyahNumber: 6226,
  ),
  DailyAyah(
    text: 'قُلْ أَعُوذُ بِرَبِّ ٱلنَّاسِ',
    meaning: {
      'en': 'Say, "I seek refuge in the Lord of mankind,',
      'ur': 'کہو کہ میں لوگوں کے پروردگار کی پناہ مانگتا ہوں',
    },
    globalAyahNumber: 6231,
  )
];

DailyAyah ayahForDate(DateTime date) {
  final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays;
  return dailyAyahs[dayOfYear % dailyAyahs.length];
}

/// Schedules the daily reminder. Idempotent: re-scheduling the same id
/// replaces the previous one. No server involved.
class AyahReminders {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _ready = false;

  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(const InitializationSettings(android: android));
    _ready = true;
  }

  static Future<void> scheduleDaily(DailyAyah ayah, String lang) async {
    if (!_ready) return;
    try {
      const details = NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_ayah',
          'Daily Ayah',
          channelDescription: 'A daily ayah reminder for your child',
        ),
      );
      await _plugin.periodicallyShow(
        1,
        'Ayah of the Day',
        ayah.meaningIn(lang),
        RepeatInterval.daily,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (_) {
      // Notifications are best-effort (permission may be denied).
    }
  }

  static Future<void> cancel() => _plugin.cancel(1);
}
