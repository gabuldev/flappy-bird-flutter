import 'dart:math';

import 'package:flutter/foundation.dart';

import '../models/bird.dart';
import '../models/game_state.dart';
import '../models/pipe.dart';
import '../utils/physics.dart';
import '../utils/pipe_pool.dart';

class GameController extends ChangeNotifier {
  // Game objects
  late Bird bird;
  late GameState gameState;
  late PipePool pipePool;

  // Game configuration
  static const double pipeSpawnInterval = 2.0; // seconds between pipe spawns
  static const double pipeSpacing = 300.0; // horizontal distance between pipes
  static const double minGapY = 150.0; // minimum gap center Y position
  static const double maxGapY = 400.0; // maximum gap center Y position

  // Screen dimensions (will be set when screen size is known)
  double screenWidth = 0;
  double screenHeight = 0;

  // Timing
  double _timeSinceLastPipe = 0.0;
  final Random _random = Random();

  GameController() {
    _initializeGame();
  }

  /// Initializes the game with default values
  void _initializeGame() {
    gameState = GameState();
    pipePool = PipePool();
    // Load high score from persistent storage
    gameState.loadHighScore();
    // Bird will be initialized when screen dimensions are set
  }

  /// Sets the screen dimensions and initializes the bird
  void setScreenSize(double width, double height) {
    screenWidth = width;
    screenHeight = height;

    // Initialize bird at starting position
    bird = Bird(
      x: screenWidth * 0.2, // 20% from left edge
      y: screenHeight * 0.5, // center vertically
    );

    // Set screen size for pipe pool
    pipePool.setScreenSize(width, height);
  }

  /// Updates all game objects
  void update(double deltaTime) {
    if (!gameState.isPlaying) return;

    // Update bird
    bird.update(deltaTime);

    // Update pipes using pool
    pipePool.updatePipes(deltaTime);

    // Spawn new pipes if needed
    _spawnPipesIfNeeded(deltaTime);

    // Check for collisions
    if (checkCollisions()) {
      _gameOver();
      return;
    }

    // Check for scoring
    _checkScoring();

    // Clean up off-screen pipes using pool
    pipePool.cleanupOffScreenPipes();
  }

  /// Spawns new pipes at regular intervals
  void _spawnPipesIfNeeded(double deltaTime) {
    _timeSinceLastPipe += deltaTime;

    if (_timeSinceLastPipe >= pipeSpawnInterval) {
      _spawnPipe();
      _timeSinceLastPipe = 0.0;
    }
  }

  /// Spawns a new pipe at the right edge of the screen
  void _spawnPipe() {
    if (screenHeight == 0) return; // Screen not initialized yet

    // Spawn pipe using pool
    pipePool.spawnPipe(
      x: screenWidth,
      minGapY: minGapY,
      maxGapY: maxGapY,
    );
  }

  /// Checks if the bird has passed through any pipes for scoring
  void _checkScoring() {
    final scoringPipes = pipePool.checkForScoringPipes(bird.x);
    if (scoringPipes.isNotEmpty) {
      // Increment score for each pipe passed
      for (final pipe in scoringPipes) {
        gameState.incrementScore();
      }
      notifyListeners(); // Notify UI about score change
    }
  }

  /// Handles user input (jump)
  void handleInput() {
    if (gameState.isPlaying) {
      bird.jump();
      notifyListeners(); // Notify for bird jump animation
    } else if (gameState.isInMenu) {
      // Start the game on first input
      startGame();
    } else if (gameState.isGameOver) {
      restart();
    }
  }

  /// Handles multiple rapid inputs
  void handleMultipleInputs(int inputCount) {
    // Process each input individually to support rapid tapping
    for (int i = 0; i < inputCount; i++) {
      handleInput();
    }
  }

  /// Handles keyboard input (for desktop support)
  void handleKeyboardInput(String key) {
    if (key == ' ' || key == 'Space') {
      handleInput();
    }
  }

  /// Starts a new game
  void startGame() {
    gameState.startGame();
    _resetGameObjects();
    notifyListeners(); // Notify UI about game state change
  }

  /// Resets the game to initial state
  void reset() {
    gameState.reset();
    _resetGameObjects();
    notifyListeners(); // Notify UI about reset
  }

  /// Restarts the game from game over state with smooth transition
  void restart() {
    if (gameState.isGameOver) {
      // Reset game state and objects
      gameState.reset();
      _resetGameObjects();

      // Start the game immediately after restart
      gameState.startGame();
      notifyListeners(); // Notify UI about restart
    }
  }

  /// Resets all game objects to their initial state
  void _resetGameObjects() {
    if (screenWidth > 0 && screenHeight > 0) {
      bird.reset(screenWidth * 0.2, screenHeight * 0.5);
    }
    pipePool.clearAllPipes();
    _timeSinceLastPipe = 0.0;
  }

  /// Gets all pipes currently in the game
  List<Pipe> get allPipes => pipePool.activePipes;

  /// Gets the current bird instance
  Bird get currentBird => bird;

  /// Gets the current game state
  GameState get currentGameState => gameState;

  /// Checks if the game is ready to be played (screen size set)
  bool get isReady => screenWidth > 0 && screenHeight > 0;

  /// Checks for collisions between bird and pipes or screen bounds
  bool checkCollisions() {
    // Check screen bounds collision
    if (_checkScreenBoundsCollision()) {
      return true;
    }

    // Check pipe collisions
    if (_checkPipeCollisions()) {
      return true;
    }

    return false;
  }

  /// Checks if the bird has collided with screen bounds
  bool _checkScreenBoundsCollision() {
    final birdBounds = bird.getBounds();

    // Check if bird hit the ground
    if (birdBounds.bottom >= screenHeight) {
      return true;
    }

    // Check if bird hit the ceiling
    if (birdBounds.top <= 0) {
      return true;
    }

    return false;
  }

  /// Checks if the bird has collided with any pipes
  bool _checkPipeCollisions() {
    final birdBounds = bird.getBounds();

    // Only check visible pipes for collision
    final visiblePipes = pipePool.getVisiblePipes();

    for (final pipe in visiblePipes) {
      final pipeBounds = pipe.getBounds();

      for (final pipeBound in pipeBounds) {
        if (Physics.checkRectCollision(birdBounds, pipeBound)) {
          return true;
        }
      }
    }

    return false;
  }

  /// Handles game over logic
  void _gameOver() {
    bird.die();
    gameState.endGame();
    notifyListeners(); // Notify UI about game over
  }

  /// Gets pipe pool statistics for performance monitoring
  Map<String, int> getPipePoolStats() {
    return pipePool.getPoolStats();
  }

  /// Disposes the controller and cleans up resources
  @override
  void dispose() {
    pipePool.dispose();
    super.dispose();
  }
}
