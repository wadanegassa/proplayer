import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:proplayer/providers/audio_player_provider.dart';
import 'package:proplayer/providers/browser_provider.dart';
import 'package:proplayer/providers/home_provider.dart';
import 'package:proplayer/providers/library_provider.dart';
import 'package:proplayer/providers/player_provider.dart';
import 'package:proplayer/providers/theme_provider.dart';
import 'package:proplayer/screens/main_screen.dart';

void main() {
  testWidgets('MainScreen builds with app providers', (WidgetTester tester) async {
    final audio = AudioPlayerProvider();
    audio.initialize();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => PlayerProvider()),
          ChangeNotifierProvider(create: (_) => HomeProvider()),
          ChangeNotifierProvider(create: (_) => BrowserProvider()),
          ChangeNotifierProvider(create: (_) => LibraryProvider()),
          ChangeNotifierProvider.value(value: audio),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ],
        child: const MaterialApp(
          home: MainScreen(),
        ),
      ),
    );

    await tester.pump();
    expect(find.byType(MainScreen), findsOneWidget);
  });
}
