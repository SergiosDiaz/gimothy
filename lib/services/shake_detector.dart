import 'dart:async';
import 'dart:math';

import 'package:sensors_plus/sensors_plus.dart';

class ShakeDetector {
  // Umbral para considerar que empieza un impacto
  static const double _peakThreshold = 10.0;
  // Si baja de este valor, el impacto ha terminado
  static const double _decayThreshold = 6.0;
  // Si el pico dura más de esto, es una agitación (no un golpe)
  static const int _maxSlapDurationMs = 220;
  static const int _cooldownMs = 450;

  final VoidCallback onShake;
  StreamSubscription<AccelerometerEvent>? _subscription;
  DateTime? _lastSlap;
  DateTime? _spikeStart;
  bool _inSpike = false;

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
    final now = DateTime.now();

    if (!_inSpike && net > _peakThreshold) {
      // Comienza un pico de aceleración
      _inSpike = true;
      _spikeStart = now;
    } else if (_inSpike) {
      final spikeDuration = now.difference(_spikeStart!).inMilliseconds;

      if (net < _decayThreshold) {
        // El pico bajó rápido → es un golpe
        if (spikeDuration < _maxSlapDurationMs) {
          if (_lastSlap == null ||
              now.difference(_lastSlap!).inMilliseconds > _cooldownMs) {
            _lastSlap = now;
            onShake();
          }
        }
        _inSpike = false;
      } else if (spikeDuration > _maxSlapDurationMs) {
        // El pico se sostiene demasiado → es una agitación, ignorar
        _inSpike = false;
      }
    }
  }

  void stop() {
    _subscription?.cancel();
    _subscription = null;
    _inSpike = false;
    _spikeStart = null;
  }
}

typedef VoidCallback = void Function();
