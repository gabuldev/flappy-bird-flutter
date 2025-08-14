import 'dart:ui';

/// Physics constants and utility functions for the Flappy Bird game
class Physics {
  // Physics constants
  static const double gravity = 980.0; // pixels/second²
  static const double jumpVelocity =
      -350.0; // pixels/second (negative = upward)
  static const double terminalVelocity = 500.0; // maximum falling speed
  static const double pipeSpeed = 200.0; // pixels/second (horizontal movement)

  // Game constants
  static const double birdSize = 30.0; // bird radius for collision
  static const double pipeWidth = 60.0; // pipe width
  static const double pipeGap = 150.0; // gap between top and bottom pipes

  /// Applies gravity to the current velocity
  /// Returns the new velocity after applying gravity for the given deltaTime
  static double applyGravity(double currentVelocity, double deltaTime) {
    double newVelocity = currentVelocity + (gravity * deltaTime);

    // Clamp to terminal velocity to prevent infinite acceleration
    if (newVelocity > terminalVelocity) {
      newVelocity = terminalVelocity;
    }

    return newVelocity;
  }

  /// Checks if two rectangles are colliding
  /// Returns true if rectangles overlap, false otherwise
  static bool checkRectCollision(Rect rectA, Rect rectB) {
    return rectA.overlaps(rectB);
  }

  /// Checks if a circular object collides with a rectangle
  /// Useful for bird (circle) vs pipe (rectangle) collision
  static bool checkCircleRectCollision(
      double circleX, double circleY, double circleRadius, Rect rect) {
    // Find the closest point on the rectangle to the circle center
    double closestX = circleX.clamp(rect.left, rect.right);
    double closestY = circleY.clamp(rect.top, rect.bottom);

    // Calculate distance between circle center and closest point
    double distanceX = circleX - closestX;
    double distanceY = circleY - closestY;
    double distanceSquared = (distanceX * distanceX) + (distanceY * distanceY);

    // Check if distance is less than circle radius
    return distanceSquared < (circleRadius * circleRadius);
  }
}
