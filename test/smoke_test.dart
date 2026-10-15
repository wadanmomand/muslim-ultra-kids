import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_ultra_kids/engine/game_state.dart';
import 'package:muslim_ultra_kids/main.dart';

/// Smoke test: the app shell builds without crashing.
/// (Does not call main(), so AdMob is never initialized in tests.)
void main() {
  testWidgets('map screen renders app title', (tester) async {
    await tester.pumpWidget(MuslimUltraKidsApp(state: GameState()));
    await tester.pump();
    expect(find.text('Muslim Ultra Kids'), findsWidgets);
  });
}
