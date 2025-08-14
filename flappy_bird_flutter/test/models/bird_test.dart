import 'package:flappy_bird_flutter/models/bird.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Bird Model Tests', () {
    late Bird bird;

    setUp(() {
      bird = Bird(x: 100, y: 200);
    });

    test('should initialize with correct default values', () {
      expect(bird.x, equals(100));
      expect(bird.y, equals(200));
      expect(bird.velocityY, equals(0.0));
      expect(bird.rotation, equals(0.0));
      expect(bird.state, equals(BirdState.flying));
    });

    test('should apply gravity correctly', () {
      const deltaTime = 1.0 / 60.0; // 60 FPS
      const expectedVelocity = Bird.gravity * deltaTime;

      bird.applyGravity(deltaTime);

      expect(bird.velocityY, closeTo(expectedVelocity, 0.01));
    });

    test('should jump correctly', () {
      bird.jump();

      expect(bird.velocityY, equals(Bird.jumpVelocity));
      expect(bird.state, equals(BirdState.flying));
    });

    test('should not jump when dead', () {
      bird.die();
      const originalVelocity = 0.0;

      bird.jump();

      expect(bird.velocityY, equals(originalVelocity));
      expect(bird.state, equals(BirdState.dead));
    });

    test('should update position correctly', () {
      const deltaTime = 1.0 / 60.0;
      const testVelocity = 100.0;
      bird.velocityY = testVelocity;
      final originalY = bird.y;

      bird.update(deltaTime);

      // Position should be updated by initial velocity plus gravity effect
      final expectedVelocityAfterGravity =
          testVelocity + Bird.gravity * deltaTime;
      final expectedY = originalY + testVelocity * deltaTime;

      expect(bird.y, closeTo(expectedY, 0.5)); // Allow for gravity effect
      expect(bird.velocityY, closeTo(expectedVelocityAfterGravity, 0.01));
    });

    test('should change state to falling when velocity is positive', () {
      bird.velocityY = 100.0; // Positive velocity = falling
      const deltaTime = 1.0 / 60.0;

      bird.update(deltaTime);

      expect(bird.state, equals(BirdState.falling));
    });

    test('should change state to flying when velocity is negative', () {
      bird.velocityY = -100.0; // Negative velocity = flying up
      const deltaTime = 1.0 / 60.0;

      bird.update(deltaTime);

      expect(bird.state, equals(BirdState.flying));
    });

    test('should clamp velocity to terminal velocity', () {
      bird.velocityY =
          Bird.terminalVelocity + 100.0; // Exceed terminal velocity
      const deltaTime = 1.0 / 60.0;

      bird.applyGravity(deltaTime);

      expect(bird.velocityY, equals(Bird.terminalVelocity));
    });

    test('should return correct bounds', () {
      const testX = 100.0;
      const testY = 200.0;
      bird.x = testX;
      bird.y = testY;

      final bounds = bird.getBounds();

      expect(bounds.left, equals(testX - Bird.width / 2));
      expect(bounds.top, equals(testY - Bird.height / 2));
      expect(bounds.width, equals(Bird.width));
      expect(bounds.height, equals(Bird.height));
    });

    test('should reset to initial state correctly', () {
      // Modify bird state
      bird.velocityY = 100.0;
      bird.rotation = 1.0;
      bird.state = BirdState.dead;

      const newX = 50.0;
      const newY = 150.0;
      bird.reset(newX, newY);

      expect(bird.x, equals(newX));
      expect(bird.y, equals(newY));
      expect(bird.velocityY, equals(0.0));
      expect(bird.rotation, equals(0.0));
      expect(bird.state, equals(BirdState.flying));
    });

    test('should die correctly', () {
      bird.velocityY = 100.0;

      bird.die();

      expect(bird.state, equals(BirdState.dead));
      expect(bird.velocityY, equals(0.0));
    });

    test('should detect out of bounds correctly', () {
      const screenHeight = 800.0;

      // Test bird above screen
      bird.y = -Bird.height;
      expect(bird.isOutOfBounds(screenHeight), isTrue);

      // Test bird below screen
      bird.y = screenHeight + Bird.height;
      expect(bird.isOutOfBounds(screenHeight), isTrue);

      // Test bird within bounds
      bird.y = screenHeight / 2;
      expect(bird.isOutOfBounds(screenHeight), isFalse);
    });

    test('should not update when dead', () {
      bird.die();
      final originalY = bird.y;
      const deltaTime = 1.0 / 60.0;

      bird.update(deltaTime);

      expect(bird.y, equals(originalY));
      expect(bird.velocityY, equals(0.0));
    });

    test('should update rotation based on velocity', () {
      const deltaTime = 1.0 / 60.0;
      bird.velocityY = Bird.terminalVelocity / 2; // Half terminal velocity

      bird.update(deltaTime);

      // Rotation should be updated (not zero)
      expect(bird.rotation, isNot(equals(0.0)));
    });
  });
}
