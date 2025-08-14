import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import 'controllers/game_controller.dart';
import 'screens/game_renderer.dart';

void main() {
  runApp(const FlappyBirdApp());
}

class FlappyBirdApp extends StatelessWidget {
  const FlappyBirdApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flappy Bird Flutter',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const GameScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  // Game components
  late GameController _gameController;
  late GameRenderer _gameRenderer;

  // Game loop
  late Ticker _ticker;
  DateTime? _lastFrameTime;

  // Input handling
  int _pendingInputs = 0;
  DateTime? _lastInputTime;
  static const Duration _inputCooldown = Duration(milliseconds: 50);

  // Focus node for keyboard input
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();

    // Set preferred orientations to portrait only
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    // Initialize focus node for keyboard input
    _focusNode = FocusNode();

    // Initialize game components
    _initializeGame();

    // Start game loop
    _startGameLoop();

    // Request focus for keyboard input
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    // Stop game loop
    _ticker.dispose();

    // Dispose focus node
    _focusNode.dispose();

    // Reset orientation when leaving the game
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    super.dispose();
  }

  /// Initializes the game controller and renderer
  void _initializeGame() {
    _gameController = GameController();
    _gameRenderer = GameRenderer(
      controller: _gameController,
      gameState: _gameController.currentGameState,
    );
  }

  /// Starts the game loop using Ticker
  void _startGameLoop() {
    _ticker = createTicker(_onTick);
    _ticker.start();
  }

  /// Game loop tick callback
  void _onTick(Duration elapsed) {
    final currentTime = DateTime.now();

    if (_lastFrameTime != null) {
      final deltaTime =
          currentTime.difference(_lastFrameTime!).inMicroseconds / 1000000.0;

      // Cap delta time to prevent large jumps (e.g., when app was paused)
      final cappedDeltaTime =
          deltaTime.clamp(0.0, 1.0 / 30.0); // Max 30 FPS minimum

      // Update game logic
      _updateGame(cappedDeltaTime);

      // Trigger repaint
      setState(() {});
    }

    _lastFrameTime = currentTime;
  }

  /// Updates game logic
  void _updateGame(double deltaTime) {
    _gameController.update(deltaTime);

    // Process pending inputs
    if (_pendingInputs > 0) {
      _gameController.handleMultipleInputs(_pendingInputs);
      _pendingInputs = 0;
    }
  }

  /// Handles user input (tap/click) with rate limiting for responsiveness
  void _handleInput() {
    final now = DateTime.now();

    // Check if we're within the cooldown period
    if (_lastInputTime != null &&
        now.difference(_lastInputTime!) < _inputCooldown) {
      // Queue the input for next frame
      _pendingInputs++;
      return;
    }

    _lastInputTime = now;
    _gameController.handleInput();
  }

  /// Handles restart when game is over
  void _handleRestart() {
    print(
        '_handleRestart called - Game over: ${_gameController.currentGameState.isGameOver}');
    if (_gameController.currentGameState.isGameOver) {
      _gameController.restart();
    }
  }

  /// Handles keyboard input
  void _handleKeyboardInput(KeyEvent event) {
    if (event is KeyDownEvent) {
      final key = event.logicalKey;

      // Handle spacebar for jump
      if (key == LogicalKeyboardKey.space) {
        if (_gameController.currentGameState.isGameOver) {
          _handleRestart();
        } else {
          _handleInput();
        }
      }

      // Handle enter for restart
      if (key == LogicalKeyboardKey.enter &&
          _gameController.currentGameState.isGameOver) {
        _handleRestart();
      }
    }
  }

  /// Handles mouse input (for desktop)
  void _handleMouseInput() {
    if (_gameController.currentGameState.isGameOver) {
      _handleRestart();
    } else {
      _handleInput();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: KeyboardListener(
        focusNode: _focusNode,
        onKeyEvent: _handleKeyboardInput,
        child: MouseRegion(
          onEnter: (_) => _focusNode.requestFocus(),
          child: GestureDetector(
            // Handle multiple rapid taps
            onTap: () {
              if (_gameController.currentGameState.isGameOver) {
                _handleRestart();
              } else {
                _handleInput();
              }
            },
            // Handle mouse clicks (desktop)
            onSecondaryTap: _handleMouseInput,
            // Ensure the gesture detector covers the entire screen
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: ListenableBuilder(
                listenable: _gameController,
                builder: (context, child) {
                  // Update the existing renderer with new state
                  _gameRenderer = GameRenderer(
                    controller: _gameController,
                    gameState: _gameController.currentGameState,
                  );
                  return CustomPaint(
                    painter: _gameRenderer,
                    size: Size.infinite,
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
