import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Performance monitoring and optimization utilities for rendering
class RenderOptimizer {
  // Performance monitoring
  static final List<double> _frameTimes = [];
  static const int _maxFrameTimesSamples = 60; // Track last 60 frames
  static const double _targetFrameTime = 16.67; // 60 FPS target (1000ms/60)
  static const double _lowPerformanceThreshold = 25.0; // 40 FPS threshold

  // Performance state
  static bool _isLowPerformanceMode = false;
  static int _consecutiveLowFrames = 0;
  static const int _lowFrameThreshold =
      10; // Frames before switching to low perf mode

  // Cached objects for reuse
  static final Map<String, Paint> _paintCache = {};
  static final Map<String, Path> _pathCache = {};
  static final Map<String, TextPainter> _textPainterCache = {};

  /// Records frame time for performance monitoring
  static void recordFrameTime(double frameTimeMs) {
    _frameTimes.add(frameTimeMs);

    // Keep only recent samples
    if (_frameTimes.length > _maxFrameTimesSamples) {
      _frameTimes.removeAt(0);
    }

    // Check if frame time is above threshold
    if (frameTimeMs > _lowPerformanceThreshold) {
      _consecutiveLowFrames++;
    } else {
      _consecutiveLowFrames = 0;
    }

    // Switch to low performance mode if needed
    if (_consecutiveLowFrames >= _lowFrameThreshold && !_isLowPerformanceMode) {
      _isLowPerformanceMode = true;
      if (kDebugMode) {
        print('RenderOptimizer: Switching to low performance mode');
      }
    }

    // Switch back to high performance mode if performance improves
    if (_consecutiveLowFrames == 0 && _isLowPerformanceMode) {
      _isLowPerformanceMode = false;
      if (kDebugMode) {
        print('RenderOptimizer: Switching to high performance mode');
      }
    }
  }

  /// Gets the current average frame time
  static double get averageFrameTime {
    if (_frameTimes.isEmpty) return _targetFrameTime;
    return _frameTimes.reduce((a, b) => a + b) / _frameTimes.length;
  }

  /// Gets the current FPS
  static double get currentFPS {
    return 1000.0 / averageFrameTime;
  }

  /// Returns true if the device is in low performance mode
  static bool get isLowPerformanceMode => _isLowPerformanceMode;

  /// Gets or creates a cached paint object
  static Paint getCachedPaint(String key, Paint Function() factory) {
    return _paintCache.putIfAbsent(key, factory);
  }

  /// Gets or creates a cached path object
  static Path getCachedPath(String key, Path Function() factory) {
    return _pathCache.putIfAbsent(key, factory);
  }

  /// Gets or creates a cached text painter
  static TextPainter getCachedTextPainter(
      String key, TextPainter Function() factory) {
    return _textPainterCache.putIfAbsent(key, factory);
  }

  /// Clears all caches (call when memory is low)
  static void clearCaches() {
    _paintCache.clear();
    _pathCache.clear();
    _textPainterCache.clear();
    if (kDebugMode) {
      print('RenderOptimizer: Cleared all caches');
    }
  }

  /// Gets performance statistics
  static Map<String, dynamic> getPerformanceStats() {
    return {
      'averageFrameTime': averageFrameTime,
      'currentFPS': currentFPS,
      'isLowPerformanceMode': _isLowPerformanceMode,
      'consecutiveLowFrames': _consecutiveLowFrames,
      'paintCacheSize': _paintCache.length,
      'pathCacheSize': _pathCache.length,
      'textPainterCacheSize': _textPainterCache.length,
    };
  }

  /// Resets performance monitoring
  static void reset() {
    _frameTimes.clear();
    _isLowPerformanceMode = false;
    _consecutiveLowFrames = 0;
  }
}

/// Dirty region tracking for optimized repainting
class DirtyRegionTracker {
  final List<Rect> _dirtyRegions = [];
  Rect? _combinedDirtyRegion;

  /// Adds a dirty region that needs repainting
  void addDirtyRegion(Rect region) {
    _dirtyRegions.add(region);
    _combinedDirtyRegion =
        _combinedDirtyRegion?.expandToInclude(region) ?? region;
  }

  /// Marks the entire screen as dirty
  void markAllDirty(Size screenSize) {
    _dirtyRegions.clear();
    _combinedDirtyRegion =
        Rect.fromLTWH(0, 0, screenSize.width, screenSize.height);
    _dirtyRegions.add(_combinedDirtyRegion!);
  }

  /// Gets the combined dirty region
  Rect? get combinedDirtyRegion => _combinedDirtyRegion;

  /// Gets all dirty regions
  List<Rect> get dirtyRegions => List.unmodifiable(_dirtyRegions);

  /// Checks if a region intersects with any dirty region
  bool intersectsWithDirtyRegion(Rect region) {
    if (_combinedDirtyRegion == null) return false;
    return _combinedDirtyRegion!.overlaps(region);
  }

  /// Clears all dirty regions
  void clear() {
    _dirtyRegions.clear();
    _combinedDirtyRegion = null;
  }

  /// Returns true if there are dirty regions
  bool get hasDirtyRegions => _dirtyRegions.isNotEmpty;
}

/// Batch drawing operations for better performance
class DrawBatch {
  final List<_DrawOperation> _operations = [];

  /// Adds a rectangle drawing operation to the batch
  void addRect(Rect rect, Paint paint) {
    _operations.add(_RectDrawOperation(rect, paint));
  }

  /// Adds a circle drawing operation to the batch
  void addCircle(Offset center, double radius, Paint paint) {
    _operations.add(_CircleDrawOperation(center, radius, paint));
  }

  /// Adds a path drawing operation to the batch
  void addPath(Path path, Paint paint) {
    _operations.add(_PathDrawOperation(path, paint));
  }

  /// Executes all batched operations on the canvas
  void execute(Canvas canvas) {
    // Group operations by paint type for better performance
    final Map<Paint, List<_DrawOperation>> groupedOps = {};

    for (final op in _operations) {
      groupedOps.putIfAbsent(op.paint, () => []).add(op);
    }

    // Execute grouped operations
    for (final entry in groupedOps.entries) {
      for (final op in entry.value) {
        op.execute(canvas);
      }
    }
  }

  /// Clears all batched operations
  void clear() {
    _operations.clear();
  }

  /// Returns the number of batched operations
  int get operationCount => _operations.length;
}

/// Base class for draw operations
abstract class _DrawOperation {
  final Paint paint;

  _DrawOperation(this.paint);

  void execute(Canvas canvas);
}

/// Rectangle draw operation
class _RectDrawOperation extends _DrawOperation {
  final Rect rect;

  _RectDrawOperation(this.rect, Paint paint) : super(paint);

  @override
  void execute(Canvas canvas) {
    canvas.drawRect(rect, paint);
  }
}

/// Circle draw operation
class _CircleDrawOperation extends _DrawOperation {
  final Offset center;
  final double radius;

  _CircleDrawOperation(this.center, this.radius, Paint paint) : super(paint);

  @override
  void execute(Canvas canvas) {
    canvas.drawCircle(center, radius, paint);
  }
}

/// Path draw operation
class _PathDrawOperation extends _DrawOperation {
  final Path path;

  _PathDrawOperation(this.path, Paint paint) : super(paint);

  @override
  void execute(Canvas canvas) {
    canvas.drawPath(path, paint);
  }
}
