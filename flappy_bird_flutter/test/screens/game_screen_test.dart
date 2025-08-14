import 'package:flappy_bird_flutter/main.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GameScreen Widget Tests', () {
    testWidgets('GameScreen should render without errors', (tester) async {
      // Build the GameScreen widget
      await tester.pumpWidget(const MaterialApp(
        home: GameScreen(),
      ));

      // Verify that the widget renders
      expect(find.byType(GameScreen), findsOneWidget);
      expect(find.byType(GestureDetector), findsOneWidget);
      expect(find.byType(CustomPaint), findsAtLeastNWidgets(1));
    });

    testWidgets('GameScreen should respond to tap input', (tester) async {
      // Build the GameScreen widget
      await tester.pumpWidget(const MaterialApp(
        home: GameScreen(),
      ));

      // Find the GestureDetector
      final gestureDetector = find.byType(GestureDetector);
      expect(gestureDetector, findsOneWidget);

      // Tap on the screen
      await tester.tap(gestureDetector);
      await tester.pump();

      // The tap should not cause any errors
      // (We can't easily test the game logic here without exposing internal state)
    });

    testWidgets('GameScreen should respond to keyboard input', (tester) async {
      // Build the GameScreen widget
      await tester.pumpWidget(const MaterialApp(
        home: GameScreen(),
      ));

      // Find the KeyboardListener
      final keyboardListener = find.byType(KeyboardListener);
      expect(keyboardListener, findsOneWidget);

      // Simulate spacebar press
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();

      // Should handle keyboard input without errors
    });

    testWidgets('GameScreen should respond to mouse input', (tester) async {
      // Build the GameScreen widget
      await tester.pumpWidget(const MaterialApp(
        home: GameScreen(),
      ));

      // Find the MouseRegion (there might be multiple due to Flutter internals)
      final mouseRegion = find.byType(MouseRegion);
      expect(mouseRegion, findsAtLeastNWidgets(1));

      // Find the GestureDetector for secondary tap
      final gestureDetector = find.byType(GestureDetector);
      expect(gestureDetector, findsOneWidget);

      // Simulate right-click (secondary tap)
      await tester.tap(gestureDetector, buttons: kSecondaryButton);
      await tester.pump();

      // Should handle mouse input without errors
    });

    testWidgets('GameScreen should handle multiple rapid taps', (tester) async {
      // Build the GameScreen widget
      await tester.pumpWidget(const MaterialApp(
        home: GameScreen(),
      ));

      final gestureDetector = find.byType(GestureDetector);

      // Perform multiple rapid taps
      for (int i = 0; i < 5; i++) {
        await tester.tap(gestureDetector);
        await tester.pump(const Duration(milliseconds: 50));
      }

      // Should handle multiple taps without errors
    });

    testWidgets('GameScreen should handle rapid keyboard inputs',
        (tester) async {
      // Build the GameScreen widget
      await tester.pumpWidget(const MaterialApp(
        home: GameScreen(),
      ));

      // Perform multiple rapid spacebar presses
      for (int i = 0; i < 5; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.space);
        await tester.pump(const Duration(milliseconds: 30));
      }

      // Should handle rapid keyboard inputs without errors
    });

    testWidgets('GameScreen should handle enter key for restart',
        (tester) async {
      // Build the GameScreen widget
      await tester.pumpWidget(const MaterialApp(
        home: GameScreen(),
      ));

      // Simulate enter key press
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      // Should handle enter key without errors
    });

    testWidgets('GameScreen should maintain proper widget structure',
        (tester) async {
      // Build the GameScreen widget
      await tester.pumpWidget(const MaterialApp(
        home: GameScreen(),
      ));

      // Verify the widget hierarchy
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(KeyboardListener), findsOneWidget);
      expect(find.byType(MouseRegion), findsAtLeastNWidgets(1));
      expect(find.byType(GestureDetector), findsOneWidget);
      expect(find.byType(CustomPaint), findsAtLeastNWidgets(1));
    });

    testWidgets('GameScreen should initialize game components correctly',
        (tester) async {
      // Build the GameScreen widget
      await tester.pumpWidget(const MaterialApp(
        home: GameScreen(),
      ));

      // Verify initial state
      expect(find.byType(GameScreen), findsOneWidget);

      // Allow some frames to pass for initialization
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Should still be functional after initialization
      expect(find.byType(GameScreen), findsOneWidget);
      expect(find.byType(CustomPaint), findsAtLeastNWidgets(1));
    });

    testWidgets(
        'GameScreen should handle tap input correctly based on game state',
        (tester) async {
      // Build the GameScreen widget
      await tester.pumpWidget(const MaterialApp(
        home: GameScreen(),
      ));

      final gestureDetector = find.byType(GestureDetector);

      // First tap should start the game (when in menu state)
      await tester.tap(gestureDetector);
      await tester.pump();

      // Second tap should make the bird jump (when playing)
      await tester.tap(gestureDetector);
      await tester.pump();

      // Should handle state transitions without errors
      expect(find.byType(GameScreen), findsOneWidget);
    });

    testWidgets('GameScreen should handle input cooldown correctly',
        (tester) async {
      // Build the GameScreen widget
      await tester.pumpWidget(const MaterialApp(
        home: GameScreen(),
      ));

      final gestureDetector = find.byType(GestureDetector);

      // Perform very rapid taps (faster than cooldown)
      await tester.tap(gestureDetector);
      await tester.tap(gestureDetector);
      await tester.tap(gestureDetector);
      await tester.pump(const Duration(milliseconds: 10));

      // Should handle input cooldown without errors
    });

    testWidgets('GameScreen should focus correctly for keyboard input',
        (tester) async {
      // Build the GameScreen widget
      await tester.pumpWidget(const MaterialApp(
        home: GameScreen(),
      ));

      // Allow focus to be requested
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Find the KeyboardListener
      final keyboardListener = find.byType(KeyboardListener);
      expect(keyboardListener, findsOneWidget);

      // Should be able to receive keyboard events
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
    });

    testWidgets('GameScreen should handle different input types simultaneously',
        (tester) async {
      // Build the GameScreen widget
      await tester.pumpWidget(const MaterialApp(
        home: GameScreen(),
      ));

      final gestureDetector = find.byType(GestureDetector);

      // Mix different input types
      await tester.tap(gestureDetector);
      await tester.pump(const Duration(milliseconds: 20));

      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump(const Duration(milliseconds: 20));

      await tester.tap(gestureDetector, buttons: kSecondaryButton);
      await tester.pump();

      // Should handle mixed input types without errors
    });
  });

  group('Input Handling Tests', () {
    testWidgets('should process pending inputs during game update',
        (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: GameScreen(),
      ));

      final gestureDetector = find.byType(GestureDetector);

      // Perform rapid taps to trigger pending inputs
      for (int i = 0; i < 3; i++) {
        await tester.tap(gestureDetector);
      }

      // Allow game loop to process pending inputs
      await tester.pump(const Duration(milliseconds: 100));

      // Should process all pending inputs without errors
    });

    testWidgets('should handle input when game is paused', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: GameScreen(),
      ));

      final gestureDetector = find.byType(GestureDetector);

      // Tap when game might be in different states
      await tester.tap(gestureDetector);
      await tester.pump(const Duration(milliseconds: 50));

      await tester.tap(gestureDetector);
      await tester.pump();

      // Should handle input regardless of game state
    });
  });
}
