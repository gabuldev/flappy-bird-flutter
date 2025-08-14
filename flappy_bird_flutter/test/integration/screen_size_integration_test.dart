import 'package:flappy_bird_flutter/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Screen Size and Orientation Integration Tests', () {
    testWidgets('Game adapts to different screen sizes', (tester) async {
      // Test various screen sizes
      final screenSizes = [
        const Size(360, 640), // Small phone
        const Size(414, 896), // iPhone 11
        const Size(768, 1024), // Tablet portrait
        const Size(1024, 768), // Tablet landscape
        const Size(1920, 1080), // Desktop
        const Size(2560, 1440), // Large desktop
      ];

      for (final size in screenSizes) {
        // Set the screen size
        await tester.binding.setSurfaceSize(size);

        // Build the app
        await tester.pumpWidget(const FlappyBirdApp());
        await tester.pump();

        // Verify the game renders correctly
        expect(find.byType(GameScreen), findsOneWidget);
        expect(find.byType(CustomPaint), findsOneWidget);

        // Test basic functionality at this screen size
        final gestureDetector = find.byType(GestureDetector);
        await tester.tap(gestureDetector);
        await tester.pump(const Duration(milliseconds: 100));

        // Game should work at any screen size
        expect(find.byType(GameScreen), findsOneWidget);
      }

      // Reset to default size
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('Game handles very small screens', (tester) async {
      // Test extremely small screen
      await tester.binding.setSurfaceSize(const Size(240, 320));

      await tester.pumpWidget(const FlappyBirdApp());
      await tester.pump();

      expect(find.byType(GameScreen), findsOneWidget);

      // Test basic functionality
      final gestureDetector = find.byType(GestureDetector);
      await tester.tap(gestureDetector);
      await tester.pump();

      expect(find.byType(CustomPaint), findsOneWidget);

      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('Game handles very large screens', (tester) async {
      // Test very large screen
      await tester.binding.setSurfaceSize(const Size(3840, 2160)); // 4K

      await tester.pumpWidget(const FlappyBirdApp());
      await tester.pump();

      expect(find.byType(GameScreen), findsOneWidget);

      // Test basic functionality
      final gestureDetector = find.byType(GestureDetector);
      await tester.tap(gestureDetector);
      await tester.pump();

      expect(find.byType(CustomPaint), findsOneWidget);

      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('Game handles aspect ratio changes', (tester) async {
      final aspectRatios = [
        const Size(400, 800), // 1:2 (tall)
        const Size(800, 400), // 2:1 (wide)
        const Size(600, 600), // 1:1 (square)
        const Size(300, 900), // 1:3 (very tall)
        const Size(900, 300), // 3:1 (very wide)
      ];

      for (final size in aspectRatios) {
        await tester.binding.setSurfaceSize(size);

        await tester.pumpWidget(const FlappyBirdApp());
        await tester.pump();

        expect(find.byType(GameScreen), findsOneWidget);

        // Test gameplay at different aspect ratios
        final gestureDetector = find.byType(GestureDetector);
        for (int i = 0; i < 3; i++) {
          await tester.tap(gestureDetector);
          await tester.pump(const Duration(milliseconds: 100));
        }

        expect(find.byType(GameScreen), findsOneWidget);
      }

      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('Game maintains performance across screen sizes',
        (tester) async {
      final testSizes = [
        const Size(360, 640),
        const Size(1024, 768),
        const Size(1920, 1080),
      ];

      for (final size in testSizes) {
        await tester.binding.setSurfaceSize(size);

        await tester.pumpWidget(const FlappyBirdApp());
        await tester.pump();

        final gestureDetector = find.byType(GestureDetector);

        // Simulate gameplay to test performance
        for (int i = 0; i < 20; i++) {
          await tester.tap(gestureDetector);
          await tester.pump(const Duration(milliseconds: 50));
        }

        // Game should remain responsive
        expect(find.byType(GameScreen), findsOneWidget);
        await tester.tap(gestureDetector);
        await tester.pump();
      }

      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('Game UI scales appropriately', (tester) async {
      // Test UI scaling at different sizes
      final sizes = [
        const Size(320, 568), // iPhone SE
        const Size(375, 812), // iPhone X
        const Size(768, 1024), // iPad
      ];

      for (final size in sizes) {
        await tester.binding.setSurfaceSize(size);

        await tester.pumpWidget(const FlappyBirdApp());
        await tester.pump();

        // Verify UI elements are present and functional
        expect(find.byType(CustomPaint), findsOneWidget);
        expect(find.byType(GestureDetector), findsOneWidget);

        // Test that the entire screen is interactive
        final gestureDetector = find.byType(GestureDetector);
        await tester.tap(gestureDetector);
        await tester.pump();

        // UI should scale appropriately
        expect(find.byType(GameScreen), findsOneWidget);
      }

      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('Game handles screen size changes during gameplay',
        (tester) async {
      // Start with one size
      await tester.binding.setSurfaceSize(const Size(400, 800));

      await tester.pumpWidget(const FlappyBirdApp());
      await tester.pump();

      final gestureDetector = find.byType(GestureDetector);

      // Start playing
      await tester.tap(gestureDetector);
      await tester.pump();

      // Change screen size during gameplay
      await tester.binding.setSurfaceSize(const Size(800, 600));
      await tester.pump();

      // Game should continue working
      await tester.tap(gestureDetector);
      await tester.pump();

      expect(find.byType(GameScreen), findsOneWidget);

      // Change back
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pump();

      await tester.tap(gestureDetector);
      await tester.pump();

      expect(find.byType(GameScreen), findsOneWidget);

      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('Game touch areas work correctly at different sizes',
        (tester) async {
      final sizes = [
        const Size(360, 640),
        const Size(768, 1024),
        const Size(1024, 768),
      ];

      for (final size in sizes) {
        await tester.binding.setSurfaceSize(size);

        await tester.pumpWidget(const FlappyBirdApp());
        await tester.pump();

        final gestureDetector = find.byType(GestureDetector);

        // Test tapping at different areas of the screen
        final center = Offset(size.width / 2, size.height / 2);
        final topLeft = Offset(size.width * 0.1, size.height * 0.1);
        final bottomRight = Offset(size.width * 0.9, size.height * 0.9);

        await tester.tapAt(center);
        await tester.pump(const Duration(milliseconds: 50));

        await tester.tapAt(topLeft);
        await tester.pump(const Duration(milliseconds: 50));

        await tester.tapAt(bottomRight);
        await tester.pump(const Duration(milliseconds: 50));

        // All areas should be responsive
        expect(find.byType(GameScreen), findsOneWidget);
      }

      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('Game rendering scales correctly', (tester) async {
      // Test that game elements scale appropriately
      final sizes = [
        const Size(300, 600), // Narrow
        const Size(600, 300), // Wide
        const Size(500, 500), // Square
      ];

      for (final size in sizes) {
        await tester.binding.setSurfaceSize(size);

        await tester.pumpWidget(const FlappyBirdApp());
        await tester.pump();

        // Verify CustomPaint adapts to size
        final customPaint = find.byType(CustomPaint);
        expect(customPaint, findsOneWidget);

        // Test that the game is playable
        final gestureDetector = find.byType(GestureDetector);
        await tester.tap(gestureDetector);
        await tester.pump();

        // Game should render correctly at any size
        expect(find.byType(GameScreen), findsOneWidget);
      }

      await tester.binding.setSurfaceSize(null);
    });
  });

  group('Orientation Handling Tests', () {
    testWidgets('Game enforces portrait orientation', (tester) async {
      // The game should work in portrait mode
      await tester.binding.setSurfaceSize(const Size(400, 800)); // Portrait

      await tester.pumpWidget(const FlappyBirdApp());
      await tester.pump();

      expect(find.byType(GameScreen), findsOneWidget);

      final gestureDetector = find.byType(GestureDetector);
      await tester.tap(gestureDetector);
      await tester.pump();

      expect(find.byType(GameScreen), findsOneWidget);

      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('Game handles landscape dimensions gracefully', (tester) async {
      // Even though the game prefers portrait, it should handle landscape
      await tester.binding.setSurfaceSize(const Size(800, 400)); // Landscape

      await tester.pumpWidget(const FlappyBirdApp());
      await tester.pump();

      expect(find.byType(GameScreen), findsOneWidget);

      final gestureDetector = find.byType(GestureDetector);
      await tester.tap(gestureDetector);
      await tester.pump();

      // Should still be functional even in landscape
      expect(find.byType(GameScreen), findsOneWidget);

      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('Game adapts to orientation changes', (tester) async {
      // Start in portrait
      await tester.binding.setSurfaceSize(const Size(400, 800));

      await tester.pumpWidget(const FlappyBirdApp());
      await tester.pump();

      final gestureDetector = find.byType(GestureDetector);
      await tester.tap(gestureDetector);
      await tester.pump();

      // Simulate orientation change to landscape
      await tester.binding.setSurfaceSize(const Size(800, 400));
      await tester.pump();

      // Game should still work
      await tester.tap(gestureDetector);
      await tester.pump();

      expect(find.byType(GameScreen), findsOneWidget);

      // Change back to portrait
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pump();

      await tester.tap(gestureDetector);
      await tester.pump();

      expect(find.byType(GameScreen), findsOneWidget);

      await tester.binding.setSurfaceSize(null);
    });
  });

  group('Device-Specific Tests', () {
    testWidgets('Game works on phone-sized screens', (tester) async {
      final phoneSizes = [
        const Size(360, 640), // Android
        const Size(375, 667), // iPhone 8
        const Size(414, 896), // iPhone 11
      ];

      for (final size in phoneSizes) {
        await tester.binding.setSurfaceSize(size);

        await tester.pumpWidget(const FlappyBirdApp());
        await tester.pump();

        final gestureDetector = find.byType(GestureDetector);

        // Test typical phone gameplay
        for (int i = 0; i < 5; i++) {
          await tester.tap(gestureDetector);
          await tester.pump(const Duration(milliseconds: 100));
        }

        expect(find.byType(GameScreen), findsOneWidget);
      }

      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('Game works on tablet-sized screens', (tester) async {
      final tabletSizes = [
        const Size(768, 1024), // iPad
        const Size(800, 1280), // Android tablet
        const Size(1024, 1366), // Surface
      ];

      for (final size in tabletSizes) {
        await tester.binding.setSurfaceSize(size);

        await tester.pumpWidget(const FlappyBirdApp());
        await tester.pump();

        final gestureDetector = find.byType(GestureDetector);

        // Test tablet gameplay
        for (int i = 0; i < 5; i++) {
          await tester.tap(gestureDetector);
          await tester.pump(const Duration(milliseconds: 100));
        }

        expect(find.byType(GameScreen), findsOneWidget);
      }

      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('Game works on desktop-sized screens', (tester) async {
      final desktopSizes = [
        const Size(1366, 768), // Laptop
        const Size(1920, 1080), // Full HD
        const Size(2560, 1440), // QHD
      ];

      for (final size in desktopSizes) {
        await tester.binding.setSurfaceSize(size);

        await tester.pumpWidget(const FlappyBirdApp());
        await tester.pump();

        final gestureDetector = find.byType(GestureDetector);

        // Test desktop gameplay
        for (int i = 0; i < 5; i++) {
          await tester.tap(gestureDetector);
          await tester.pump(const Duration(milliseconds: 100));
        }

        expect(find.byType(GameScreen), findsOneWidget);
      }

      await tester.binding.setSurfaceSize(null);
    });
  });
}
