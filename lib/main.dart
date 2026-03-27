import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/moan_type.dart';
import 'screens/home_screen.dart';
import 'services/sound_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Orientación fija vertical
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Barra de estado oscura
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarBrightness: Brightness.dark,
    statusBarIconBrightness: Brightness.light,
  ));

  // Cargar preferencia guardada
  final prefs = await SharedPreferences.getInstance();
  final savedIndex = prefs.getInt('moan_type') ?? 0;
  final savedType = MoanType.values[savedIndex.clamp(0, MoanType.values.length - 1)];
  SoundService().setMoanType(savedType);

  runApp(const GimothyApp());
}

class GimothyApp extends StatelessWidget {
  const GimothyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gimothy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        fontFamily: 'SF Pro Display',
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
