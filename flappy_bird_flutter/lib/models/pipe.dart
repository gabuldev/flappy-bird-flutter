import 'dart:ui';

class Pipe {
  // Position properties
  double x;
  double topHeight;
  double bottomHeight;
  double gapSize;

  // State
  bool scored;

  // Constants
  static const double width = 52.0;
  static const double speed = 200.0; // pixels/second
  static const double defaultGapSize = 150.0;

  Pipe({
    required this.x,
    required this.topHeight,
    required this.bottomHeight,
    this.gapSize = defaultGapSize,
    this.scored = false,
  });

  /// Factory constructor to create a pipe with a gap at specified position
  factory Pipe.withGap({
    required double x,
    required double screenHeight,
    required double gapY,
    double gapSize = defaultGapSize,
  }) {
    final topHeight = gapY - gapSize / 2;
    final bottomHeight = screenHeight - (gapY + gapSize / 2);

    return Pipe(
      x: x,
      topHeight: topHeight,
      bottomHeight: bottomHeight,
      gapSize: gapSize,
    );
  }

  /// Updates the pipe position
  void update(double deltaTime) {
    x -= speed * deltaTime;
  }

  /// Checks if the pipe is completely off screen (left side)
  bool isOffScreen() {
    return x + width < 0;
  }

  /// Returns the collision bounds for both top and bottom pipes
  List<Rect> getBounds() {
    final List<Rect> bounds = [];

    // Top pipe bounds
    if (topHeight > 0) {
      bounds.add(Rect.fromLTWH(
        x,
        0,
        width,
        topHeight,
      ));
    }

    // Bottom pipe bounds
    if (bottomHeight > 0) {
      bounds.add(Rect.fromLTWH(
        x,
        topHeight + gapSize,
        width,
        bottomHeight,
      ));
    }

    return bounds;
  }

  /// Returns the bounds of the gap (for scoring detection)
  Rect getGapBounds() {
    return Rect.fromLTWH(
      x,
      topHeight,
      width,
      gapSize,
    );
  }

  /// Checks if a point has passed through this pipe (for scoring)
  bool hasPassedPoint(double pointX) {
    return !scored && pointX > x + width;
  }

  /// Marks this pipe as scored
  void markAsScored() {
    scored = true;
  }

  /// Resets the pipe to a new position with new gap configuration
  void reset({
    required double newX,
    required double screenHeight,
    required double gapY,
    double? newGapSize,
  }) {
    x = newX;
    gapSize = newGapSize ?? gapSize;
    topHeight = gapY - gapSize / 2;
    bottomHeight = screenHeight - (gapY + gapSize / 2);
    scored = false;
  }

  /// Gets the center Y position of the gap
  double getGapCenterY() {
    return topHeight + gapSize / 2;
  }

  /// Checks if the pipe is visible on screen
  bool isVisible(double screenWidth) {
    return x + width > 0 && x < screenWidth;
  }

  /// Gets the left edge X position
  double getLeftEdge() {
    return x;
  }

  /// Gets the right edge X position
  double getRightEdge() {
    return x + width;
  }
}
