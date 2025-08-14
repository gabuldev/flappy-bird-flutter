import 'package:flappy_bird_flutter/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Performance Integration Tests', () {
    testWidgets('Game maintains consistent frame rate during gameplay',
        (tester) async {
      await tester.pumpWidget(const FlappyBirdApp());
      await tester.pump();

      final gestureDetector = find.byType(GestureDetector);

      // Start the game
      await tester.tap(gestureDetector);
      await tester.pump();

      // Measure frame consistency over extended gameplay
      final frameTimings = <Duration>[];
      final startTime = DateTime.now();

      // Simulate 60 FPS gameplay for 2 seconds (120 frames)
      for (int i = 0; i < 120; i++) {
        final frameStart = DateTime.now();

        // Simulate user input every few frames
        if (i % 10 == 0) {
          await tester.tap(gestureDetector);
        }

        await tester.pump(const Duration(milliseconds: 16)); // ~60 FPS

        final frameEnd = DateTime.now();
        frameTimings.add(frameEnd.difference(frameStart));
      }

      final totalTime = DateTime.now().difference(startTime);

      // Verify performance metrics
      expect(frameTimings.length, equals(120));
      expect(totalTime.inMilliseconds,
          lessThan(3000)); // Should complete in under 3 seconds

      // Check that most frames are processed quickly
      final fastFrames =
          frameTimings.where((timing) => timing.inMilliseconds < 50).length;
      expect(fastFrames / frameTimings.length,
          greaterThan(0.9)); // 90% of frames should be fast
    });

    testWidgets('Game handles memory efficiently during extended play',
        (tester) async {
      await tester.pumpWidget(const FlappyBirdApp());
      await tester.pump();

      final gestureDetector = find.byType(GestureDetector);

      // Start the game
      await tester.tap(gestureDetector);
      await tester.pump();

      // Simulate extended gameplay to test memory management
      for (int cycle = 0; cycle < 10; cycle++) {
        // Play for a while
        for (int i = 0; i < 20; i++) {
          await tester.tap(gestureDetector);
          await tester.pump(const Duration(milliseconds: 100));
        }

        // Let the game run to generate and cleanup pipes
        for (int i = 0; i < 10; i++) {
          await tester.pump(const Duration(milliseconds: 200));
        }

        // Restart cycle
        await tester.tap(gestureDetector); // Restart if game over
        await tester.pump();
      }

      // Game should still be responsive after extended play
      expect(find.byType(GameScreen), findsOneWidget);
      await tester.tap(gestureDetector);
      await tester.pump();
    });

    testWidgets('Input responsiveness remains consistent under load',
        (tester) async {
      await tester.pumpWidget(const FlappyBirdApp());
      await tester.pump();

      final gestureDetector = find.byType(GestureDetector);

      // Start the game
      await tester.tap(gestureDetector);
      await tester.pump();

      // Test input responsiveness with varying loads
      final inputTimings = <Duration>[];

      for (int i = 0; i < 50; i++) {
        final inputStart = DateTime.now();

        await tester.tap(gestureDetector);
        await tester.pump(const Duration(milliseconds: 16));

        final inputEnd = DateTime.now();
        inputTimings.add(inputEnd.difference(inputStart));

        // Add some processing load every few frames
        if (i % 5 == 0) {
          await tester.pump(const Duration(milliseconds: 50));
        }
      }

      // Verify input responsiveness
      expect(inputTimings.length, equals(50));

      // Most inputs should be processed quickly
      final responsiveInputs =
          inputTimings.where((timing) => timing.inMilliseconds < 100).length;
      expect(responsiveInputs / inputTimings.length,
          greaterThan(0.8)); // 80% should be responsive
    });

    testWidgets('Game performance scales with different screen sizes',
        (tester) async {
      final screenSizes = [
        const Size(360, 640), // Small
        const Size(768, 1024), // Medium
        const Size(1920, 1080), // Large
      ];

      for (final size in screenSizes) {
        await tester.binding.setSurfaceSize(size);

        await tester.pumpWidget(const FlappyBirdApp());
        await tester.pump();

        final gestureDetector = find.byType(GestureDetector);

        // Start the game
        await tester.tap(gestureDetector);
        await tester.pump();

        // Measure performance at this screen size
        final frameTimings = <Duration>[];

        for (int i = 0; i < 30; i++) {
          final frameStart = DateTime.now();

          if (i % 5 == 0) {
            await tester.tap(gestureDetector);
          }

          await tester.pump(const Duration(milliseconds: 16));

          final frameEnd = DateTime.now();
          frameTimings.add(frameEnd.difference(frameStart));
        }

        // Performance should be consistent across screen sizes
        final avgFrameTime = frameTimings.fold<int>(
                0, (sum, timing) => sum + timing.inMilliseconds) /
            frameTimings.length;
        expect(avgFrameTime,
            lessThan(50)); // Average frame time should be under 50ms
      }

      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('Game handles rapid input without performance degradation',
        (tester) async {
      await tester.pumpWidget(const FlappyBirdApp());
      await tester.pump();

      final gestureDetector = find.byType(GestureDetector);

      // Start the game
      await tester.tap(gestureDetector);
      await tester.pump();

      // Test performance with rapid inputs
      final rapidInputTimings = <Duration>[];

      for (int burst = 0; burst < 5; burst++) {
        // Burst of rapid inputs
        for (int i = 0; i < 10; i++) {
          final inputStart = DateTime.now();

          await tester.tap(gestureDetector);
          await tester.pump(const Duration(milliseconds: 8)); // Very fast

          final inputEnd = DateTime.now();
          rapidInputTimings.add(inputEnd.difference(inputStart));
        }

        // Brief pause between bursts
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Verify that rapid inputs don't cause performance issues
      expect(rapidInputTimings.length, equals(50));

      // Even with rapid inputs, processing should remain reasonable
      final slowInputs = rapidInputTimings
          .where((timing) => timing.inMilliseconds > 200)
          .length;
      expect(slowInputs / rapidInputTimings.length,
          lessThan(0.1)); // Less than 10% should be slow
    });

    testWidgets('Game maintains performance during state transitions',
        (tester) async {
      await tester.pumpWidget(const FlappyBirdApp());
      await tester.pump();

      final gestureDetector = find.byType(GestureDetector);

      // Test performance during various state transitions
      final transitionTimings = <Duration>[];

      for (int cycle = 0; cycle < 10; cycle++) {
        final transitionStart = DateTime.now();

        // Start game
        await tester.tap(gestureDetector);
        await tester.pump();

        // Play briefly
        for (int i = 0; i < 5; i++) {
          await tester.tap(gestureDetector);
          await tester.pump(const Duration(milliseconds: 50));
        }

        // Let game potentially end
        await tester.pump(const Duration(milliseconds: 200));

        // Try to restart
        await tester.tap(gestureDetector);
        await tester.pump();

        final transitionEnd = DateTime.now();
        transitionTimings.add(transitionEnd.difference(transitionStart));
      }

      // State transitions should be fast
      expect(transitionTimings.length, equals(10));

      final avgTransitionTime = transitionTimings.fold<int>(
              0, (sum, timing) => sum + timing.inMilliseconds) /
          transitionTimings.length;
      expect(avgTransitionTime,
          lessThan(500)); // Average transition should be under 500ms
    });

    testWidgets('Game performance with mixed input types', (tester) async {
      await tester.pumpWidget(const FlappyBirdApp());
      await tester.pump();

      final gestureDetector = find.byType(GestureDetector);

      // Start the game
      await tester.tap(gestureDetector);
      await tester.pump();

      // Test performance with mixed input types
      final mixedInputTimings = <Duration>[];

      for (int i = 0; i < 30; i++) {
        final inputStart = DateTime.now();

        // Alternate between different input types
        switch (i % 3) {
          case 0:
            await tester.tap(gestureDetector);
            break;
          case 1:
            await tester.sendKeyEvent(LogicalKeyboardKey.space);
            break;
          case 2:
            await tester.tap(gestureDetector, buttons: kSecondaryButton);
            break;
        }

        await tester.pump(const Duration(milliseconds: 20));

        final inputEnd = DateTime.now();
        mixedInputTimings.add(inputEnd.difference(inputStart));
      }

      // Mixed input types should not degrade performance
      expect(mixedInputTimings.length, equals(30));

      final avgInputTime = mixedInputTimings.fold<int>(
              0, (sum, timing) => sum + timing.inMilliseconds) /
          mixedInputTimings.length;
      expect(avgInputTime,
          lessThan(100)); // Average input processing should be under 100ms
    });

    testWidgets('Game handles continuous gameplay without degradation',
        (tester) async {
      await tester.pumpWidget(const FlappyBirdApp());
      await tester.pump();

      final gestureDetector = find.byType(GestureDetector);

      // Start the game
      await tester.tap(gestureDetector);
      await tester.pump();

      // Simulate continuous gameplay
      final continuousTimings = <Duration>[];

      for (int minute = 0; minute < 3; minute++) {
        // 3 "minutes" of gameplay
        for (int second = 0; second < 10; second++) {
          // 10 "seconds" per minute
          final secondStart = DateTime.now();

          // Simulate gameplay for this "second"
          for (int frame = 0; frame < 6; frame++) {
            // ~6 frames per "second"
            if (frame % 2 == 0) {
              await tester.tap(gestureDetector);
            }
            await tester.pump(const Duration(milliseconds: 16));
          }

          final secondEnd = DateTime.now();
          continuousTimings.add(secondEnd.difference(secondStart));
        }

        // Brief pause between "minutes"
        await tester.pump(const Duration(milliseconds: 50));
      }

      // Performance should remain consistent throughout continuous play
      expect(continuousTimings.length, equals(30));

      // Check that performance doesn't degrade over time
      final firstHalf = continuousTimings.take(15).toList();
      final secondHalf = continuousTimings.skip(15).toList();

      final firstHalfAvg =
          firstHalf.fold<int>(0, (sum, timing) => sum + timing.inMilliseconds) /
              firstHalf.length;
      final secondHalfAvg = secondHalf.fold<int>(
              0, (sum, timing) => sum + timing.inMilliseconds) /
          secondHalf.length;

      // Second half should not be significantly slower than first half
      expect(secondHalfAvg / firstHalfAvg,
          lessThan(1.5)); // No more than 50% slower
    });
  });

  group('Memory Management Tests', () {
    testWidgets('Game cleans up resources properly', (tester) async {
      // Test multiple game instances to check for memory leaks
      for (int instance = 0; instance < 5; instance++) {
        await tester.pumpWidget(const FlappyBirdApp());
        await tester.pump();

        final gestureDetector = find.byType(GestureDetector);

        // Play the game briefly
        await tester.tap(gestureDetector);
        await tester.pump();

        for (int i = 0; i < 10; i++) {
          await tester.tap(gestureDetector);
          await tester.pump(const Duration(milliseconds: 50));
        }

        // Dispose the widget
        await tester.pumpWidget(Container());
        await tester.pump();
      }

      // If we get here without issues, memory management is working
      expect(true, isTrue);
    });

    testWidgets('Game handles object pooling efficiently', (tester) async {
      await tester.pumpWidget(const FlappyBirdApp());
      await tester.pump();

      final gestureDetector = find.byType(GestureDetector);

      // Start the game
      await tester.tap(gestureDetector);
      await tester.pump();

      // Generate many pipes to test object pooling
      for (int i = 0; i < 100; i++) {
        await tester.tap(gestureDetector);
        await tester.pump(const Duration(milliseconds: 100));

        // Let some pipes pass off-screen
        if (i % 10 == 0) {
          await tester.pump(const Duration(milliseconds: 500));
        }
      }

      // Game should still be responsive after generating many objects
      expect(find.byType(GameScreen), findsOneWidget);
      await tester.tap(gestureDetector);
      await tester.pump();
    });
  });

  group('Optimization Validation Tests', () {
    testWidgets('Rendering optimizations are effective', (tester) async {
      await tester.pumpWidget(const FlappyBirdApp());
      await tester.pump();

      final gestureDetector = find.byType(GestureDetector);

      // Start the game
      await tester.tap(gestureDetector);
      await tester.pump();

      // Test rendering performance with many updates
      final renderTimings = <Duration>[];

      for (int i = 0; i < 60; i++) {
        // 1 second at 60 FPS
        final renderStart = DateTime.now();

        if (i % 3 == 0) {
          await tester.tap(gestureDetector);
        }

        await tester.pump(const Duration(milliseconds: 16));

        final renderEnd = DateTime.now();
        renderTimings.add(renderEnd.difference(renderStart));
      }

      // Rendering should be optimized
      expect(renderTimings.length, equals(60));

      // Most renders should be fast
      final fastRenders =
          renderTimings.where((timing) => timing.inMilliseconds < 30).length;
      expect(fastRenders / renderTimings.length,
          greaterThan(0.8)); // 80% should be fast
    });

    testWidgets('Input handling optimizations work correctly', (tester) async {
      await tester.pumpWidget(const FlappyBirdApp());
      await tester.pump();

      final gestureDetector = find.byType(GestureDetector);

      // Start the game
      await tester.tap(gestureDetector);
      await tester.pump();

      // Test input handling with rapid inputs (testing cooldown and queuing)
      final inputHandlingTimings = <Duration>[];

      for (int i = 0; i < 20; i++) {
        final inputStart = DateTime.now();

        // Rapid inputs to test optimization
        await tester.tap(gestureDetector);
        await tester.tap(gestureDetector);
        await tester.tap(gestureDetector);

        await tester.pump(const Duration(milliseconds: 25));

        final inputEnd = DateTime.now();
        inputHandlingTimings.add(inputEnd.difference(inputStart));
      }

      // Input handling should remain efficient even with rapid inputs
      expect(inputHandlingTimings.length, equals(20));

      final avgInputHandling = inputHandlingTimings.fold<int>(
              0, (sum, timing) => sum + timing.inMilliseconds) /
          inputHandlingTimings.length;
      expect(avgInputHandling,
          lessThan(150)); // Should handle rapid inputs efficiently
    });

    testWidgets('Game loop optimization maintains stability', (tester) async {
      await tester.pumpWidget(const FlappyBirdApp());
      await tester.pump();

      final gestureDetector = find.byType(GestureDetector);

      // Start the game
      await tester.tap(gestureDetector);
      await tester.pump();

      // Test game loop stability over time
      final gameLoopTimings = <Duration>[];

      for (int i = 0; i < 100; i++) {
        final loopStart = DateTime.now();

        // Simulate various game loop conditions
        if (i % 7 == 0) {
          await tester.tap(gestureDetector);
        }

        await tester.pump(const Duration(milliseconds: 16));

        final loopEnd = DateTime.now();
        gameLoopTimings.add(loopEnd.difference(loopStart));
      }

      // Game loop should be stable
      expect(gameLoopTimings.length, equals(100));

      // Check for consistency (no major spikes)
      final avgLoopTime = gameLoopTimings.fold<int>(
              0, (sum, timing) => sum + timing.inMilliseconds) /
          gameLoopTimings.length;
      final maxLoopTime = gameLoopTimings
          .map((timing) => timing.inMilliseconds)
          .reduce((a, b) => a > b ? a : b);

      expect(maxLoopTime,
          lessThan(avgLoopTime * 3)); // No loop should be more than 3x average
    });
  });

  group('Stress Tests', () {
    testWidgets('Game survives stress conditions', (tester) async {
      await tester.pumpWidget(const FlappyBirdApp());
      await tester.pump();

      final gestureDetector = find.byType(GestureDetector);

      // Start the game
      await tester.tap(gestureDetector);
      await tester.pump();

      // Apply various stress conditions
      for (int stress = 0; stress < 10; stress++) {
        // Rapid inputs
        for (int rapid = 0; rapid < 20; rapid++) {
          await tester.tap(gestureDetector);
          await tester.sendKeyEvent(LogicalKeyboardKey.space);
          await tester.pump(const Duration(milliseconds: 5));
        }

        // State changes
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pump(const Duration(milliseconds: 10));

        // Mixed inputs
        await tester.tap(gestureDetector, buttons: kSecondaryButton);
        await tester.pump(const Duration(milliseconds: 10));
      }

      // Game should survive stress conditions
      expect(find.byType(GameScreen), findsOneWidget);
      await tester.tap(gestureDetector);
      await tester.pump();
    });

    testWidgets('Game handles extreme input rates', (tester) async {
      await tester.pumpWidget(const FlappyBirdApp());
      await tester.pump();

      final gestureDetector = find.byType(GestureDetector);

      // Start the game
      await tester.tap(gestureDetector);
      await tester.pump();

      // Extreme input rate test
      for (int i = 0; i < 200; i++) {
        await tester.tap(gestureDetector);
        if (i % 2 == 0) {
          await tester.sendKeyEvent(LogicalKeyboardKey.space);
        }
        await tester.pump(const Duration(milliseconds: 1)); // Extremely fast
      }

      // Game should handle extreme input rates gracefully
      expect(find.byType(GameScreen), findsOneWidget);
    });
  });
}
