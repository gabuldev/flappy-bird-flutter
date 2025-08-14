# Deployment Guide - Flappy Bird Flutter

This document explains how to deploy the Flappy Bird Flutter game to GitHub Pages.

## 🚀 Automatic Deployment (Recommended)

The project is configured with GitHub Actions for automatic deployment. Every push to the `main` branch will:

1. Run all tests
2. Build the Flutter web version
3. Deploy to GitHub Pages automatically

### Setup GitHub Pages

1. Go to your repository on GitHub
2. Navigate to **Settings** → **Pages**
3. Under **Source**, select **Deploy from a branch**
4. Choose **gh-pages** branch and **/ (root)** folder
5. Click **Save**

The game will be available at: `https://[username].github.io/[repository-name]/`

## 🛠️ Manual Deployment

### Prerequisites

- Flutter SDK (3.24.0 or later)
- Git configured with GitHub access
- Repository with GitHub Pages enabled

### Steps

1. **Build the web version:**

   ```bash
   flutter build web --base-href "/flappy-bird-flutter/"
   ```

2. **Use the deployment script:**

   ```bash
   cd flappy_bird_flutter
   ./scripts/deploy.sh
   ```

   Or manually:

   ```bash
   # From the flappy_bird_flutter directory
   cd flappy_bird_flutter

   # Install dependencies
   flutter pub get

   # Run tests
   flutter test

   # Build for web
   flutter build web --base-href "/flappy-bird-flutter/"

   # Go back to repository root and commit
   cd ..
   git add .
   git commit -m "Deploy: Update web build"
   git push origin main
   ```

## 📁 Project Structure for Deployment

```
repository-root/
├── .github/
│   └── workflows/
│       └── deploy.yml          # GitHub Actions workflow
├── flappy_bird_flutter/
│   ├── build/
│   │   └── web/                # Generated web build (not committed)
│   ├── scripts/
│   │   └── deploy.sh           # Deployment helper script
│   ├── web/
│   │   ├── index.html          # Web entry point
│   │   ├── manifest.json       # PWA manifest
│   │   └── icons/              # App icons
│   └── DEPLOYMENT.md           # This file
├── .nojekyll                   # Prevents Jekyll processing
└── 404.html                    # Custom 404 page
```

## 🔧 Configuration Details

### GitHub Actions Workflow

The `.github/workflows/deploy.yml` file:

- Triggers on pushes to `main` branch
- Sets up Flutter environment
- Runs tests before deployment
- Builds web version with correct base href
- Deploys to `gh-pages` branch using `peaceiris/actions-gh-pages`

### Base HREF Configuration

The web build uses `--base-href "/flappy-bird-flutter/"` to ensure:

- Assets load correctly from the GitHub Pages subdirectory
- Routing works properly
- The app functions correctly when not served from root domain

### Web Configuration

Key files for web deployment:

- `web/index.html`: Contains `<base href="$FLUTTER_BASE_HREF">` placeholder
- `web/manifest.json`: PWA configuration
- `web/icons/`: App icons for different sizes

## 🐛 Troubleshooting

### Common Issues

1. **404 Error on GitHub Pages**

   - Check that GitHub Pages is enabled in repository settings
   - Verify the `gh-pages` branch exists and has content
   - Ensure the base href matches your repository name

2. **Assets Not Loading**

   - Verify the base href is correct: `/repository-name/`
   - Check that the build completed successfully
   - Ensure all assets are in the `build/web` directory

3. **GitHub Actions Failing**
   - Check the Actions tab in your GitHub repository
   - Verify Flutter version compatibility
   - Ensure tests are passing locally

### Debug Steps

1. **Test locally:**

   ```bash
   flutter build web --base-href "/flappy-bird-flutter/"
   cd build/web
   python -m http.server 8000
   # Visit http://localhost:8000
   ```

2. **Check GitHub Actions logs:**

   - Go to repository → Actions tab
   - Click on the latest workflow run
   - Review build and deploy logs

3. **Verify deployment:**
   - Check the `gh-pages` branch has the latest build files
   - Ensure `index.html` and assets are present

## 🌐 Live Demo

Once deployed, your game will be available at:
**https://gabuldev.github.io/flappy-bird-flutter/**

## 📝 Notes

- The deployment process takes 2-5 minutes after pushing to main
- GitHub Pages may take additional time to update (up to 10 minutes)
- The game works offline once loaded (PWA capabilities)
- All Flutter web features are supported including touch, mouse, and keyboard input

## 🔄 Updating the Deployment

To update the deployed version:

1. Make your changes
2. Commit and push to `main` branch
3. GitHub Actions will automatically rebuild and deploy
4. Wait for the deployment to complete

The deployment status can be monitored in the GitHub Actions tab of your repository.
