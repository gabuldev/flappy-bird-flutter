import 'package:flappy_bird_flutter/controllers/game_controller.dart';
import 'package:flappy_bird_flutter/models/bird.dart';
import 'package:flappy_bird_flutter/models/pipe.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GameController', () {
    late GameController controller;

    setUp(() {
      controller = GameController();
      controller.setScreenSize(400, 600); // Set test screen size
    });

    group('Collision Detection', () {
      test('should detect collision with ground', () {
        // Position bird at ground level
        controller.bird.y = 600; // At screen height

        expect(controller.checkCollisions(), isTrue);
      });

      test('should detect collision with ceiling', () {
        // Position bird at ceiling
        controller.bird.y = -10; // Above screen

        expect(controller.checkCollisions(), isTrue);
      });

      test('should detect collision with pipe', () {
        // Spawn a pipe that overlaps with bird position
        controller.pipePool.spawnPipe(
          x: controller.bird.x - 10, // Slightly to the left of bird
          minGapY: 100, // Gap well above bird position
          maxGapY: 100,
        );

        // Position bird where it will hit the bottom pipe
        controller.bird.y = 400; // Below the gap

        expect(controller.checkCollisions(), isTrue);
      });

      test('should not detect collision when bird is in pipe gap', () {
        // Spawn a pipe with gap at bird position
        controller.pipePool.spawnPipe(
          x: controller.bird.x - 10, // Slightly to the left of bird
          minGapY: controller.bird.y, // Gap at bird position
          maxGapY: controller.bird.y,
        );

        expect(controller.checkCollisions(), isFalse);
      });

      test('should not detect collision when bird is away from pipes', () {
        // Spawn a pipe far from bird
        controller.pipePool.spawnPipe(
          x: controller.bird.x + 200, // Far to the right
          minGapY: 300,
          maxGapY: 300,
        );

        expect(controller.checkCollisions(), isFalse);
      });
    });

    group('Game Over Logic', () {
      test('should end game when collision occurs', () {
        // Start the game
        controller.startGame();
        expect(controller.gameState.isPlaying, isTrue);

        // Position bird to collide with ground
        controller.bird.y = 600;

        // Update should trigger collision and game over
        controller.update(0.016); // ~60 FPS delta

        expect(controller.gameState.isGameOver, isTrue);
        expect(controller.bird.state, equals(BirdState.dead));
      });

      test('should not update game objects after game over', () {
        // Start and end the game
        controller.startGame();
        controller.gameState.endGame();

        final initialBirdY = controller.bird.y;

        // Update should not change bird position when game is over
        controller.update(0.016);

        expect(controller.bird.y, equals(initialBirdY));
      });
    });

    group('Scoring System', () {
      test('should increment score when bird passes pipe', () {
        controller.startGame();
        final initialScore = controller.gameState.score;

        // Spawn a pipe behind the bird (already passed)
        controller.pipePool.spawnPipe(
          x: controller.bird.x - 100, // Behind bird
          minGapY: 300,
          maxGapY: 300,
        );

        // Trigger scoring check
        controller.update(0.016);

        expect(controller.gameState.score, equals(initialScore + 1));
      });

      test('should not score same pipe twice', () {
        controller.startGame();

        // Spawn a pipe behind the bird
        final pipe = controller.pipePool.spawnPipe(
          x: controller.bird.x - 100, // Behind bird
          minGapY: 300,
          maxGapY: 300,
        );

        // Mark as already scored
        pipe.markAsScored();

        final initialScore = controller.gameState.score;

        // Update should not increment score again
        controller.update(0.016);

        expect(controller.gameState.score, equals(initialScore));
      });
    });

    group('Pipe Management', () {
      test('should spawn pipes at regular intervals', () {
        controller.startGame();

        // Update for longer than spawn interval
        controller.update(2.5); // Longer than pipeSpawnInterval (2.0)

        expect(controller.allPipes.isNotEmpty, isTrue);
      });

      test('should clean up off-screen pipes', () {
        controller.startGame();

        // Spawn a pipe that's off-screen
        final pipe = controller.pipePool.spawnPipe(
          x: -Pipe.width - 1, // Off-screen to the left
          minGapY: 300,
          maxGapY: 300,
        );

        expect(controller.pipePool.activePipeCount, equals(1));

        // Update should remove the off-screen pipe
        controller.update(0.016);

        expect(controller.pipePool.activePipeCount, equals(0));
      });
    });

    group('Game State Management', () {
      test('should start game correctly', () {
        controller.startGame();

        expect(controller.gameState.isPlaying, isTrue);
        expect(controller.gameState.score, equals(0));
      });

      test('should reset game correctly', () {
        // Start game and add some score
        controller.startGame();
        controller.gameState.incrementScore();

        // Add some pipes
        controller.pipePool.spawnPipe(
          x: 200,
          minGapY: 300,
          maxGapY: 300,
        );

        expect(controller.pipePool.activePipeCount, greaterThan(0));

        // Reset game
        controller.reset();

        expect(controller.gameState.score, equals(0));
        expect(controller.pipePool.activePipeCount, equals(0));
        expect(controller.bird.state, equals(BirdState.flying));
      });

      test('should handle input correctly in different states', () {
        // In menu state, input should start game
        expect(controller.gameState.isInMenu, isTrue);
        controller.handleInput();
        expect(controller.gameState.isPlaying, isTrue);

        // In playing state, input should make bird jump
        final initialVelocity = controller.bird.velocityY;
        controller.handleInput();
        expect(controller.bird.velocityY, lessThan(initialVelocity));
      });
    });

    group('Pipe Pool Integration', () {
      test('should provide pipe pool statistics', () {
        final stats = controller.getPipePoolStats();

        expect(stats, containsPair('active', 0));
        expect(stats, containsPair('available', greaterThan(0)));
        expect(stats, containsPair('total', greaterThan(0)));
      });

      test('should reuse pipes efficiently', () {
        controller.startGame();

        // Spawn a pipe
        controller.pipePool.spawnPipe(x: 400, minGapY: 300, maxGapY: 300);
        final statsAfterSpawn = controller.getPipePoolStats();

        // Move pipe off-screen and cleanup
        final pipe = controller.allPipes.first;
        pipe.x = -Pipe.width - 1;
        controller.pipePool.cleanupOffScreenPipes();

        // Spawn another pipe - should reuse from pool
        controller.pipePool.spawnPipe(x: 400, minGapY: 300, maxGapY: 300);
        final statsAfterReuse = controller.getPipePoolStats();

        // Total count should remain the same (reusing pipes)
        expect(statsAfterReuse['total'], equals(statsAfterSpawn['total']));
      });
    });
  });
}
