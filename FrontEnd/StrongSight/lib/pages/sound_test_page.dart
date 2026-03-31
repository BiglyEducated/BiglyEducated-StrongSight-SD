import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class SoundTestPage extends StatefulWidget {
  const SoundTestPage({super.key});

  @override
  State<SoundTestPage> createState() => _SoundTestPageState();
}

class _SoundTestPageState extends State<SoundTestPage> {
  final _player = AudioPlayer();
  Timer? _timer;
  String _status = 'Idle';
  bool _looping = false;

  // IMPORTANT: do NOT include "assets/" here
  static const goodPath = 'audio/good_rep.mp3';
  static const badPath = 'audio/bad_rep.mp3';

  Future<void> _systemTest() async {
    SystemSound.play(SystemSoundType.click);
    HapticFeedback.lightImpact();
    setState(() => _status = 'System click + haptic fired (if you felt/heard it, iOS output works)');
  }

  Future<void> _playAsset(String path) async {
    try {
      await _player.stop();
      await _player.play(AssetSource(path));
      setState(() => _status = 'Played asset: $path');
      // ignore: avoid_print
      print('✅ Played asset: $path');
    } catch (e) {
      setState(() => _status = '❌ Play failed: $e');
      // ignore: avoid_print
      print('❌ Play failed: $e');
    }
  }

  void _toggleLoop() {
    if (_looping) {
      _timer?.cancel();
      _timer = null;
      setState(() {
        _looping = false;
        _status = 'Loop stopped';
      });
      return;
    }

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      // ignore: avoid_print
      print('🔊 LOOP tick - playing GOOD');
      _playAsset(goodPath);
    });

    setState(() {
      _looping = true;
      _status = 'Loop running: GOOD every 2s';
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sound Test')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(_status),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _systemTest,
              child: const Text('1) System click test (no assets)'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _playAsset(goodPath),
              child: const Text('2) Play GOOD asset'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _playAsset(badPath),
              child: const Text('3) Play BAD asset'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _toggleLoop,
              child: Text(_looping ? 'Stop Loop' : '4) Loop GOOD every 2s'),
            ),
          ],
        ),
      ),
    );
  }
}
