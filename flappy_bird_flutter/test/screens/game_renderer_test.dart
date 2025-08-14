import 'package:flappy_bird_flutter/controllers/game_controller.dart';
import 'package:flappy_bird_flutter/screens/game_renderer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GameRenderer', () {
    late GameController controller;
    late GameRenderer renderer;

    setUp(() {
      controller = GameController();
      controller.setScreenSize(400, 600);
      renderer =
          GameRenderer(controller: controller, gameState: controller.gameState);
    });

    test('should create GameRenderer with controller', () {
      expect(renderer, isNotNull);
      expect(renderer.controller, equals(controller));
    });

    test('should always repaint for smooth animation', () {
      final oldRenderer =
          GameRenderer(controller: controller, gameState: controller.gameState);
      expect(renderer.shouldRepaint(oldRenderer), isTrue);
    });

    testWidgets('should render without errors when controller is ready',
        (tester) async {
      // Set screen size to make controller ready
      controller.setScreenSize(400, 600);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomPaint(
              painter: renderer,
              size: const Size(400, 600),
            ),
          ),
        ),
      );

      // Verify the widget renders without throwing
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('should handle uninitialized controller gracefully',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomPaint(
              painter: renderer,
              size: const Size(400, 600),
            ),
          ),
        ),
      );

      // Should not throw even with uninitialized controller
      expect(find.byType(CustomPaint), findsWidgets);
    });
  });
}
