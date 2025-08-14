import 'package:flappy_bird_flutter/models/pipe.dart';
import 'package:flappy_bird_flutter/utils/pipe_pool.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PipePool', () {
    late PipePool pipePool;

    setUp(() {
      pipePool = PipePool();
      pipePool.setScreenSize(400.0, 600.0);
    });

    tearDown(() {
      pipePool.dispose();
    });

    test('initializes with correct pool size', () {
      final stats = pipePool.getPoolStats();
      expect(stats['available'], equals(10)); // Initial pool size
      expect(stats['active'], equals(0));
      expect(stats['total'], equals(10));
    });

    test('spawns pipe correctly', () {
      final pipe = pipePool.spawnPipe(
        x: 400.0,
        minGapY: 150.0,
        maxGapY: 400.0,
      );

      expect(pipe.x, equals(400.0));
      expect(pipe.gapSize, equals(Pipe.defaultGapSize));
      expect(pipe.scored, isFalse);

      final stats = pipePool.getPoolStats();
      expect(stats['active'], equals(1));
      expect(stats['available'], equals(9));
    });

    test('reuses pipes from pool', () {
      // Check initial state
      var stats = pipePool.getPoolStats();
      final initialAvailable = stats['available']!;
      final initialTotal = stats['total']!;

      // Spawn a pipe
      final pipe1 = pipePool.spawnPipe(
        x: 400.0,
        minGapY: 150.0,
        maxGapY: 400.0,
      );

      stats = pipePool.getPoolStats();
      expect(stats['active'], equals(1));
      expect(stats['available'], equals(initialAvailable - 1));

      // Move pipe off-screen and cleanup
      pipe1.x = -Pipe.width - 1; // Ensure it's completely off-screen
      pipePool.cleanupOffScreenPipes();

      // After cleanup, pipe should be returned to pool
      stats = pipePool.getPoolStats();
      expect(stats['active'], equals(0));
      expect(stats['available'], equals(initialAvailable));

      // Spawn another pipe - should reuse from pool (total count shouldn't increase)
      final pipe2 = pipePool.spawnPipe(
        x: 400.0,
        minGapY: 150.0,
        maxGapY: 400.0,
      );

      // Total pipe count should remain the same (reusing existing pipes)
      stats = pipePool.getPoolStats();
      expect(stats['active'], equals(1));
      expect(stats['available'], equals(initialAvailable - 1));
      expect(stats['total'], equals(initialTotal)); // No new pipes created

      // Verify pipe is properly configured
      expect(pipe2.x, equals(400.0));
      expect(pipe2.scored, isFalse);
    });

    test('updates all active pipes', () {
      // Spawn multiple pipes
      final pipe1 =
          pipePool.spawnPipe(x: 400.0, minGapY: 150.0, maxGapY: 400.0);
      final pipe2 =
          pipePool.spawnPipe(x: 500.0, minGapY: 150.0, maxGapY: 400.0);

      final initialX1 = pipe1.x;
      final initialX2 = pipe2.x;

      // Update pipes
      pipePool.updatePipes(1.0); // 1 second

      // Pipes should have moved left
      expect(pipe1.x, lessThan(initialX1));
      expect(pipe2.x, lessThan(initialX2));
      expect(pipe1.x, equals(initialX1 - Pipe.speed));
      expect(pipe2.x, equals(initialX2 - Pipe.speed));
    });

    test('cleans up off-screen pipes', () {
      // Spawn pipes
      final pipe1 =
          pipePool.spawnPipe(x: 400.0, minGapY: 150.0, maxGapY: 400.0);
      final pipe2 =
          pipePool.spawnPipe(x: 500.0, minGapY: 150.0, maxGapY: 400.0);

      expect(pipePool.activePipeCount, equals(2));

      // Move one pipe off-screen
      pipe1.x = -Pipe.width - 1;

      // Cleanup should remove off-screen pipe
      pipePool.cleanupOffScreenPipes();

      expect(pipePool.activePipeCount, equals(1));
      expect(pipePool.activePipes.contains(pipe2), isTrue);
      expect(pipePool.activePipes.contains(pipe1), isFalse);

      // Available count should increase (pipe returned to pool)
      final stats = pipePool.getPoolStats();
      expect(stats['available'], equals(9));
    });

    test('checks for scoring pipes correctly', () {
      // Spawn a pipe
      final pipe = pipePool.spawnPipe(x: 100.0, minGapY: 150.0, maxGapY: 400.0);
      expect(pipe.scored, isFalse);

      // Bird hasn't passed pipe yet
      var scoringPipes = pipePool.checkForScoringPipes(50.0);
      expect(scoringPipes, isEmpty);
      expect(pipe.scored, isFalse);

      // Bird passes pipe
      scoringPipes = pipePool.checkForScoringPipes(200.0);
      expect(scoringPipes, hasLength(1));
      expect(scoringPipes.first, equals(pipe));
      expect(pipe.scored, isTrue);

      // Subsequent checks should not return the same pipe
      scoringPipes = pipePool.checkForScoringPipes(250.0);
      expect(scoringPipes, isEmpty);
    });

    test('gets visible pipes correctly', () {
      // Spawn pipes at different positions
      final pipe1 = pipePool.spawnPipe(
          x: -Pipe.width - 1,
          minGapY: 150.0,
          maxGapY: 400.0); // Off-screen left
      final pipe2 = pipePool.spawnPipe(
          x: 200.0, minGapY: 150.0, maxGapY: 400.0); // Visible
      final pipe3 = pipePool.spawnPipe(
          x: 500.0, minGapY: 150.0, maxGapY: 400.0); // Off-screen right

      final visiblePipes = pipePool.getVisiblePipes();

      // Only pipe2 should be visible (screen width is 400)
      expect(visiblePipes, hasLength(1));
      expect(visiblePipes.contains(pipe2), isTrue);
      expect(visiblePipes.contains(pipe1), isFalse);
      expect(visiblePipes.contains(pipe3), isFalse);
    });

    test('clears all pipes correctly', () {
      // Spawn multiple pipes
      pipePool.spawnPipe(x: 400.0, minGapY: 150.0, maxGapY: 400.0);
      pipePool.spawnPipe(x: 500.0, minGapY: 150.0, maxGapY: 400.0);
      pipePool.spawnPipe(x: 600.0, minGapY: 150.0, maxGapY: 400.0);

      expect(pipePool.activePipeCount, equals(3));

      // Clear all pipes
      pipePool.clearAllPipes();

      expect(pipePool.activePipeCount, equals(0));
      expect(pipePool.activePipes, isEmpty);

      // All pipes should be returned to pool
      final stats = pipePool.getPoolStats();
      expect(stats['available'], equals(10)); // Back to initial size
    });

    test('handles pool size limits correctly', () {
      // Fill the pool beyond max size by spawning and cleaning up many pipes
      for (int i = 0; i < 25; i++) {
        final pipe =
            pipePool.spawnPipe(x: 400.0, minGapY: 150.0, maxGapY: 400.0);
        pipe.x = -Pipe.width - 1; // Move off-screen
        pipePool.cleanupOffScreenPipes();
      }

      final stats = pipePool.getPoolStats();
      // Pool should not exceed max size of 20
      expect(stats['available'], lessThanOrEqualTo(20));
      expect(stats['active'], equals(0));
    });

    test('throws error when screen size not set', () {
      final uninitializedPool = PipePool();

      expect(
        () => uninitializedPool.spawnPipe(
          x: 400.0,
          minGapY: 150.0,
          maxGapY: 400.0,
        ),
        throwsStateError,
      );
    });

    test('creates new pipes when pool is empty', () {
      // Exhaust the pool
      final pipes = <Pipe>[];
      for (int i = 0; i < 15; i++) {
        pipes.add(pipePool.spawnPipe(
            x: 400.0 + i * 100, minGapY: 150.0, maxGapY: 400.0));
      }

      expect(pipePool.activePipeCount, equals(15));
      expect(pipePool.availablePipeCount, equals(0));

      // Should still be able to spawn more pipes (creates new ones)
      final newPipe =
          pipePool.spawnPipe(x: 2000.0, minGapY: 150.0, maxGapY: 400.0);
      expect(newPipe, isNotNull);
      expect(pipePool.activePipeCount, equals(16));
    });
  });
}
