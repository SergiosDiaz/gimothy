import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/moan_type.dart';
import '../services/sound_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SoundService _soundService = SoundService();
  MoanType _selected = MoanType.suave;

  @override
  void initState() {
    super.initState();
    _selected = _soundService.currentType;
  }

  Future<void> _selectType(MoanType type) async {
    setState(() => _selected = type);
    _soundService.setMoanType(type);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('moan_type', type.index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_back_ios_new, color: Colors.white70, size: 18),
          ),
        ),
        title: const Text(
          'OPCIONES',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: 4,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tipo de gemido',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 13,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  itemCount: MoanType.values.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final type = MoanType.values[index];
                    final isSelected = type == _selected;
                    return _MoanTypeCard(
                      type: type,
                      isSelected: isSelected,
                      onTap: () => _selectType(type),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoanTypeCard extends StatelessWidget {
  final MoanType type;
  final bool isSelected;
  final VoidCallback onTap;

  const _MoanTypeCard({
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  Color get _accentColor {
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isSelected
              ? _accentColor.withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? _accentColor : Colors.white12,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: _accentColor.withValues(alpha: 0.2), blurRadius: 20)]
              : [],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: _accentColor.withValues(alpha: isSelected ? 0.25 : 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(type.emoji, style: const TextStyle(fontSize: 26)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    type.displayName,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    type.description,
                    style: TextStyle(
                      color: isSelected ? Colors.white54 : Colors.white30,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: _accentColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 14),
              ),
          ],
        ),
      ),
    );
  }
}
