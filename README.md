# Flappy Bird Flutter

A Flutter implementation of the classic Flappy Bird game, demonstrating Flutter's 2D rendering capabilities with CustomPainter and game loop optimization.

## 🎮 Play Online

**[🎮 Play the game here!](https://gabuldev.github.io/flappy-bird-flutter/)**

## 📁 Project Structure

```
repository-root/
├── .github/workflows/          # GitHub Actions for deployment
├── flappy_bird_flutter/        # Flutter project directory
│   ├── lib/                    # Dart source code
│   ├── test/                   # Unit and integration tests
│   ├── web/                    # Web-specific files
│   └── scripts/                # Deployment scripts
├── .nojekyll                   # GitHub Pages configuration
└── 404.html                    # Custom 404 page
```

## 🚀 Quick Start

1. **Clone the repository:**

   ```bash
   git clone https://github.com/gabuldev/flappy-bird-flutter.git
   cd flappy-bird-flutter
   ```

2. **Navigate to the Flutter project:**

   ```bash
   cd flappy_bird_flutter
   ```

3. **Install dependencies:**

   ```bash
   flutter pub get
   ```

4. **Run the game:**

   ```bash
   # For web
   flutter run -d chrome

   # For mobile (with device/emulator connected)
   flutter run

   # For desktop
   flutter run -d windows  # or macos/linux
   ```

## 🎯 Features

- **Smooth 60 FPS gameplay** with CustomPainter rendering
- **Physics-based bird movement** with gravity and jump mechanics
- **Procedurally generated pipe obstacles**
- **Score tracking** with persistent high score
- **Responsive controls** (touch, mouse, keyboard)
- **Performance optimizations** with object pooling
- **Cross-platform support** (Web, Mobile, Desktop)

## 🏗️ Architecture

The game follows a clean architecture pattern:

- **Models**: `Bird`, `Pipe`, `GameState` - Core game entities
- **Controllers**: `GameController` - Game logic and state management
- **Screens**: `GameRenderer` - CustomPainter for 2D rendering
- **Utils**: `Physics`, `PipePool` - Game utilities and optimizations

## 🧪 Testing

Run the comprehensive test suite:

```bash
cd flappy_bird_flutter
flutter test
```

The project includes:

- Unit tests for all game logic
- Widget tests for UI components
- Integration tests for complete game flows
- Performance tests for optimization validation

## 🚀 Deployment

The game is automatically deployed to GitHub Pages via GitHub Actions. See [DEPLOYMENT.md](flappy_bird_flutter/DEPLOYMENT.md) for detailed deployment instructions.

### Automatic Deployment

- Every push to `main` triggers automated deployment
- Tests run before deployment
- Game is available at: https://gabuldev.github.io/flappy-bird-flutter/

## 🎮 Game Controls

- **Touch/Click**: Make the bird jump
- **Spacebar**: Jump (desktop)
- **Enter**: Restart game (when game over)

## 📊 Performance Optimizations

- Object pooling for pipe reuse
- Dirty region updates in CustomPainter
- Optimized collision detection
- Frame rate monitoring and adjustment
- Memory management for extended gameplay

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes in the `flappy_bird_flutter` directory
4. Add tests for new functionality
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

## 🎯 Development Workflow

This project was built using a spec-driven development approach:

1. **Requirements Gathering** - Defined user stories and acceptance criteria
2. **Design Document** - Created comprehensive architecture and component design
3. **Implementation Plan** - Broke down development into actionable tasks
4. **Test-Driven Development** - Implemented features with comprehensive testing
5. **Performance Optimization** - Added object pooling and rendering optimizations
6. **Deployment Setup** - Configured automated deployment to GitHub Pages

For detailed development documentation, see the `.kiro/specs/flappy-bird-flutter/` directory.

---

**Made with ❤️ using Flutter**
