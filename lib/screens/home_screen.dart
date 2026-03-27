import 'dart:async';

import 'package:flutter/material.dart';

import '../models/moan_type.dart';
import '../services/shake_detector.dart';
import '../services/sound_service.dart';
import '../widgets/reaction_emote.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SoundService _soundService = SoundService();
  late ShakeDetector _shakeDetector;
  bool _isReacting = false;
  Timer? _resetTimer;
  int _hitCount = 0;

  @override
  void initState() {
    super.initState();
    _soundService.init();
    _shakeDetector = ShakeDetector(onShake: _onShake);
    _shakeDetector.start();
  }

  void _onShake() {
    _soundService.playMoan();
    setState(() {
      _isReacting = true;
      _hitCount++;
    });
    _resetTimer?.cancel();
    _resetTimer = Timer(const Duration(milliseconds: 900), () {
      if (mounted) {
        setState(() => _isReacting = false);
      }
    });
  }

  void _openSettings() async {
    _shakeDetector.stop();
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
    // Refrescar tipo al volver
    setState(() {});
    _shakeDetector.start();
  }

  @override
  void dispose() {
    _shakeDetector.stop();
    _resetTimer?.cancel();
    _soundService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final moanType = _soundService.currentType;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      body: SafeArea(
        child: Stack(
          children: [
            // Fondo animado
            _buildBackground(moanType),

            // Contenido principal
            Column(
              children: [
                _buildTopBar(moanType),
                Expanded(child: _buildCenter(moanType)),
                _buildBottomHint(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground(MoanType type) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: _isReacting ? 1.2 : 0.6,
          colors: [
            _bgGlowColor(type).withValues(alpha: _isReacting ? 0.25 : 0.05),
            const Color(0xFF0D0D1A),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(MoanType type) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'GIMOTHY',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4,
                ),
              ),
              Text(
                '${type.emoji} ${type.displayName}',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 13,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: _openSettings,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white12),
              ),
              child: const Icon(
                Icons.tune_rounded,
                color: Colors.white70,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenter(MoanType type) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ReactionEmote(isReacting: _isReacting, moanType: type),
        const SizedBox(height: 32),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            _isReacting ? _reactionText(type) : '¡Golpéame!',
            key: ValueKey(_isReacting),
            style: TextStyle(
              color: _isReacting ? _bgGlowColor(type) : Colors.white38,
              fontSize: _isReacting ? 26 : 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (_hitCount > 0)
          Text(
            '$_hitCount ${_hitCount == 1 ? 'golpe' : 'golpes'}',
            style: const TextStyle(
              color: Colors.white24,
              fontSize: 13,
              letterSpacing: 1,
            ),
          ),
      ],
    );
  }

  Widget _buildBottomHint() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.vibration, color: Colors.white24, size: 14),
          const SizedBox(width: 6),
          const Text(
            'Agita o golpea el móvil',
            style: TextStyle(color: Colors.white24, fontSize: 12),
          ),
        ],
      ),
    );
  }

  String _reactionText(MoanType type) {
    switch (type) {
      case MoanType.suave:
        return '~ mmmmm ~';
      case MoanType.intenso:
        return '¡OH!';
      case MoanType.dramatico:
        return '¡AAAHHH!';
      case MoanType.timido:
        return '...mm...';
      case MoanType.robusto:
        return 'UGH!';
    }
  }

  Color _bgGlowColor(MoanType type) {
    switch (type) {
      case MoanType.suave:
        return Colors.pink.shade300;
      case MoanType.intenso:
        return Colors.orange.shade400;
      case MoanType.dramatico:
        return Colors.purple.shade300;
      case MoanType.timido:
        return Colors.blue.shade300;
      case MoanType.robusto:
        return Colors.red.shade400;
    }
  }
}
