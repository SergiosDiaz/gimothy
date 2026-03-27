import 'dart:math';
import 'dart:typed_data';

import '../models/moan_type.dart';

class SoundGenerator {
  static const int _sampleRate = 22050;

  static Uint8List generateMoan(MoanType type) {
    switch (type) {
      case MoanType.suave:
        return _generateSuave();
      case MoanType.intenso:
        return _generateIntenso();
      case MoanType.dramatico:
        return _generateDramatico();
      case MoanType.timido:
        return _generateTimido();
      case MoanType.robusto:
        return _generateRobusto();
    }
  }

  // Suave: frecuencia media que sube suavemente, vibrato lento
  static Uint8List _generateSuave() {
    const duration = 1.6;
    final samples = _generateSamples(
      duration: duration,
      baseFreq: (t, p) => 220 + 60 * p,
      vibrato: (t) => 8 * sin(2 * pi * 4 * t),
      harmonics: [1.0, 0.4, 0.15, 0.05],
      envelope: _smoothEnvelope,
    );
    return _buildWav(samples);
  }

  // Intenso: frecuencia alta que sube rápido con vibrato agresivo
  static Uint8List _generateIntenso() {
    const duration = 1.2;
    final samples = _generateSamples(
      duration: duration,
      baseFreq: (t, p) => 320 + 180 * sin(pi * p),
      vibrato: (t) => 18 * sin(2 * pi * 7 * t),
      harmonics: [1.0, 0.6, 0.3, 0.1],
      envelope: _sharpEnvelope,
    );
    return _buildWav(samples);
  }

  // Dramático: sweep descendente largo y teatral
  static Uint8List _generateDramatico() {
    const duration = 2.2;
    final samples = _generateSamples(
      duration: duration,
      baseFreq: (t, p) => 450 - 250 * p,
      vibrato: (t) => 12 * sin(2 * pi * 5.5 * t),
      harmonics: [1.0, 0.5, 0.25, 0.12, 0.06],
      envelope: _dramaticEnvelope,
    );
    return _buildWav(samples);
  }

  // Tímido: frecuencia baja, corto, muy suave
  static Uint8List _generateTimido() {
    const duration = 0.7;
    final samples = _generateSamples(
      duration: duration,
      baseFreq: (t, p) => 260 + 20 * sin(pi * p),
      vibrato: (t) => 4 * sin(2 * pi * 5 * t),
      harmonics: [1.0, 0.2, 0.05],
      envelope: _shyEnvelope,
    );
    return _buildWav(samples);
  }

  // Robusto: frecuencia grave y profunda
  static Uint8List _generateRobusto() {
    const duration = 1.8;
    final samples = _generateSamples(
      duration: duration,
      baseFreq: (t, p) => 110 + 40 * sin(pi * p * 0.5),
      vibrato: (t) => 6 * sin(2 * pi * 3 * t),
      harmonics: [1.0, 0.7, 0.4, 0.2, 0.1],
      envelope: _robustEnvelope,
    );
    return _buildWav(samples);
  }

  static Int16List _generateSamples({
    required double duration,
    required double Function(double t, double progress) baseFreq,
    required double Function(double t) vibrato,
    required List<double> harmonics,
    required double Function(double progress) envelope,
  }) {
    final numSamples = (_sampleRate * duration).round();
    final samples = Int16List(numSamples);
    double phase = 0;

    for (int i = 0; i < numSamples; i++) {
      final t = i / _sampleRate;
      final progress = i / numSamples;
      final freq = baseFreq(t, progress) + vibrato(t);
      final amp = envelope(progress);

      double sample = 0;
      for (int h = 0; h < harmonics.length; h++) {
        sample += harmonics[h] * sin(phase * (h + 1));
      }

      final totalHarmonicWeight = harmonics.reduce((a, b) => a + b);
      sample = (sample / totalHarmonicWeight) * amp;

      // Pequeño ruido para naturalidad
      sample += (Random().nextDouble() - 0.5) * 0.015 * amp;

      samples[i] = (sample * 28000).round().clamp(-32767, 32767);
      phase += 2 * pi * freq / _sampleRate;
    }

    return samples;
  }

  // Envolventes de amplitud
  static double _smoothEnvelope(double p) {
    if (p < 0.12) return p / 0.12;
    if (p > 0.75) return (1 - p) / 0.25;
    return 1.0;
  }

  static double _sharpEnvelope(double p) {
    if (p < 0.05) return p / 0.05;
    if (p > 0.6) return pow((1 - p) / 0.4, 0.6).toDouble();
    return 1.0;
  }

  static double _dramaticEnvelope(double p) {
    if (p < 0.08) return p / 0.08;
    if (p > 0.5) return pow((1 - p) / 0.5, 0.4).toDouble();
    return 1.0;
  }

  static double _shyEnvelope(double p) {
    if (p < 0.15) return p / 0.15;
    if (p > 0.5) return (1 - p) / 0.5;
    return 0.6;
  }

  static double _robustEnvelope(double p) {
    if (p < 0.15) return pow(p / 0.15, 0.5).toDouble();
    if (p > 0.8) return (1 - p) / 0.2;
    return 1.0;
  }

  static Uint8List _buildWav(Int16List samples) {
    final dataSize = samples.length * 2;
    final fileSize = 44 + dataSize;
    final buffer = ByteData(fileSize);
    int offset = 0;

    void writeString(String s) {
      for (final c in s.codeUnits) {
        buffer.setUint8(offset++, c);
      }
    }

    void writeUint32(int v) {
      buffer.setUint32(offset, v, Endian.little);
      offset += 4;
    }

    void writeUint16(int v) {
      buffer.setUint16(offset, v, Endian.little);
      offset += 2;
    }

    writeString('RIFF');
    writeUint32(fileSize - 8);
    writeString('WAVE');
    writeString('fmt ');
    writeUint32(16);
    writeUint16(1); // PCM
    writeUint16(1); // mono
    writeUint32(_sampleRate);
    writeUint32(_sampleRate * 2); // byteRate
    writeUint16(2); // blockAlign
    writeUint16(16); // bitsPerSample
    writeString('data');
    writeUint32(dataSize);

    for (final sample in samples) {
      buffer.setInt16(offset, sample, Endian.little);
      offset += 2;
    }

    return buffer.buffer.asUint8List();
  }
}
