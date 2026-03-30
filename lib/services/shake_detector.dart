import 'dart:async';
import 'dart:math';

import 'package:sensors_plus/sensors_plus.dart';

class ShakeDetector {
  static const double _shakeThreshold = 8.0;
  static const int _cooldownMs = 400;

  final VoidCallback onShake;
  StreamSubscription<AccelerometerEvent>? _subscription;
  DateTime? _lastShake;

  ShakeDetector({required this.onShake});

  void start() {
    _subscription = accelerometerEventStream(
      samplingPeriod: SensorInterval.gameInterval,
    ).listen(_onAccelerometer);
  }

  void _onAccelerometer(AccelerometerEvent event) {
    final magnitude = sqrt(
      event.x * event.x + event.y * event.y + event.z * event.z,
    );
    final net = (magnitude - 9.81).abs();

    if (net > _shakeThreshold) {
      final now = DateTime.now();
      if (_lastShake == null ||
          now.difference(_lastShake!).inMilliseconds > _cooldownMs) {
        _lastShake = now;
        onShake();
      }
    }
  }

  void stop() {
    _subscription?.cancel();
    _subscription = null;
  }
}

typedef VoidCallback = void Function();
