import 'dart:ui';

enum BirdState { flying, falling, dead }

class Bird {
  // Position properties
  double x;
  double y;

  // Physics properties
  double velocityY;
  double rotation;

  // State
  BirdState state;

  // Constants for bird physics
  static const double gravity = 980.0; // pixels/second²
  static const double jumpVelocity = -350.0; // pixels/second
  static const double terminalVelocity = 500.0; // pixels/second
  static const double rotationSpeed = 3.0; // radians/second
  static const double maxRotation = 1.5; // radians
  static const double minRotation = -0.5; // radians

  // Bird dimensions
  static const double width = 34.0;
  static const double height = 24.0;

  Bird({
    required this.x,
    required this.y,
    this.velocityY = 0.0,
    this.rotation = 0.0,
    this.state = BirdState.flying,
  });

  /// Updates the bird's position and physics
  void update(double deltaTime) {
    if (state == BirdState.dead) return;

    // Apply gravity
    applyGravity(deltaTime);

    // Update position
    y += velocityY * deltaTime;

    // Update rotation based on velocity
    _updateRotation(deltaTime);

    // Update state based on velocity
    if (velocityY > 0) {
      state = BirdState.falling;
    } else {
      state = BirdState.flying;
    }
  }

  /// Makes the bird jump
  void jump() {
    if (state == BirdState.dead) return;

    velocityY = jumpVelocity;
    state = BirdState.flying;
  }

  /// Applies gravity to the bird
  void applyGravity(double deltaTime) {
    if (state == BirdState.dead) return;

    velocityY += gravity * deltaTime;

    // Clamp to terminal velocity
    if (velocityY > terminalVelocity) {
      velocityY = terminalVelocity;
    }
  }

  /// Updates bird rotation based on velocity
  void _updateRotation(double deltaTime) {
    if (state == BirdState.dead) return;

    // Rotate based on vertical velocity
    double targetRotation = (velocityY / terminalVelocity) * maxRotation;

    // Clamp rotation
    targetRotation = targetRotation.clamp(minRotation, maxRotation);

    // Smooth rotation transition
    double rotationDiff = targetRotation - rotation;
    rotation += rotationDiff * rotationSpeed * deltaTime;
  }

  /// Returns the collision bounds of the bird
  Rect getBounds() {
    return Rect.fromLTWH(
      x - width / 2,
      y - height / 2,
      width,
      height,
    );
  }

  /// Resets the bird to initial state
  void reset(double initialX, double initialY) {
    x = initialX;
    y = initialY;
    velocityY = 0.0;
    rotation = 0.0;
    state = BirdState.flying;
  }

  /// Marks the bird as dead
  void die() {
    state = BirdState.dead;
    velocityY = 0.0;
  }

  /// Checks if the bird is out of screen bounds
  bool isOutOfBounds(double screenHeight) {
    return y - height / 2 > screenHeight || y + height / 2 < 0;
  }
}
