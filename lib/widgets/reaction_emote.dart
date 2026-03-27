import 'dart:math';

import 'package:flutter/material.dart';

import '../models/moan_type.dart';

class ReactionEmote extends StatefulWidget {
  final bool isReacting;
  final MoanType moanType;

  const ReactionEmote({
    super.key,
    required this.isReacting,
    required this.moanType,
  });

  @override
  State<ReactionEmote> createState() => _ReactionEmoteState();
}

class _ReactionEmoteState extends State<ReactionEmote>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _shakeController;
  late AnimationController _glowController;
  late Animation<double> _glowAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.4), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.4, end: 0.9), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.0), weight: 40),
    ]).animate(CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut));

    _glowAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(ReactionEmote oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isReacting && !oldWidget.isReacting) {
      _triggerReaction();
    }
  }

  void _triggerReaction() {
    _bounceController.forward(from: 0);
    _shakeController.forward(from: 0);
    _glowController.forward(from: 0).then((_) => _glowController.reverse());
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _shakeController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  String get _currentEmoji {
    if (!widget.isReacting) return '😐';
    switch (widget.moanType) {
      case MoanType.suave:
        return '😮';
      case MoanType.intenso:
        return '😩';
      case MoanType.dramatico:
        return '🤯';
      case MoanType.timido:
        return '😳';
      case MoanType.robusto:
        return '😤';
    }
  }

  Color get _glowColor {
    switch (widget.moanType) {
      case MoanType.suave:
        return Colors.pink.shade300;
      case MoanType.intenso:
        return Colors.orange.shade400;
      case MoanType.dramatico:
        return Colors.purple.shade400;
      case MoanType.timido:
        return Colors.blue.shade300;
      case MoanType.robusto:
        return Colors.red.shade400;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_bounceController, _shakeController, _glowController]),
      builder: (context, child) {
        final shakeOffset = widget.isReacting
            ? sin(_shakeController.value * pi * 8) * 12 * (1 - _shakeController.value)
            : 0.0;

        return Transform.translate(
          offset: Offset(shakeOffset, 0),
          child: Transform.scale(
            scale: _bounceController.isAnimating ? _scaleAnim.value : 1.0,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _glowColor.withValues(alpha: _glowAnim.value * 0.7),
                    blurRadius: 50 * _glowAnim.value,
                    spreadRadius: 20 * _glowAnim.value,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  _currentEmoji,
                  style: const TextStyle(fontSize: 100),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
