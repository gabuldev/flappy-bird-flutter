# Flappy Bird Flutter

A Flutter implementation of the classic Flappy Bird game, demonstrating Flutter's 2D rendering capabilities with CustomPainter and game loop optimization.

## 🎮 Play Online

**[Play the game here!](https://gabuldev.github.io/flappy-bird-flutter/)**

## Features

- Smooth 60 FPS gameplay with CustomPainter rendering
- Physics-based bird movement with gravity and jump mechanics
- Procedurally generated pipe obstacles
- Score tracking with persistent high score
- Responsive controls (touch, mouse, keyboard)
- Performance optimizations with object pooling
- Cross-platform support (Web, Mobile, Desktop)

## Getting Started

### Prerequisites

- Flutter SDK (3.24.0 or later)
- Dart SDK
- Web browser for web version

### Installation

1. Clone the repository:

```bash
git clone https://github.com/gabuldev/flappy-bird-flutter.git
cd flappy-bird-flutter
```

2. Install dependencies:

```bash
flutter pub get
```

3. Run the app:

```bash
# For web
flutter run -d chrome

# For mobile (with device/emulator connected)
flutter run

# For desktop
flutter run -d windows  # or macos/linux
```

### Building for Production

#### Web Build

```bash
flutter build web --base-href "/flappy-bird-flutter/"
```

#### Mobile Build

```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

## Architecture

The game follows a clean architecture pattern with:

- **Models**: Bird, Pipe, GameState - Core game entities
- **Controllers**: GameController - Game logic and state management
- **Screens**: GameRenderer - CustomPainter for 2D rendering
- **Utils**: Physics, PipePool - Game utilities and optimizations

## Performance Optimizations

- Object pooling for pipe reuse
- Dirty region updates in CustomPainter
- Optimized collision detection
- Frame rate monitoring and adjustment

## Testing

Run the test suite:

```bash
flutter test
```

## Deployment

The game is automatically deployed to GitHub Pages via GitHub Actions on every push to the main branch.

### Manual Deployment

1. Build the web version:

```bash
flutter build web --base-href "/flappy-bird-flutter/"
```

2. Deploy the `build/web` directory to your hosting service.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## License

This project is open source and available under the [MIT License](LICENSE).
