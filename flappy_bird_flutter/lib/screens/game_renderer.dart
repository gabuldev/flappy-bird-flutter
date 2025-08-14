import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../controllers/game_controller.dart';
import '../models/bird.dart';
import '../models/game_state.dart';
import '../models/pipe.dart';

/// Custom painter responsible for rendering all game elements
class GameRenderer extends CustomPainter {
  final GameController controller;
  final GameState gameState;

  // Cached paints for performance
  late final Paint _pipePaint;
  late final Paint _groundPaint;

  // Background animation state
  double _backgroundOffset = 0.0;
  double _cloudOffset = 0.0;

  // Bird animation state
  double _wingAnimationTime = 0.0;
  double _birdAnimationTime = 0.0;

  // Game state transition animation
  double _gameOverTransition = 0.0;
  GameStatus? _previousGameStatus;

  // Animation reset flag
  bool _shouldResetAnimations = false;

  // Performance optimization
  static const double _backgroundSpeed = 50.0; // pixels/second
  static const double _cloudSpeed = 30.0; // pixels/second
  static const double _wingFlapSpeed = 8.0; // flaps per second
  static const double _birdBobSpeed = 2.0; // bobs per second when idle

  GameRenderer({required this.controller, required this.gameState}) {
    _initializePaints();
  }

  /// Initializes all paint objects for rendering
  void _initializePaints() {
    _pipePaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;

    _groundPaint = Paint()
      ..color = const Color(0xFF8B4513) // Brown ground
      ..style = PaintingStyle.fill;
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Set screen size in controller if not already set
    if (!controller.isReady) {
      controller.setScreenSize(size.width, size.height);
    }

    // Update background animation
    _updateBackgroundAnimation();

    // Draw background with parallax effect
    drawBackground(canvas, size);

    // Draw game elements if ready
    if (controller.isReady) {
      // Draw pipes
      drawPipes(canvas, controller.allPipes);

      // Draw bird
      drawBird(canvas, controller.currentBird);

      // Draw UI elements
      drawUI(canvas, size);
    }
  }

  /// Updates background and bird animation offsets
  void _updateBackgroundAnimation() {
    const deltaTime = 1 / 60; // Assume 60 FPS

    if (controller.isReady && controller.currentGameState.isPlaying) {
      // Update background offset for parallax scrolling
      _backgroundOffset += _backgroundSpeed * deltaTime;
      _cloudOffset += _cloudSpeed * deltaTime;

      // Reset offsets to prevent overflow
      if (_backgroundOffset > 100) _backgroundOffset = 0;
      if (_cloudOffset > 200) _cloudOffset = 0;
    }

    // Always update bird animations (even when not playing for menu animation)
    if (controller.isReady) {
      _wingAnimationTime += deltaTime;
      _birdAnimationTime += deltaTime;

      // Reset animation times to prevent overflow
      if (_wingAnimationTime > 1000) _wingAnimationTime = 0;
      if (_birdAnimationTime > 1000) _birdAnimationTime = 0;
    }

    // Update game state transitions
    _updateGameStateTransitions(deltaTime);
  }

  /// Updates smooth transitions between game states
  void _updateGameStateTransitions(double deltaTime) {
    if (!controller.isReady) return;

    final currentStatus = controller.currentGameState.status;

    // Check if game state changed
    if (_previousGameStatus != currentStatus) {
      print(
          'GameRenderer: State changed from $_previousGameStatus to $currentStatus');

      // Reset transition animation when entering game over
      if (currentStatus == GameStatus.gameOver) {
        _gameOverTransition = 0.0;
        print('GameRenderer: Starting game over transition');
      }

      // Reset animations when restarting game (from gameOver to playing)
      if (_previousGameStatus == GameStatus.gameOver &&
          currentStatus == GameStatus.playing) {
        _shouldResetAnimations = true;
        print('GameRenderer: Resetting animations for game restart');
      }

      // Update previous status AFTER checking transitions
      _previousGameStatus = currentStatus;
    }

    // Reset animations if needed
    if (_shouldResetAnimations) {
      _resetAnimations();
      _shouldResetAnimations = false;
    }

    // Animate game over transition
    if (currentStatus == GameStatus.gameOver && _gameOverTransition < 1.0) {
      _gameOverTransition += deltaTime * 2.0; // 0.5 second transition
      _gameOverTransition = _gameOverTransition.clamp(0.0, 1.0);
    }

    // Reset transition when not in game over
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

  /// Draws the background with parallax effect
  void drawBackground(Canvas canvas, Size size) {
    // Draw sky gradient
    _drawSkyGradient(canvas, size);

    // Draw clouds with parallax effect
    _drawClouds(canvas, size);

    // Draw ground with texture
    _drawGround(canvas, size);
  }

  /// Draws a gradient sky background
  void _drawSkyGradient(Canvas canvas, Size size) {
    const gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFF87CEEB), // Light sky blue
        Color(0xFFB0E0E6), // Powder blue
      ],
    );

    final paint = Paint()
      ..shader =
          gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  /// Draws animated clouds with parallax scrolling
  void _drawClouds(Canvas canvas, Size size) {
    final cloudPositions = [
      {'x': 100.0, 'y': 80.0, 'scale': 1.0},
      {'x': 300.0, 'y': 120.0, 'scale': 0.8},
      {'x': 500.0, 'y': 60.0, 'scale': 1.2},
      {'x': 700.0, 'y': 140.0, 'scale': 0.9},
    ];

    for (final cloud in cloudPositions) {
      final x = (cloud['x']! - _cloudOffset) % (size.width + 100);
      final y = cloud['y']!;
      final scale = cloud['scale']!;

      _drawCloud(canvas, x, y, scale);
    }
  }

  /// Draws a single cloud
  void _drawCloud(Canvas canvas, double x, double y, double scale) {
    canvas.save();
    canvas.translate(x, y);
    canvas.scale(scale);

    // Draw cloud using circles
    final cloudPaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.fill;

    // Main cloud body
    canvas.drawCircle(const Offset(0, 0), 20, cloudPaint);
    canvas.drawCircle(const Offset(25, -5), 25, cloudPaint);
    canvas.drawCircle(const Offset(50, 0), 20, cloudPaint);
    canvas.drawCircle(const Offset(15, -15), 15, cloudPaint);
    canvas.drawCircle(const Offset(35, -18), 18, cloudPaint);

    canvas.restore();
  }

  /// Draws the ground with texture and parallax effect
  void _drawGround(Canvas canvas, Size size) {
    const groundHeight = 50.0;
    final groundY = size.height - groundHeight;

    // Draw main ground
    final groundRect = Rect.fromLTWH(0, groundY, size.width, groundHeight);
    canvas.drawRect(groundRect, _groundPaint);

    // Draw ground texture with parallax
    _drawGroundTexture(canvas, size, groundY, groundHeight);

    // Draw ground border
    final borderPaint = Paint()
      ..color = const Color(0xFF654321) // Darker brown
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(0, groundY),
      Offset(size.width, groundY),
      borderPaint,
    );
  }

  /// Draws ground texture with moving pattern
  void _drawGroundTexture(
      Canvas canvas, Size size, double groundY, double groundHeight) {
    final texturePaint = Paint()
      ..color = const Color(0xFF654321).withOpacity(0.3)
      ..style = PaintingStyle.fill;

    // Draw moving grass pattern
    const grassSpacing = 20.0;
    final grassOffset = _backgroundOffset * 2; // Move faster than clouds

    for (double x = -grassSpacing + (grassOffset % grassSpacing);
        x < size.width + grassSpacing;
        x += grassSpacing) {
      // Draw simple grass blades
      final grassPath = Path()
        ..moveTo(x, groundY)
        ..lineTo(x - 2, groundY - 8)
        ..lineTo(x + 2, groundY - 8)
        ..close();

      canvas.drawPath(grassPath, texturePaint);
    }
  }

  /// Draws the bird with rotation and wing flapping animation
  void drawBird(Canvas canvas, Bird bird) {
    canvas.save();

    // Calculate bird position with subtle bobbing animation when in menu
    double birdY = bird.y;
    if (controller.currentGameState.isInMenu) {
      birdY += math.sin(_birdAnimationTime * _birdBobSpeed * 2 * math.pi) * 3;
    }

    // Translate to bird position
    canvas.translate(bird.x, birdY);

    // Apply smooth rotation based on velocity
    double smoothRotation = bird.rotation;
    if (bird.state != BirdState.dead) {
      // Add slight rotation animation for more natural movement
      smoothRotation += math.sin(_birdAnimationTime * 4) * 0.05;
    }
    canvas.rotate(smoothRotation);

    // Calculate wing flap animation
    final wingFlapCycle =
        math.sin(_wingAnimationTime * _wingFlapSpeed * 2 * math.pi);
    final wingAngle = wingFlapCycle * 0.3; // Wing flap angle in radians

    // Draw bird body
    _drawBirdBody(canvas, bird);

    // Draw animated wings
    _drawBirdWings(canvas, bird, wingAngle);

    // Draw bird details (eye, beak)
    _drawBirdDetails(canvas, bird);

    canvas.restore();
  }

  /// Draws the main body of the bird
  void _drawBirdBody(Canvas canvas, Bird bird) {
    // Change color based on bird state
    Color birdColor = Colors.yellow;
    if (bird.state == BirdState.dead) {
      birdColor = Colors.red;
    } else if (bird.state == BirdState.falling) {
      birdColor = Colors.orange;
    }

    final birdPaint = Paint()
      ..color = birdColor
      ..style = PaintingStyle.fill;

    // Draw main body as oval
    final bodyRect = Rect.fromCenter(
      center: Offset.zero,
      width: Bird.width,
      height: Bird.height,
    );
    canvas.drawOval(bodyRect, birdPaint);

    // Draw body outline
    final outlinePaint = Paint()
      ..color = birdColor.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawOval(bodyRect, outlinePaint);
  }

  /// Draws animated wings
  void _drawBirdWings(Canvas canvas, Bird bird, double wingAngle) {
    final wingPaint = Paint()
      ..color = bird.state == BirdState.dead
          ? Colors.red.shade700
          : Colors.orange.shade700
      ..style = PaintingStyle.fill;

    // Draw left wing
    canvas.save();
    canvas.translate(-8, -2);
    canvas.rotate(wingAngle);

    final leftWingPath = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(-12, -8, -18, -4)
      ..quadraticBezierTo(-15, 2, -8, 4)
      ..quadraticBezierTo(-4, 2, 0, 0);

    canvas.drawPath(leftWingPath, wingPaint);
    canvas.restore();

    // Draw right wing
    canvas.save();
    canvas.translate(8, -2);
    canvas.rotate(-wingAngle);

    final rightWingPath = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(12, -8, 18, -4)
      ..quadraticBezierTo(15, 2, 8, 4)
      ..quadraticBezierTo(4, 2, 0, 0);

    canvas.drawPath(rightWingPath, wingPaint);
    canvas.restore();

    // Draw wing details
    final wingDetailPaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Left wing detail
    canvas.save();
    canvas.translate(-8, -2);
    canvas.rotate(wingAngle);
    canvas.drawLine(
        const Offset(-4, -2), const Offset(-12, -4), wingDetailPaint);
    canvas.drawLine(
        const Offset(-6, 0), const Offset(-14, -2), wingDetailPaint);
    canvas.restore();

    // Right wing detail
    canvas.save();
    canvas.translate(8, -2);
    canvas.rotate(-wingAngle);
    canvas.drawLine(const Offset(4, -2), const Offset(12, -4), wingDetailPaint);
    canvas.drawLine(const Offset(6, 0), const Offset(14, -2), wingDetailPaint);
    canvas.restore();
  }

  /// Draws bird details (eye, beak, etc.)
  void _drawBirdDetails(Canvas canvas, Bird bird) {
    // Draw bird eye
    final eyePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final eyeRect = Rect.fromCenter(
      center: const Offset(8, -4),
      width: 6,
      height: 6,
    );
    canvas.drawOval(eyeRect, eyePaint);

    // Draw eye highlight
    final eyeHighlightPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final highlightRect = Rect.fromCenter(
      center: const Offset(9, -5),
      width: 2,
      height: 2,
    );
    canvas.drawOval(highlightRect, eyeHighlightPaint);

    // Draw beak
    final beakPaint = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.fill;

    final beakPath = Path()
      ..moveTo(Bird.width / 2, 0)
      ..lineTo(Bird.width / 2 + 8, -2)
      ..lineTo(Bird.width / 2 + 8, 2)
      ..close();

    canvas.drawPath(beakPath, beakPaint);

    // Draw beak outline
    final beakOutlinePaint = Paint()
      ..color = Colors.orange.shade800
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawPath(beakPath, beakOutlinePaint);

    // Draw small tail feathers
    if (bird.state != BirdState.dead) {
      final tailPaint = Paint()
        ..color = Colors.yellow.shade700
        ..style = PaintingStyle.fill;

      final tailPath = Path()
        ..moveTo(-Bird.width / 2, 2)
        ..lineTo(-Bird.width / 2 - 6, 0)
        ..lineTo(-Bird.width / 2 - 4, 4)
        ..close();

      canvas.drawPath(tailPath, tailPaint);
    }
  }

  /// Draws all pipes in the game
  void drawPipes(Canvas canvas, List<Pipe> pipes) {
    for (final pipe in pipes) {
      _drawSinglePipe(canvas, pipe);
    }
  }

  /// Draws a single pipe (both top and bottom parts)
  void _drawSinglePipe(Canvas canvas, Pipe pipe) {
    final pipeBounds = pipe.getBounds();

    for (final bound in pipeBounds) {
      // Draw pipe body
      canvas.drawRect(bound, _pipePaint);

      // Draw pipe border
      final borderPaint = Paint()
        ..color = Colors.green.shade800
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      canvas.drawRect(bound, borderPaint);

      // Draw pipe cap (wider rectangle at the end)
      final isTopPipe = bound.top == 0;
      const capHeight = 20.0;
      const capWidth = Pipe.width + 8.0;

      Rect capRect;
      if (isTopPipe) {
        // Top pipe cap at bottom of pipe
        capRect = Rect.fromLTWH(
          bound.left - 4,
          bound.bottom - capHeight,
          capWidth,
          capHeight,
        );
      } else {
        // Bottom pipe cap at top of pipe
        capRect = Rect.fromLTWH(
          bound.left - 4,
          bound.top,
          capWidth,
          capHeight,
        );
      }

      canvas.drawRect(capRect, _pipePaint);
      canvas.drawRect(capRect, borderPaint);
    }
  }

  /// Draws the game over screen with enhanced UI
  void _drawGameOverScreen(Canvas canvas, Size size, GameState gameState) {
    print('_drawGameOverScreen called');

    // Draw simple overlay first to test
    final overlayPaint = Paint()..color = Colors.black.withOpacity(0.7);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), overlayPaint);

    // Draw simple "Game Over" text to test
    const gameOverStyle = TextStyle(
      color: Colors.white,
      fontSize: 48,
      fontWeight: FontWeight.bold,
    );

    const gameOverSpan = TextSpan(
      text: 'Game Over',
      style: gameOverStyle,
    );

    final gameOverPainter = TextPainter(
      text: gameOverSpan,
      textDirection: TextDirection.ltr,
    );

    gameOverPainter.layout();

    final gameOverOffset = Offset(
      (size.width - gameOverPainter.width) / 2,
      size.height / 2 - 50,
    );

    gameOverPainter.paint(canvas, gameOverOffset);

    // Draw score
    final scoreStyle = TextStyle(
      color: Colors.white,
      fontSize: 24,
    );

    final scoreSpan = TextSpan(
      text: 'Score: ${gameState.score}',
      style: scoreStyle,
    );

    final scorePainter = TextPainter(
      text: scoreSpan,
      textDirection: TextDirection.ltr,
    );

    scorePainter.layout();

    final scoreOffset = Offset(
      (size.width - scorePainter.width) / 2,
      size.height / 2 + 20,
    );

    scorePainter.paint(canvas, scoreOffset);

    // Draw restart instruction
    const restartSpan = TextSpan(
      text: 'Tap to restart',
      style: TextStyle(color: Colors.white70, fontSize: 18),
    );

    final restartPainter = TextPainter(
      text: restartSpan,
      textDirection: TextDirection.ltr,
    );

    restartPainter.layout();

    final restartOffset = Offset(
      (size.width - restartPainter.width) / 2,
      size.height / 2 + 60,
    );

    restartPainter.paint(canvas, restartOffset);
  }

  /// Draws the game over overlay with gradient effect
  void _drawGameOverOverlay(Canvas canvas, Size size) {
    final gradient = RadialGradient(
      center: Alignment.center,
      radius: 1.0,
      colors: [
        Colors.black.withOpacity(0.3),
        Colors.black.withOpacity(0.7),
      ],
    );

    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  /// Draws the main game over panel with all UI elements
  void _drawGameOverPanel(Canvas canvas, Size size, GameState gameState) {
    final panelWidth = size.width * 0.8;
    final panelHeight = size.height * 0.5;
    final panelX = (size.width - panelWidth) / 2;
    final panelY = (size.height - panelHeight) / 2;

    // Draw panel background with rounded corners
    _drawPanelBackground(canvas, panelX, panelY, panelWidth, panelHeight);

    // Draw "Game Over" title
    _drawGameOverTitle(canvas, size, panelY);

    // Draw score section
    _drawScoreSection(canvas, size, gameState, panelY, panelHeight);

    // Draw restart button
    _drawRestartButton(canvas, size, panelY, panelHeight);
  }

  /// Draws the panel background with rounded corners and shadow
  void _drawPanelBackground(
      Canvas canvas, double x, double y, double width, double height) {
    // Draw shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final shadowRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x + 4, y + 4, width, height),
      const Radius.circular(20),
    );
    canvas.drawRRect(shadowRect, shadowPaint);

    // Draw main panel background
    final panelPaint = Paint()
      ..color = Colors.white.withOpacity(0.95)
      ..style = PaintingStyle.fill;

    final panelRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x, y, width, height),
      const Radius.circular(20),
    );
    canvas.drawRRect(panelRect, panelPaint);

    // Draw panel border
    final borderPaint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawRRect(panelRect, borderPaint);
  }

  /// Draws the "Game Over" title
  void _drawGameOverTitle(Canvas canvas, Size size, double panelY) {
    const gameOverStyle = TextStyle(
      color: Color(0xFF2C3E50),
      fontSize: 48,
      fontWeight: FontWeight.bold,
      shadows: [
        Shadow(
          offset: Offset(2, 2),
          blurRadius: 4,
          color: Colors.black26,
        ),
      ],
    );

    const gameOverSpan = TextSpan(
      text: 'Game Over',
      style: gameOverStyle,
    );

    final gameOverPainter = TextPainter(
      text: gameOverSpan,
      textDirection: TextDirection.ltr,
    );

    gameOverPainter.layout();

    final gameOverOffset = Offset(
      (size.width - gameOverPainter.width) / 2,
      panelY + 40,
    );

    gameOverPainter.paint(canvas, gameOverOffset);
  }

  /// Draws the score section with current score and high score
  void _drawScoreSection(Canvas canvas, Size size, GameState gameState,
      double panelY, double panelHeight) {
    const scoreStyle = TextStyle(
      color: Color(0xFF34495E),
      fontSize: 28,
      fontWeight: FontWeight.w600,
    );

    const labelStyle = TextStyle(
      color: Color(0xFF7F8C8D),
      fontSize: 18,
      fontWeight: FontWeight.w400,
    );

    // Draw current score
    final scoreSpan = TextSpan(
      text: '${gameState.score}',
      style: scoreStyle,
    );

    final scorePainter = TextPainter(
      text: scoreSpan,
      textDirection: TextDirection.ltr,
    );

    scorePainter.layout();

    final scoreOffset = Offset(
      (size.width - scorePainter.width) / 2,
      panelY + panelHeight * 0.35,
    );

    scorePainter.paint(canvas, scoreOffset);

    // Draw "Score" label
    const scoreLabelSpan = TextSpan(
      text: 'Score',
      style: labelStyle,
    );

    final scoreLabelPainter = TextPainter(
      text: scoreLabelSpan,
      textDirection: TextDirection.ltr,
    );

    scoreLabelPainter.layout();

    final scoreLabelOffset = Offset(
      (size.width - scoreLabelPainter.width) / 2,
      panelY + panelHeight * 0.25,
    );

    scoreLabelPainter.paint(canvas, scoreLabelOffset);

    // Draw high score if available
    if (gameState.highScore > 0) {
      // Highlight if new high score
      final highScoreStyle = gameState.isNewHighScore
          ? const TextStyle(
              color: Color(0xFFE74C3C),
              fontSize: 24,
              fontWeight: FontWeight.w600,
            )
          : const TextStyle(
              color: Color(0xFF27AE60),
              fontSize: 24,
              fontWeight: FontWeight.w600,
            );

      final highScoreSpan = TextSpan(
        text: '${gameState.highScore}',
        style: highScoreStyle,
      );

      final highScorePainter = TextPainter(
        text: highScoreSpan,
        textDirection: TextDirection.ltr,
      );

      highScorePainter.layout();

      final highScoreOffset = Offset(
        (size.width - highScorePainter.width) / 2,
        panelY + panelHeight * 0.55,
      );

      highScorePainter.paint(canvas, highScoreOffset);

      // Draw high score label
      final highScoreLabelText =
          gameState.isNewHighScore ? 'New Best!' : 'Best';
      final highScoreLabelStyle = gameState.isNewHighScore
          ? const TextStyle(
              color: Color(0xFFE74C3C),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            )
          : labelStyle;

      final highScoreLabelSpan = TextSpan(
        text: highScoreLabelText,
        style: highScoreLabelStyle,
      );

      final highScoreLabelPainter = TextPainter(
        text: highScoreLabelSpan,
        textDirection: TextDirection.ltr,
      );

      highScoreLabelPainter.layout();

      final highScoreLabelOffset = Offset(
        (size.width - highScoreLabelPainter.width) / 2,
        panelY + panelHeight * 0.48,
      );

      highScoreLabelPainter.paint(canvas, highScoreLabelOffset);
    }
  }

  /// Draws the restart button with styling
  void _drawRestartButton(
      Canvas canvas, Size size, double panelY, double panelHeight) {
    final buttonWidth = size.width * 0.4;
    const buttonHeight = 50.0;
    final buttonX = (size.width - buttonWidth) / 2;
    final buttonY = panelY + panelHeight * 0.75;

    // Draw button shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final shadowRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(buttonX + 2, buttonY + 2, buttonWidth, buttonHeight),
      const Radius.circular(25),
    );
    canvas.drawRRect(shadowRect, shadowPaint);

    // Draw button background
    final buttonPaint = Paint()
      ..color = const Color(0xFF3498DB)
      ..style = PaintingStyle.fill;

    final buttonRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(buttonX, buttonY, buttonWidth, buttonHeight),
      const Radius.circular(25),
    );
    canvas.drawRRect(buttonRect, buttonPaint);

    // Draw button border
    final buttonBorderPaint = Paint()
      ..color = const Color(0xFF2980B9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawRRect(buttonRect, buttonBorderPaint);

    // Draw button text
    const buttonTextStyle = TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    );

    const buttonTextSpan = TextSpan(
      text: 'Restart',
      style: buttonTextStyle,
    );

    final buttonTextPainter = TextPainter(
      text: buttonTextSpan,
      textDirection: TextDirection.ltr,
    );

    buttonTextPainter.layout();

    final buttonTextOffset = Offset(
      buttonX + (buttonWidth - buttonTextPainter.width) / 2,
      buttonY + (buttonHeight - buttonTextPainter.height) / 2,
    );

    buttonTextPainter.paint(canvas, buttonTextOffset);

    // Draw tap instruction below button
    const instructionStyle = TextStyle(
      color: Color(0xFF95A5A6),
      fontSize: 16,
      fontWeight: FontWeight.w400,
    );

    const instructionSpan = TextSpan(
      text: 'Tap anywhere to restart',
      style: instructionStyle,
    );

    final instructionPainter = TextPainter(
      text: instructionSpan,
      textDirection: TextDirection.ltr,
    );

    instructionPainter.layout();

    final instructionOffset = Offset(
      (size.width - instructionPainter.width) / 2,
      buttonY + buttonHeight + 20,
    );

    instructionPainter.paint(canvas, instructionOffset);
  }

  /// Draws UI elements (score, game over screen, etc.)
  void drawUI(Canvas canvas, Size size) {
    final gameState = controller.currentGameState;

    // Draw score
    _drawScore(canvas, size, gameState.score);

    // Draw game over screen if needed
    if (gameState.isGameOver) {
      _drawGameOverScreen(canvas, size, gameState);
    }

    // Draw start instruction if in menu
    if (gameState.isInMenu) {
      _drawStartInstruction(canvas, size);
    }
  }

  /// Draws the current score
  void _drawScore(Canvas canvas, Size size, int score) {
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

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    // Center the score at the top of the screen
    final offset = Offset(
      (size.width - textPainter.width) / 2,
      50,
    );

    textPainter.paint(canvas, offset);
  }

  /// Draws start instruction when in menu
  void _drawStartInstruction(Canvas canvas, Size size) {
    const instructionStyle = TextStyle(
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

    const instructionSpan = TextSpan(
      text: 'Tap to start',
      style: instructionStyle,
    );

    final instructionPainter = TextPainter(
      text: instructionSpan,
      textDirection: TextDirection.ltr,
    );

    instructionPainter.layout();

    final instructionOffset = Offset(
      (size.width - instructionPainter.width) / 2,
      size.height / 2,
    );

    instructionPainter.paint(canvas, instructionOffset);
  }

  @override
  bool shouldRepaint(covariant GameRenderer oldDelegate) {
    // Repaint if game state changed or for smooth animation
    return oldDelegate.gameState.status != gameState.status ||
        oldDelegate.gameState.score != gameState.score ||
        true; // Always repaint for smooth animation
  }
}
