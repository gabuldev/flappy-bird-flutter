#!/bin/bash

# Manual deployment script for Flappy Bird Flutter to GitHub Pages

echo "🚀 Starting manual deployment process..."

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ Error: pubspec.yaml not found. Please run this script from the Flutter project root (flappy_bird_flutter folder)."
    exit 1
fi

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Error: Flutter is not installed or not in PATH."
    exit 1
fi

echo "📦 Installing dependencies..."
flutter pub get

echo "🏗️ Building web version..."
flutter build web --base-href "/flappy-bird-flutter/"
if [ $? -ne 0 ]; then
    echo "❌ Build failed. Deployment aborted."
    exit 1
fi

echo "📁 Preparing deployment files..."
cd ..  # Go to repository root

# Create a temporary directory for the build
TEMP_DIR=$(mktemp -d)
cp -r flappy_bird_flutter/build/web/* "$TEMP_DIR/"

# Check if gh-pages branch exists
if git show-ref --verify --quiet refs/heads/gh-pages; then
    echo "📋 Switching to existing gh-pages branch..."
    git checkout gh-pages
else
    echo "🌿 Creating new gh-pages branch..."
    git checkout --orphan gh-pages
    git rm -rf .
fi

# Copy build files to root
cp -r "$TEMP_DIR"/* .

# Add .nojekyll file
touch .nojekyll

# Add custom 404 page
cat > 404.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Page Not Found - Flappy Bird Flutter</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            text-align: center;
            padding: 50px;
            background: linear-gradient(135deg, #87CEEB 0%, #98FB98 100%);
            min-height: 100vh;
            margin: 0;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
        }
        .container {
            background: white;
            padding: 40px;
            border-radius: 20px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.2);
            max-width: 500px;
        }
        h1 {
            color: #333;
            font-size: 3em;
            margin-bottom: 20px;
        }
        p {
            color: #666;
            font-size: 1.2em;
            margin-bottom: 30px;
        }
        .bird {
            font-size: 4em;
            margin: 20px 0;
            animation: fly 2s ease-in-out infinite;
        }
        @keyframes fly {
            0%, 100% { transform: translateY(0px); }
            50% { transform: translateY(-20px); }
        }
        .btn {
            background: #4CAF50;
            color: white;
            padding: 15px 30px;
            border: none;
            border-radius: 25px;
            font-size: 1.1em;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
            transition: background 0.3s;
        }
        .btn:hover {
            background: #45a049;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="bird">🐦</div>
        <h1>404</h1>
        <p>Oops! This page flew away like our little bird!</p>
        <p>The page you're looking for doesn't exist.</p>
        <a href="/flappy-bird-flutter/" class="btn">🎮 Play Flappy Bird</a>
    </div>
</body>
</html>
EOF

echo "📤 Committing and pushing to gh-pages..."
git add .
git commit -m "Deploy: Manual deployment $(date '+%Y-%m-%d %H:%M:%S')"
git push origin gh-pages

echo "🔄 Switching back to main branch..."
git checkout main

# Clean up
rm -rf "$TEMP_DIR"

echo "✅ Manual deployment completed!"
echo "🌐 Your game will be available at: https://gabuldev.github.io/flappy-bird-flutter/"
echo "⏱️ It may take a few minutes for changes to appear on GitHub Pages."