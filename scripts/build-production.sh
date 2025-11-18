#!/bin/bash

# Production 환경 빌드 스크립트

echo "🔨 Building for PRODUCTION environment..."
echo ""

# Android
echo "📱 Building Android App Bundle (production)..."
flutter build appbundle --dart-define=ENV=production --release

echo ""
echo "✅ Build complete!"
echo "📦 AAB location: build/app/outputs/bundle/release/app-release.aab"
echo ""
echo "🚀 Next steps:"
echo "   1. Upload to Google Play Console"
echo "   2. Create a release"
echo ""
echo "⚠️  Remember to:"
echo "   - Test thoroughly before release"
echo "   - Update version in pubspec.yaml"
echo "   - Create release notes"
