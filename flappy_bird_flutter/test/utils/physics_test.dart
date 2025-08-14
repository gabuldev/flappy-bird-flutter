import 'package:flappy_bird_flutter/utils/physics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Physics Constants', () {
    test('should have correct physics constants', () {
      expect(Physics.gravity, equals(980.0));
      expect(Physics.jumpVelocity, equals(-350.0));
      expect(Physics.terminalVelocity, equals(500.0));
      expect(Physics.pipeSpeed, equals(200.0));
      expect(Physics.birdSize, equals(30.0));
      expect(Physics.pipeWidth, equals(60.0));
      expect(Physics.pipeGap, equals(150.0));
    });
  });

  group('applyGravity', () {
    test('should increase velocity when falling', () {
      double initialVelocity = 0.0;
      double deltaTime = 1.0 / 60.0; // 60 FPS

      double newVelocity = Physics.applyGravity(initialVelocity, deltaTime);

      expect(newVelocity, greaterThan(initialVelocity));
      expect(newVelocity, equals(Physics.gravity * deltaTime));
    });

    test('should continue increasing velocity over time', () {
      double velocity = 0.0;
      double deltaTime = 1.0 / 60.0;

      // Apply gravity multiple times
      velocity = Physics.applyGravity(velocity, deltaTime);
      double firstUpdate = velocity;

      velocity = Physics.applyGravity(velocity, deltaTime);
      double secondUpdate = velocity;

      expect(secondUpdate, greaterThan(firstUpdate));
    });

    test('should clamp velocity to terminal velocity', () {
      double highVelocity = 600.0; // Above terminal velocity
      double deltaTime = 1.0 / 60.0;

      double newVelocity = Physics.applyGravity(highVelocity, deltaTime);

      expect(newVelocity, equals(Physics.terminalVelocity));
    });

    test('should handle negative velocity (upward movement)', () {
      double upwardVelocity = -200.0;
      double deltaTime = 1.0 / 60.0;

      double newVelocity = Physics.applyGravity(upwardVelocity, deltaTime);

      // Should be less negative (closer to 0) due to gravity
      expect(newVelocity, greaterThan(upwardVelocity));
    });

    test('should handle zero delta time', () {
      double velocity = 100.0;
      double deltaTime = 0.0;

      double newVelocity = Physics.applyGravity(velocity, deltaTime);

      expect(newVelocity, equals(velocity));
    });
  });

  group('checkRectCollision', () {
    test('should detect collision when rectangles overlap', () {
      Rect rectA = const Rect.fromLTWH(0, 0, 50, 50);
      Rect rectB = const Rect.fromLTWH(25, 25, 50, 50);

      bool collision = Physics.checkRectCollision(rectA, rectB);

      expect(collision, isTrue);
    });

    test('should not detect collision when rectangles do not overlap', () {
      Rect rectA = const Rect.fromLTWH(0, 0, 50, 50);
      Rect rectB = const Rect.fromLTWH(100, 100, 50, 50);

      bool collision = Physics.checkRectCollision(rectA, rectB);

      expect(collision, isFalse);
    });

    test('should detect collision when rectangles touch edges', () {
      Rect rectA = const Rect.fromLTWH(0, 0, 50, 50);
      Rect rectB = const Rect.fromLTWH(50, 0, 50, 50);

      bool collision = Physics.checkRectCollision(rectA, rectB);

      expect(collision, isFalse); // Touching edges don't overlap
    });

    test('should detect collision when one rectangle is inside another', () {
      Rect rectA = const Rect.fromLTWH(0, 0, 100, 100);
      Rect rectB = const Rect.fromLTWH(25, 25, 50, 50);

      bool collision = Physics.checkRectCollision(rectA, rectB);

      expect(collision, isTrue);
    });
  });

  group('checkCircleRectCollision', () {
    test('should detect collision when circle overlaps rectangle', () {
      double circleX = 50.0;
      double circleY = 50.0;
      double circleRadius = 25.0;
      Rect rect = const Rect.fromLTWH(40, 40, 60, 60);

      bool collision = Physics.checkCircleRectCollision(
          circleX, circleY, circleRadius, rect);

      expect(collision, isTrue);
    });

    test('should not detect collision when circle is far from rectangle', () {
      double circleX = 0.0;
      double circleY = 0.0;
      double circleRadius = 10.0;
      Rect rect = const Rect.fromLTWH(100, 100, 50, 50);

      bool collision = Physics.checkCircleRectCollision(
          circleX, circleY, circleRadius, rect);

      expect(collision, isFalse);
    });

    test('should detect collision when circle center is inside rectangle', () {
      double circleX = 50.0;
      double circleY = 50.0;
      double circleRadius = 10.0;
      Rect rect = const Rect.fromLTWH(0, 0, 100, 100);

      bool collision = Physics.checkCircleRectCollision(
          circleX, circleY, circleRadius, rect);

      expect(collision, isTrue);
    });

    test('should detect collision when circle touches rectangle corner', () {
      double circleX = 0.0;
      double circleY = 0.0;
      double circleRadius = 15.0;
      Rect rect = const Rect.fromLTWH(10, 10, 50, 50);

      bool collision = Physics.checkCircleRectCollision(
          circleX, circleY, circleRadius, rect);

      // Distance from (0,0) to (10,10) is ~14.14, radius is 15
      expect(collision, isTrue);
    });

    test('should not detect collision when circle just misses rectangle corner',
        () {
      double circleX = 0.0;
      double circleY = 0.0;
      double circleRadius = 10.0;
      Rect rect = const Rect.fromLTWH(15, 15, 50, 50);

      bool collision = Physics.checkCircleRectCollision(
          circleX, circleY, circleRadius, rect);

      // Distance from (0,0) to (15,15) is ~21.21, radius is 10
      expect(collision, isFalse);
    });
  });
}
