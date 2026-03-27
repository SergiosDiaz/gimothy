import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

import '../models/moan_type.dart';
import 'sound_generator.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  MoanType _currentType = MoanType.suave;

  MoanType get currentType => _currentType;

  Future<void> init() async {
    await _player.setVolume(1.0);
    _player.onPlayerComplete.listen((_) {
      _isPlaying = false;
    });
  }

  void setMoanType(MoanType type) {
    _currentType = type;
  }

  Future<void> playMoan() async {
    if (_isPlaying) {
      await _player.stop();
    }
    _isPlaying = true;
    final bytes = SoundGenerator.generateMoan(_currentType);
    await _player.play(BytesSource(bytes));
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}
