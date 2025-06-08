#!/bin/bash

echo "📦 Flutter iOS Build Fix Script Starting..."

# Step 1: Go to Flutter project root
echo "🔍 Checking for pubspec.yaml..."
if [ ! -f "pubspec.yaml" ]; then
  echo "❌ Error: Run this script from your Flutter project root."
  exit 1
fi

# Step 2: Flutter Clean
echo "🧹 Running flutter clean..."
flutter clean

# Step 3: Pub Get
echo "📥 Fetching pub dependencies..."
flutter pub get

# Step 4: Delete old iOS build folders
echo "🧽 Cleaning iOS build, Pods, and Podfile.lock..."
cd ios || exit 1
rm -rf Pods Podfile.lock Flutter/Flutter.podspec
rm -rf .symlinks

# Step 5: Pod Install
echo "🔧 Installing CocoaPods..."
pod install || arch -x86_64 pod install

# Step 6: Go back and rebuild iOS
cd ..
echo "🏗️ Building iOS..."
flutter build ios

# Step 7: Re-open in Xcode
echo "🚀 Opening Xcode workspace..."
open ios/Runner.xcworkspace

echo "✅ Done! Now use Product > Archive in Xcode to create the App Store build."
