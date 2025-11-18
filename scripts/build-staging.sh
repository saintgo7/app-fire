#!/bin/bash

# Staging 환경 빌드 스크립트

echo "🔨 Building for STAGING environment..."
echo ""

# Android
echo "📱 Building Android APK (staging)..."
flutter build apk --dart-define=ENV=staging --release

echo ""
echo "✅ Build complete!"
echo "📦 APK location: build/app/outputs/flutter-apk/app-release.apk"
echo ""
echo "🚀 Install command:"
echo "   adb install build/app/outputs/flutter-apk/app-release.apk"
