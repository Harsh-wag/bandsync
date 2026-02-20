import 'dart:async';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class Metronome {
  Timer? _timer;
  bool _isPlaying = false;
  int _bpm = 120;
  final Function(bool) onBeat;
  final AudioPlayer _audioPlayer = AudioPlayer();

  Metronome({required this.onBeat}) {
    _audioPlayer.setReleaseMode(ReleaseMode.stop);
    _audioPlayer.setVolume(1.0);
  }

  bool get isPlaying => _isPlaying;
  int get bpm => _bpm;

  void start(int bpm) {
    _bpm = bpm;
    _isPlaying = true;
    final interval = Duration(milliseconds: (60000 / bpm).round());
    _timer = Timer.periodic(interval, (_) {
      HapticFeedback.lightImpact();
      _audioPlayer.play(AssetSource('click.mp3.mp3'));
      onBeat(true);
    });
  }

  void stop() {
    _isPlaying = false;
    _timer?.cancel();
    _timer = null;
    _audioPlayer.stop();
  }

  void dispose() {
    stop();
    _audioPlayer.dispose();
  }
}
