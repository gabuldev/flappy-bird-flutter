import 'package:flappy_bird_flutter/models/pipe.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Pipe Model Tests', () {
    late Pipe pipe;
    const screenHeight = 800.0;
    const testX = 400.0;
    const testTopHeight = 300.0;
    const testBottomHeight = 350.0;

    setUp(() {
      pipe = Pipe(
        x: testX,
        topHeight: testTopHeight,
        bottomHeight: testBottomHeight,
      );
    });

    test('should initialize with correct values', () {
      expect(pipe.x, equals(testX));
      expect(pipe.topHeight, equals(testTopHeight));
      expect(pipe.bottomHeight, equals(testBottomHeight));
      expect(pipe.gapSize, equals(Pipe.defaultGapSize));
      expect(pipe.scored, isFalse);
    });

    test('should create pipe with gap correctly', () {
      const gapY = 400.0;
      const gapSize = 150.0;

      final pipeWithGap = Pipe.withGap(
        x: testX,
        screenHeight: screenHeight,
        gapY: gapY,
        gapSize: gapSize,
      );

      expect(pipeWithGap.x, equals(testX));
      expect(pipeWithGap.topHeight, equals(gapY - gapSize / 2));
      expect(pipeWithGap.bottomHeight,
          equals(screenHeight - (gapY + gapSize / 2)));
      expect(pipeWithGap.gapSize, equals(gapSize));
    });

    test('should update position correctly', () {
      const deltaTime = 1.0 / 60.0;
      final originalX = pipe.x;

      pipe.update(deltaTime);

      expect(pipe.x, closeTo(originalX - Pipe.speed * deltaTime, 0.01));
    });

    test('should detect when off screen', () {
      // Pipe on screen
      pipe.x = 100.0;
      expect(pipe.isOffScreen(), isFalse);

      // Pipe just off screen
      pipe.x = -Pipe.width - 1;
      expect(pipe.isOffScreen(), isTrue);

      // Pipe at edge
      pipe.x = -Pipe.width;
      expect(pipe.isOffScreen(), isFalse);
    });

    test('should return correct bounds for top and bottom pipes', () {
      final bounds = pipe.getBounds();

      expect(bounds.length, equals(2));

      // Top pipe bounds
      final topBounds = bounds[0];
      expect(topBounds.left, equals(testX));
      expect(topBounds.top, equals(0));
      expect(topBounds.width, equals(Pipe.width));
      expect(topBounds.height, equals(testTopHeight));

      // Bottom pipe bounds
      final bottomBounds = bounds[1];
      expect(bottomBounds.left, equals(testX));
      expect(bottomBounds.top, equals(testTopHeight + pipe.gapSize));
      expect(bottomBounds.width, equals(Pipe.width));
      expect(bottomBounds.height, equals(testBottomHeight));
    });

    test('should return correct gap bounds', () {
      final gapBounds = pipe.getGapBounds();

      expect(gapBounds.left, equals(testX));
      expect(gapBounds.top, equals(testTopHeight));
      expect(gapBounds.width, equals(Pipe.width));
      expect(gapBounds.height, equals(pipe.gapSize));
    });

    test('should detect when point has passed', () {
      const pointX = testX + Pipe.width + 10;

      // Should detect passing when not scored
      expect(pipe.hasPassedPoint(pointX), isTrue);

      // Should not detect passing when already scored
      pipe.markAsScored();
      expect(pipe.hasPassedPoint(pointX), isFalse);

      // Should not detect passing when point hasn't passed yet
      pipe.scored = false;
      const pointXBefore = testX + Pipe.width - 10;
      expect(pipe.hasPassedPoint(pointXBefore), isFalse);
    });

    test('should mark as scored correctly', () {
      expect(pipe.scored, isFalse);

      pipe.markAsScored();

      expect(pipe.scored, isTrue);
    });

    test('should reset correctly', () {
      // Modify pipe state
      pipe.markAsScored();

      const newX = 600.0;
      const newGapY = 350.0;
      const newGapSize = 120.0;

      pipe.reset(
        newX: newX,
        screenHeight: screenHeight,
        gapY: newGapY,
        newGapSize: newGapSize,
      );

      expect(pipe.x, equals(newX));
      expect(pipe.gapSize, equals(newGapSize));
      expect(pipe.topHeight, equals(newGapY - newGapSize / 2));
      expect(
          pipe.bottomHeight, equals(screenHeight - (newGapY + newGapSize / 2)));
      expect(pipe.scored, isFalse);
    });

    test('should reset without changing gap size when not provided', () {
      final originalGapSize = pipe.gapSize;
      const newX = 600.0;
      const newGapY = 350.0;

      pipe.reset(
        newX: newX,
        screenHeight: screenHeight,
        gapY: newGapY,
      );

      expect(pipe.gapSize, equals(originalGapSize));
    });

    test('should return correct gap center Y', () {
      final expectedCenterY = testTopHeight + pipe.gapSize / 2;

      expect(pipe.getGapCenterY(), equals(expectedCenterY));
    });

    test('should detect visibility correctly', () {
      const screenWidth = 800.0;

      // Visible on screen
      pipe.x = 100.0;
      expect(pipe.isVisible(screenWidth), isTrue);

      // Just off screen to the right
      pipe.x = screenWidth + 1;
      expect(pipe.isVisible(screenWidth), isFalse);

      // Just off screen to the left
      pipe.x = -Pipe.width - 1;
      expect(pipe.isVisible(screenWidth), isFalse);

      // At right edge
      pipe.x = screenWidth;
      expect(pipe.isVisible(screenWidth), isFalse);

      // At left edge
      pipe.x = -Pipe.width;
      expect(pipe.isVisible(screenWidth), isFalse);
    });

    test('should return correct edge positions', () {
      expect(pipe.getLeftEdge(), equals(testX));
      expect(pipe.getRightEdge(), equals(testX + Pipe.width));
    });

    test('should handle zero height pipes correctly', () {
      final pipeWithZeroTop = Pipe(
        x: testX,
        topHeight: 0,
        bottomHeight: testBottomHeight,
      );

      final bounds = pipeWithZeroTop.getBounds();

      // Should only have bottom pipe bounds
      expect(bounds.length, equals(1));
      expect(bounds[0].top, equals(pipeWithZeroTop.gapSize));
    });

    test('should handle negative height pipes correctly', () {
      final pipeWithNegativeTop = Pipe(
        x: testX,
        topHeight: -10,
        bottomHeight: testBottomHeight,
      );

      final bounds = pipeWithNegativeTop.getBounds();

      // Should only have bottom pipe bounds when top height is negative
      expect(bounds.length, equals(1));
    });

    test('should maintain gap size consistency', () {
      const gapY = 400.0;
      const customGapSize = 200.0;

      final pipeWithCustomGap = Pipe.withGap(
        x: testX,
        screenHeight: screenHeight,
        gapY: gapY,
        gapSize: customGapSize,
      );

      const calculatedGapSize =
          (gapY + customGapSize / 2) - (gapY - customGapSize / 2);
      expect(calculatedGapSize, equals(customGapSize));

      // Verify the gap bounds match the specified size
      final gapBounds = pipeWithCustomGap.getGapBounds();
      expect(gapBounds.height, equals(customGapSize));
    });
  });
}
