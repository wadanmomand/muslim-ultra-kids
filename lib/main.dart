import 'package:flutter/material.dart';

import 'ads/ads_service.dart';
import 'engine/daily_ayah.dart';
import 'engine/game_state.dart';
import 'l10n/strings.dart';
import 'screens/map_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await KidsAds.initialize();
  final gameState = GameState();
  await gameState.init();
  // Daily Ayah reminder (local notification, no server).
  try {
    await AyahReminders.init();
    if (gameState.store.getSetting('notif') != 'off') {
      await AyahReminders.scheduleDaily(
        ayahForDate(DateTime.now()),
        gameState.lang.code,
      );
    }
  } catch (_) {
    // Notifications are best-effort.
  }
  runApp(MuslimUltraKidsApp(state: gameState));
}

class MuslimUltraKidsApp extends StatefulWidget {
  final GameState state;
  const MuslimUltraKidsApp({super.key, required this.state});

  @override
  State<MuslimUltraKidsApp> createState() => _MuslimUltraKidsAppState();
}

class _MuslimUltraKidsAppState extends State<MuslimUltraKidsApp> {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.state,
      builder: (_, _) {
        return MaterialApp(
          title: widget.state.strings.get('appName'),
          theme: KidsTheme.light,
          debugShowCheckedModeBanner: false,
          home: Directionality(
            textDirection: widget.state.lang.direction,
            child: MapScreen(state: widget.state),
          ),
        );
      },
    );
  }
}
