import 'package:audioplayers/audioplayers.dart';

import '../models/moan_type.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final AudioPlayer _player = AudioPlayer();
  MoanType _currentType = MoanType.suave;

  MoanType get currentType => _currentType;

  Future<void> init() async {
    await _player.setVolume(1.0);
  }

  void setMoanType(MoanType type) {
    _currentType = type;
  }

  Future<void> playMoan() async {
    await _player.stop();
    await _player.play(AssetSource(_assetPath(_currentType)));
  }

  String _assetPath(MoanType type) {
    switch (type) {
      case MoanType.suave:
        return 'assets/sounds/suave.mp3';
      case MoanType.intenso:
        return 'assets/sounds/intenso.mp3';
      case MoanType.dramatico:
        return 'assets/sounds/dramatico.mp3';
      case MoanType.timido:
        return 'assets/sounds/timido.mp3';
      case MoanType.robusto:
        return 'assets/sounds/robusto.mp3';
    }
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}
