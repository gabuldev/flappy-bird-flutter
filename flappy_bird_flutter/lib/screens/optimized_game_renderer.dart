import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../controllers/game_controller.dart';
import '../models/bird.dart';
import '../models/game_state.dart';
import '../models/pipe.dart';
import '../utils/render_optimizer.dart';

/// Optimized custom painter with performance enhancements
class OptimizedGameRenderer extends CustomPainter {
  final GameController controller;
  final GameState gameState;

  // Performance tracking
  final Stopwatch _frameTimer = Stopwatch();

  // Dirty region tracking
  final DirtyRegionTracker _dirtyTracker = DirtyRegionTracker();

  // Draw batching
  final DrawBatch _drawBatch = DrawBatch();

  // Cached paints for performance (using RenderOptimizer)
  late final Paint _pipePaint;
  late final Paint _groundPaint;
  late final Paint _skyPaint;
  late final Paint _cloudPaint;
  late final Paint _birdPaint;
  late final Paint _overlayPaint;

  // Cached paths for reuse
  late final Path _birdWingPath;
  late final Path _birdBodyPath;
  late final Path _cloudPath;

  // Animation state
  double _backgroundOffset = 0.0;
  double _cloudOffset = 0.0;
  double _wingAnimationTime = 0.0;
  double _birdAnimationTime = 0.0;
  double _gameOverTransition = 0.0;
  GameStatus? _previousGameStatus;

  // Performance optimization flags
  bool _shouldResetAnimations = false;
  bool _useSimplifiedRendering = false;

  // Constants
  static const double _backgroundSpeed = 50.0;
  static const double _cloudSpeed = 30.0;
  static const double _wingFlapSpeed = 8.0;
  static const double _birdBobSpeed = 2.0;

  OptimizedGameRenderer({required this.controller, required this.gameState}) {
    _initializeCachedPaints();
    _initializeCachedPaths();
  }

  /// Initializes all cached paint objects using RenderOptimizer
  void _initializeCachedPaints() {
    _pipePaint = RenderOptimizer.getCachedPaint(
        'pipe',
        () => Paint()
          ..color = Colors.green
          ..style = PaintingStyle.fill);

    _groundPaint = RenderOptimizer.getCachedPaint(
        'ground',
        () => Paint()
          ..color = const Color(0xFF8B4513)
          ..style = PaintingStyle.fill);

    _skyPaint = RenderOptimizer.getCachedPaint(
        'sky',
        () => Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF87CEEB), Color(0xFFB0E0E6)],
          ).createShader(const Rect.fromLTWH(0, 0, 400, 600)));

    _cloudPaint = RenderOptimizer.getCachedPaint(
        'cloud',
        () => Paint()
          ..color = Colors.white.withOpacity(0.8)
          ..style = PaintingStyle.fill);

    _birdPaint = RenderOptimizer.getCachedPaint(
        'bird',
        () => Paint()
          ..color = Colors.yellow
          ..style = PaintingStyle.fill);

    _overlayPaint = RenderOptimizer.getCachedPaint(
        'overlay', () => Paint()..color = Colors.black.withOpacity(0.7));
  }

  /// Initializes cached paths for reuse
  void _initializeCachedPaths() {
    _birdWingPath = RenderOptimizer.getCachedPath('birdWing', () {
      final path = Path();
      path.moveTo(0, 0);
      path.quadraticBezierTo(-12, -8, -18, -4);
      path.quadraticBezierTo(-15, 2, -8, 4);
      path.quadraticBezierTo(-4, 2, 0, 0);
      return path;
    });

    _birdBodyPath = RenderOptimizer.getCachedPath('birdBody', () {
      final path = Path();
      path.addOval(Rect.fromCenter(
        center: Offset.zero,
        width: Bird.width,
        height: Bird.height,
      ));
      return path;
    });

    _cloudPath = RenderOptimizer.getCachedPath('cloud', () {
      final path = Path();
      path.addOval(const Rect.fromLTWH(-20, -20, 40, 40));
      path.addOval(const Rect.fromLTWH(5, -25, 50, 50));
      path.addOval(const Rect.fromLTWH(30, -20, 40, 40));
      path.addOval(const Rect.fromLTWH(-5, -35, 30, 30));
      path.addOval(const Rect.fromLTWH(15, -38, 36, 36));
      return path;
    });
  }

  @override
  void paint(Canvas canvas, Size size) {
    _frameTimer.reset();
    _frameTimer.start();

    // Set screen size in controller if not already set
    if (!controller.isReady) {
      controller.setScreenSize(size.width, size.height);
      _dirtyTracker.markAllDirty(size);
    }

    // Update performance mode based on current performance
    _useSimplifiedRendering = RenderOptimizer.isLowPerformanceMode;

    // Update animations and determine dirty regions
    _updateAnimationsAndDirtyRegions(size);

    // Clear previous batch
    _drawBatch.clear();

    // Only render dirty regions for better performance
    if (_dirtyTracker.hasDirtyRegions) {
      // Clip to dirty region if possible (for very targeted updates)
      final dirtyRegion = _dirtyTracker.combinedDirtyRegion;
      if (dirtyRegion != null && !_useSimplifiedRendering) {
        canvas.save();
        canvas.clipRect(dirtyRegion);
      }

      // Draw background (always full screen)
      _drawOptimizedBackground(canvas, size);

      // Draw game elements if ready
      if (controller.isReady) {
        _drawOptimizedPipes(canvas);
        _drawOptimizedBird(canvas);
        _drawOptimizedUI(canvas, size);
      }

      // Execute batched operations
      _drawBatch.execute(canvas);

      if (dirtyRegion != null && !_useSimplifiedRendering) {
        canvas.restore();
      }
    }

    // Clear dirty regions for next frame
    _dirtyTracker.clear();

    // Record frame time for performance monitoring
    _frameTimer.stop();
    RenderOptimizer.recordFrameTime(_frameTimer.elapsedMicroseconds / 1000.0);
  }

  /// Updates animations and determines which regions need repainting
  void _updateAnimationsAndDirtyRegions(Size size) {
    const deltaTime = 1 / 60; // Assume 60 FPS

    // Track previous positions for dirty region calculation
    final previousBirdY = controller.isReady ? controller.currentBird.y : 0.0;
    final previousBackgroundOffset = _backgroundOffset;

    // Update animations
    if (controller.isReady && controller.currentGameState.isPlaying) {
      _backgroundOffset += _backgroundSpeed * deltaTime;
      _cloudOffset += _cloudSpeed * deltaTime;

      if (_backgroundOffset > 100) _backgroundOffset = 0;
      if (_cloudOffset > 200) _cloudOffset = 0;
    }

    if (controller.isReady) {
      _wingAnimationTime += deltaTime;
      _birdAnimationTime += deltaTime;

      if (_wingAnimationTime > 1000) _wingAnimationTime = 0;
      if (_birdAnimationTime > 1000) _birdAnimationTime = 0;
    }

    _updateGameStateTransitions(deltaTime);

    // Calculate dirty regions based on what changed
    if (controller.isReady) {
      final bird = controller.currentBird;

      // Bird moved - mark bird area as dirty
      if ((bird.y - previousBirdY).abs() > 0.1) {
        final birdRect = Rect.fromCenter(
          center: Offset(bird.x, bird.y),
          width: Bird.width + 40, // Extra margin for wings and rotation
          height: Bird.height + 40,
        );
        _dirtyTracker.addDirtyRegion(birdRect);
      }

      // Background moved - mark background areas as dirty (simplified)
      if ((_backgroundOffset - previousBackgroundOffset).abs() > 0.1) {
        // Only mark ground area as dirty for background movement
        final groundRect = Rect.fromLTWH(0, size.height - 50, size.width, 50);
        _dirtyTracker.addDirtyRegion(groundRect);
      }

      // Pipes moved - mark pipe areas as dirty
      for (final pipe in controller.allPipes) {
        if (pipe.isVisible(size.width)) {
          for (final bound in pipe.getBounds()) {
            _dirtyTracker.addDirtyRegion(bound);
          }
        }
      }

      // UI changes - mark UI areas as dirty
      final uiRect = Rect.fromLTWH(0, 0, size.width, 100); // Score area
      _dirtyTracker.addDirtyRegion(uiRect);

      // Game over screen - mark entire screen as dirty
      if (controller.currentGameState.isGameOver) {
        _dirtyTracker.markAllDirty(size);
      }
    }

    // If no specific dirty regions, mark all dirty (fallback)
    if (!_dirtyTracker.hasDirtyRegions) {
      _dirtyTracker.markAllDirty(size);
    }
  }

  /// Updates smooth transitions between game states
  void _updateGameStateTransitions(double deltaTime) {
    if (!controller.isReady) return;

    final currentStatus = controller.currentGameState.status;

    if (_previousGameStatus != currentStatus) {
      if (currentStatus == GameStatus.gameOver) {
        _gameOverTransition = 0.0;
      }

      if (_previousGameStatus == GameStatus.gameOver &&
          currentStatus == GameStatus.playing) {
        _shouldResetAnimations = true;
      }

      _previousGameStatus = currentStatus;
    }

    if (_shouldResetAnimations) {
      _resetAnimations();
      _shouldResetAnimations = false;
    }

    if (currentStatus == GameStatus.gameOver && _gameOverTransition < 1.0) {
      _gameOverTransition += deltaTime * 2.0;
      _gameOverTransition = _gameOverTransition.clamp(0.0, 1.0);
    }

    if (currentStatus != GameStatus.gameOver) {
      _gameOverTransition = 0.0;
    }
  }

  /// Resets all visual animations to initial state
  void _resetAnimations() {
    _wingAnimationTime = 0.0;
    _birdAnimationTime = 0.0;
    _backgroundOffset = 0.0;
    _cloudOffset = 0.0;
    _gameOverTransition = 0.0;
  }

  /// Draws optimized background with reduced complexity in low performance mode
  void _drawOptimizedBackground(Canvas canvas, Size size) {
    // Always draw sky (it's a simple gradient)
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), _skyPaint);

    // Skip clouds in low performance mode
    if (!_useSimplifiedRendering) {
      _drawOptimizedClouds(canvas, size);
    }

    // Always draw ground (essential for gameplay)
    _drawOptimizedGround(canvas, size);
  }

  /// Draws optimized clouds using cached paths
  void _drawOptimizedClouds(Canvas canvas, Size size) {
    final cloudPositions = [
      {'x': 100.0, 'y': 80.0, 'scale': 1.0},
      {'x': 300.0, 'y': 120.0, 'scale': 0.8},
      {'x': 500.0, 'y': 60.0, 'scale': 1.2},
    ];

    for (final cloud in cloudPositions) {
      final x = (cloud['x']! - _cloudOffset) % (size.width + 100);
      final y = cloud['y']!;
      final scale = cloud['scale']!;

      canvas.save();
      canvas.translate(x, y);
      canvas.scale(scale);
      canvas.drawPath(_cloudPath, _cloudPaint);
      canvas.restore();
    }
  }

  /// Draws optimized ground
  void _drawOptimizedGround(Canvas canvas, Size size) {
    const groundHeight = 50.0;
    final groundY = size.height - groundHeight;

    final groundRect = Rect.fromLTWH(0, groundY, size.width, groundHeight);
    _drawBatch.addRect(groundRect, _groundPaint);

    // Skip ground texture in low performance mode
    if (!_useSimplifiedRendering) {
      _drawGroundTexture(canvas, size, groundY);
    }
  }

  /// Draws simplified ground texture
  void _drawGroundTexture(Canvas canvas, Size size, double groundY) {
    final texturePaint = RenderOptimizer.getCachedPaint(
        'groundTexture',
        () => Paint()
          ..color = const Color(0xFF654321).withOpacity(0.3)
          ..style = PaintingStyle.fill);

    const grassSpacing = 40.0; // Reduced density for performance
    final grassOffset = _backgroundOffset * 2;

    for (double x = -grassSpacing + (grassOffset % grassSpacing);
        x < size.width + grassSpacing;
        x += grassSpacing) {
      final grassRect = Rect.fromLTWH(x - 1, groundY - 8, 2, 8);
      _drawBatch.addRect(grassRect, texturePaint);
    }
  }

  /// Draws optimized pipes using batching
  void _drawOptimizedPipes(Canvas canvas) {
    final visiblePipes = controller.pipePool.getVisiblePipes();

    // Batch all pipe rectangles together
    for (final pipe in visiblePipes) {
      final pipeBounds = pipe.getBounds();
      for (final bound in pipeBounds) {
        _drawBatch.addRect(bound, _pipePaint);

        // Add pipe caps in high performance mode only
        if (!_useSimplifiedRendering) {
          _addPipeCap(bound);
        }
      }
    }
  }

  /// Adds pipe cap to the draw batch
  void _addPipeCap(Rect bound) {
    final isTopPipe = bound.top == 0;
    const capHeight = 20.0;
    const capWidth = Pipe.width + 8.0;

    Rect capRect;
    if (isTopPipe) {
      capRect = Rect.fromLTWH(
        bound.left - 4,
        bound.bottom - capHeight,
        capWidth,
        capHeight,
      );
    } else {
      capRect = Rect.fromLTWH(
        bound.left - 4,
        bound.top,
        capWidth,
        capHeight,
      );
    }

    _drawBatch.addRect(capRect, _pipePaint);
  }

  /// Draws optimized bird with reduced complexity in low performance mode
  void _drawOptimizedBird(Canvas canvas) {
    final bird = controller.currentBird;

    canvas.save();

    // Calculate bird position with bobbing animation
    double birdY = bird.y;
    if (controller.currentGameState.isInMenu) {
      birdY += math.sin(_birdAnimationTime * _birdBobSpeed * 2 * math.pi) * 3;
    }

    canvas.translate(bird.x, birdY);

    // Apply rotation
    double smoothRotation = bird.rotation;
    if (bird.state != BirdState.dead && !_useSimplifiedRendering) {
      smoothRotation += math.sin(_birdAnimationTime * 4) * 0.05;
    }
    canvas.rotate(smoothRotation);

    // Draw bird body using cached path
    Color birdColor = Colors.yellow;
    if (bird.state == BirdState.dead) {
      birdColor = Colors.red;
    } else if (bird.state == BirdState.falling) {
      birdColor = Colors.orange;
    }

    final currentBirdPaint = RenderOptimizer.getCachedPaint(
        'bird_$birdColor',
        () => Paint()
          ..color = birdColor
          ..style = PaintingStyle.fill);

    canvas.drawPath(_birdBodyPath, currentBirdPaint);

    // Draw wings only in high performance mode
    if (!_useSimplifiedRendering) {
      _drawOptimizedWings(canvas, bird);
    }

    // Always draw eye (important for character)
    _drawBirdEye(canvas);

    canvas.restore();
  }

  /// Draws optimized wings
  void _drawOptimizedWings(Canvas canvas, Bird bird) {
    final wingFlapCycle =
        math.sin(_wingAnimationTime * _wingFlapSpeed * 2 * math.pi);
    final wingAngle = wingFlapCycle * 0.3;

    final wingPaint = RenderOptimizer.getCachedPaint(
        'wing',
        () => Paint()
          ..color = Colors.orange.shade700
          ..style = PaintingStyle.fill);

    // Left wing
    canvas.save();
    canvas.translate(-8, -2);
    canvas.rotate(wingAngle);
    canvas.drawPath(_birdWingPath, wingPaint);
    canvas.restore();

    // Right wing (mirrored)
    canvas.save();
    canvas.translate(8, -2);
    canvas.scale(-1, 1); // Mirror horizontally
    canvas.rotate(wingAngle);
    canvas.drawPath(_birdWingPath, wingPaint);
    canvas.restore();
  }

  /// Draws bird eye (always visible for character recognition)
  void _drawBirdEye(Canvas canvas) {
    final eyePaint = RenderOptimizer.getCachedPaint(
        'eye',
        () => Paint()
          ..color = Colors.black
          ..style = PaintingStyle.fill);

    final eyeHighlightPaint = RenderOptimizer.getCachedPaint(
        'eyeHighlight',
        () => Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill);

    _drawBatch.addCircle(const Offset(8, -4), 3, eyePaint);
    _drawBatch.addCircle(const Offset(9, -5), 1, eyeHighlightPaint);
  }

  /// Draws optimized UI elements
  void _drawOptimizedUI(Canvas canvas, Size size) {
    final gameState = controller.currentGameState;

    // Draw score (always visible)
    _drawOptimizedScore(canvas, size, gameState.score);

    // Draw game over screen if needed
    if (gameState.isGameOver) {
      _drawOptimizedGameOverScreen(canvas, size, gameState);
    }

    // Draw start instruction if in menu
    if (gameState.isInMenu) {
      _drawOptimizedStartInstruction(canvas, size);
    }
  }

  /// Draws optimized score using cached text painter
  void _drawOptimizedScore(Canvas canvas, Size size, int score) {
    final textPainter =
        RenderOptimizer.getCachedTextPainter('score_$score', () {
      const textStyle = TextStyle(
        color: Colors.white,
        fontSize: 48,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(
            offset: Offset(2, 2),
            blurRadius: 4,
            color: Colors.black54,
          ),
        ],
      );

      final textSpan = TextSpan(
        text: score.toString(),
        style: textStyle,
      );

      final painter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      painter.layout();
      return painter;
    });

    final offset = Offset(
      (size.width - textPainter.width) / 2,
      50,
    );

    textPainter.paint(canvas, offset);
  }

  /// Draws simplified game over screen
  void _drawOptimizedGameOverScreen(
      Canvas canvas, Size size, GameState gameState) {
    // Draw overlay
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height), _overlayPaint);

    // Use cached text painters for game over elements
    final gameOverPainter =
        RenderOptimizer.getCachedTextPainter('gameOver', () {
      const textStyle = TextStyle(
        color: Colors.white,
        fontSize: 48,
        fontWeight: FontWeight.bold,
      );

      final textSpan = TextSpan(
        text: 'Game Over',
        style: textStyle,
      );

      final painter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      painter.layout();
      return painter;
    });

    final gameOverOffset = Offset(
      (size.width - gameOverPainter.width) / 2,
      size.height / 2 - 50,
    );

    gameOverPainter.paint(canvas, gameOverOffset);

    // Draw final score
    final finalScorePainter = RenderOptimizer.getCachedTextPainter(
        'finalScore_${gameState.score}', () {
      const textStyle = TextStyle(
        color: Colors.white,
        fontSize: 24,
      );

      final textSpan = TextSpan(
        text: 'Score: ${gameState.score}',
        style: textStyle,
      );

      final painter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      painter.layout();
      return painter;
    });

    final scoreOffset = Offset(
      (size.width - finalScorePainter.width) / 2,
      size.height / 2 + 20,
    );

    finalScorePainter.paint(canvas, scoreOffset);
  }

  /// Draws optimized start instruction
  void _drawOptimizedStartInstruction(Canvas canvas, Size size) {
    final instructionPainter =
        RenderOptimizer.getCachedTextPainter('startInstruction', () {
      const textStyle = TextStyle(
        color: Colors.white,
        fontSize: 32,
        fontWeight: FontWeight.w500,
        shadows: [
          Shadow(
            offset: Offset(2, 2),
            blurRadius: 4,
            color: Colors.black54,
          ),
        ],
      );

      final textSpan = TextSpan(
        text: 'Tap to start',
        style: textStyle,
      );

      final painter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      painter.layout();
      return painter;
    });

    final offset = Offset(
      (size.width - instructionPainter.width) / 2,
      size.height / 2,
    );

    instructionPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant OptimizedGameRenderer oldDelegate) {
    // More intelligent repainting decision
    final stateChanged = oldDelegate.gameState.status != gameState.status ||
        oldDelegate.gameState.score != gameState.score;

    final hasMovement = controller.isReady &&
        (controller.currentGameState.isPlaying ||
            controller.currentGameState.isInMenu);

    // In low performance mode, reduce repaint frequency
    if (RenderOptimizer.isLowPerformanceMode) {
      return stateChanged ||
          (hasMovement && _frameTimer.elapsedMilliseconds > 33); // 30 FPS
    }

    return stateChanged || hasMovement;
  }
}
