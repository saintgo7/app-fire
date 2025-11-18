#!/bin/bash

# Development 환경 빌드 스크립트

echo "🔨 Building for DEVELOPMENT environment..."
echo ""

# Android
echo "📱 Building Android APK (dev)..."
flutter build apk --dart-define=ENV=dev --debug

echo ""
echo "✅ Build complete!"
echo "📦 APK location: build/app/outputs/flutter-apk/app-debug.apk"
echo ""
echo "🚀 Install command:"
echo "   flutter install"
