// This is a basic Flutter widget test for Flappy Bird Flutter.

import 'package:flappy_bird_flutter/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Flappy Bird app loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FlappyBirdApp());

    // Verify that the game screen loads with the game components.
    expect(find.byType(GameScreen), findsOneWidget);
    expect(find.byType(GestureDetector), findsOneWidget);
    expect(find.byType(CustomPaint), findsAtLeastNWidgets(1));
  });
}
