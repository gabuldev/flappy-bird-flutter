#!/bin/bash

# Deploy script for Flappy Bird Flutter to GitHub Pages

echo "🚀 Starting deployment process..."

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ Error: pubspec.yaml not found. Please run this script from the Flutter project root."
    exit 1
fi

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Error: Flutter is not installed or not in PATH."
    exit 1
fi

echo "📦 Installing dependencies..."
flutter pub get

echo "🧪 Running tests..."
flutter test
if [ $? -ne 0 ]; then
    echo "❌ Tests failed. Deployment aborted."
    exit 1
fi

echo "🏗️ Building web version..."
flutter build web --base-href "/flappy-bird-flutter/"
if [ $? -ne 0 ]; then
    echo "❌ Build failed. Deployment aborted."
    exit 1
fi

echo "📤 Committing and pushing changes..."
git add .
git commit -m "Deploy: Update web build $(date '+%Y-%m-%d %H:%M:%S')"
git push origin main

echo "✅ Deployment initiated! Check GitHub Actions for progress."
echo "🌐 Your game will be available at: https://gabuldev.github.io/flappy-bird-flutter/"
echo "⏱️ It may take a few minutes for changes to appear."