import 'dart:collection';
import 'dart:math';

import '../models/pipe.dart';

/// Object pool for managing Pipe instances to reduce garbage collection
/// and improve performance by reusing pipe objects instead of creating new ones
class PipePool {
  // Pool of available pipe objects
  final Queue<Pipe> _availablePipes = Queue<Pipe>();

  // List of currently active pipes in the game
  final List<Pipe> _activePipes = <Pipe>[];

  // Configuration
  static const int _initialPoolSize = 10;
  static const int _maxPoolSize = 20;

  // Screen dimensions for pipe creation
  double _screenWidth = 0;
  double _screenHeight = 0;

  // Random number generator for gap positioning
  final Random _random = Random();

  /// Initializes the pipe pool with a set of pre-created pipes
  PipePool() {
    _initializePool();
  }

  /// Sets the screen dimensions for pipe creation
  void setScreenSize(double width, double height) {
    _screenWidth = width;
    _screenHeight = height;
  }

  /// Creates initial pool of pipe objects
  void _initializePool() {
    for (int i = 0; i < _initialPoolSize; i++) {
      final pipe = Pipe(
        x: 0,
        topHeight: 0,
        bottomHeight: 0,
      );
      _availablePipes.add(pipe);
    }
  }

  /// Gets a pipe from the pool or creates a new one if pool is empty
  Pipe _getPipeFromPool() {
    if (_availablePipes.isNotEmpty) {
      return _availablePipes.removeFirst();
    }

    // Create new pipe if pool is empty
    return Pipe(
      x: 0,
      topHeight: 0,
      bottomHeight: 0,
    );
  }

  /// Returns a pipe to the pool for reuse
  void _returnPipeToPool(Pipe pipe) {
    // Only return to pool if we haven't exceeded max size
    if (_availablePipes.length < _maxPoolSize) {
      _availablePipes.add(pipe);
    }
    // If pool is full, let the pipe be garbage collected
  }

  /// Spawns a new pipe at the specified position with random gap
  Pipe spawnPipe({
    required double x,
    required double minGapY,
    required double maxGapY,
    double gapSize = Pipe.defaultGapSize,
  }) {
    if (_screenHeight == 0) {
      throw StateError('Screen size not set. Call setScreenSize() first.');
    }

    // Get pipe from pool
    final pipe = _getPipeFromPool();

    // Calculate random gap position
    final gapY = minGapY + _random.nextDouble() * (maxGapY - minGapY);

    // Reset pipe with new configuration
    pipe.reset(
      newX: x,
      screenHeight: _screenHeight,
      gapY: gapY,
      newGapSize: gapSize,
    );

    // Add to active pipes
    _activePipes.add(pipe);

    return pipe;
  }

  /// Updates all active pipes
  void updatePipes(double deltaTime) {
    for (final pipe in _activePipes) {
      pipe.update(deltaTime);
    }
  }

  /// Removes pipes that are off-screen and returns them to the pool
  void cleanupOffScreenPipes() {
    final pipesToRemove = <Pipe>[];

    for (final pipe in _activePipes) {
      if (pipe.isOffScreen()) {
        pipesToRemove.add(pipe);
      }
    }

    // Remove from active list and return to pool
    for (final pipe in pipesToRemove) {
      _activePipes.remove(pipe);
      _returnPipeToPool(pipe);
    }
  }

  /// Gets all currently active pipes
  List<Pipe> get activePipes => List.unmodifiable(_activePipes);

  /// Clears all active pipes and returns them to the pool
  void clearAllPipes() {
    for (final pipe in _activePipes) {
      _returnPipeToPool(pipe);
    }
    _activePipes.clear();
  }

  /// Gets the number of pipes currently in use
  int get activePipeCount => _activePipes.length;

  /// Gets the number of pipes available in the pool
  int get availablePipeCount => _availablePipes.length;

  /// Gets total number of pipes (active + available)
  int get totalPipeCount => activePipeCount + availablePipeCount;

  /// Checks if any active pipe has been passed by the given x position for scoring
  List<Pipe> checkForScoringPipes(double birdX) {
    final scoringPipes = <Pipe>[];

    for (final pipe in _activePipes) {
      if (pipe.hasPassedPoint(birdX)) {
        pipe.markAsScored();
        scoringPipes.add(pipe);
      }
    }

    return scoringPipes;
  }

  /// Gets all visible pipes on screen
  List<Pipe> getVisiblePipes() {
    if (_screenWidth == 0) return _activePipes;

    return _activePipes.where((pipe) => pipe.isVisible(_screenWidth)).toList();
  }

  /// Disposes the pool and clears all pipes
  void dispose() {
    _activePipes.clear();
    _availablePipes.clear();
  }

  /// Gets pool statistics for debugging/monitoring
  Map<String, int> getPoolStats() {
    return {
      'active': activePipeCount,
      'available': availablePipeCount,
      'total': totalPipeCount,
    };
  }
}
