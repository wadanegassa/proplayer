import 'package:flutter_test/flutter_test.dart';
import 'package:proplayer/providers/audio_player_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('repeat cycles off → all → one → off', () {
    final p = AudioPlayerProvider();
    expect(p.repeatMode, PlayerRepeatMode.off);
    p.cycleRepeatMode();
    expect(p.repeatMode, PlayerRepeatMode.all);
    p.cycleRepeatMode();
    expect(p.repeatMode, PlayerRepeatMode.one);
    p.cycleRepeatMode();
    expect(p.repeatMode, PlayerRepeatMode.off);
  });

  test('shuffle toggles', () {
    final p = AudioPlayerProvider();
    expect(p.shuffleEnabled, false);
    // No playlist: toggle is no-op
    p.toggleShuffle();
    expect(p.shuffleEnabled, false);
  });
}
