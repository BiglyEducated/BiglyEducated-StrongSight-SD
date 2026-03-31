import 'package:audio_session/audio_session.dart';
// Hide audioplayers' AudioContext + AVAudioSessionCategory symbols to avoid collision
import 'package:audioplayers/audioplayers.dart'
    hide AudioContext, AVAudioSessionCategory, AVAudioSessionCategoryOptions, AVAudioSessionMode;

class RepSoundService {
  final AudioPlayer _good = AudioPlayer(playerId: 'good');
  final AudioPlayer _bad = AudioPlayer(playerId: 'bad');

  bool _ready = false;

  Future<void> preload() async {
    try {
      final session = await AudioSession.instance;

      // Don't use const here - avoids any const-expression issues across versions.
      await session.configure(AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playback,
        avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.mixWithOthers,
        avAudioSessionMode: AVAudioSessionMode.defaultMode,
      ));

      await _good.setReleaseMode(ReleaseMode.stop);
      await _bad.setReleaseMode(ReleaseMode.stop);

      // IMPORTANT: no "assets/" prefix
      await _good.setSource(AssetSource('audio/good_rep.mp3'));
      await _bad.setSource(AssetSource('audio/bad_rep.mp3'));

      _ready = true;
      // ignore: avoid_print
      print('✅ RepSoundService: preload ok');
    } catch (e) {
      _ready = false;
      // ignore: avoid_print
      print('❌ RepSoundService: preload failed: $e');
    }
  }

  Future<void> playGood() async {
    if (!_ready) return;
    try {
      await _good.stop();
      await _good.resume();
    } catch (e) {
      // ignore: avoid_print
      print('❌ RepSoundService: playGood failed: $e');
    }
  }

  Future<void> playBad() async {
    if (!_ready) return;
    try {
      await _bad.stop();
      await _bad.resume();
    } catch (e) {
      // ignore: avoid_print
      print('❌ RepSoundService: playBad failed: $e');
    }
  }

  Future<void> dispose() async {
    try {
      await _good.dispose();
      await _bad.dispose();
    } catch (_) {}
  }
}
