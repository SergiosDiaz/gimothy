#!/bin/bash
set -e

echo "================================================"
echo "  GIMOTHY - Setup iOS para Xcode"
echo "================================================"
echo ""

# 1. Verificar Flutter
if ! command -v flutter &> /dev/null; then
  echo "ERROR: Flutter no está instalado o no está en el PATH"
  echo "Instálalo desde https://docs.flutter.dev/get-started/install/macos"
  exit 1
fi

# 2. Verificar CocoaPods
if ! command -v pod &> /dev/null; then
  echo "CocoaPods no encontrado. Instalando..."
  sudo gem install cocoapods
fi

echo "Flutter: $(flutter --version | head -1)"
echo "CocoaPods: $(pod --version)"
echo ""

# 3. Obtener dependencias Dart
echo "[1/3] Descargando dependencias Flutter..."
flutter pub get

# 4. Instalar pods
echo ""
echo "[2/3] Instalando CocoaPods..."
cd ios
pod install --repo-update
cd ..

echo ""
echo "[3/3] Listo!"
echo ""
echo "================================================"
echo "  Abre el proyecto en Xcode con:"
echo ""
echo "  open ios/Runner.xcworkspace"
echo ""
echo "  IMPORTANTE: Abre Runner.xcworkspace"
echo "  NO abras Runner.xcodeproj"
echo "================================================"
echo ""
echo "  Pasos en Xcode:"
echo "  1. Selecciona el target 'Runner'"
echo "  2. Ve a Signing & Capabilities"
echo "  3. Pon tu Team (Apple Developer Account)"
echo "  4. Pulsa Product > Run"
echo "================================================"
