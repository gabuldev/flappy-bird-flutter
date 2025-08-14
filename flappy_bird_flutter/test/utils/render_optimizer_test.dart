import 'package:flappy_bird_flutter/utils/render_optimizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RenderOptimizer', () {
    setUp(() {
      RenderOptimizer.reset();
    });

    tearDown(() {
      RenderOptimizer.clearCaches();
      RenderOptimizer.reset();
    });

    group('Performance Monitoring', () {
      test('should track frame times correctly', () {
        expect(RenderOptimizer.currentFPS, closeTo(60.0, 1.0));
        expect(RenderOptimizer.isLowPerformanceMode, isFalse);

        // Record good frame times
        for (int i = 0; i < 5; i++) {
          RenderOptimizer.recordFrameTime(16.67); // 60 FPS
        }

        expect(RenderOptimizer.currentFPS, closeTo(60.0, 1.0));
        expect(RenderOptimizer.isLowPerformanceMode, isFalse);
      });

      test('should detect low performance mode', () {
        // Record bad frame times
        for (int i = 0; i < 15; i++) {
          RenderOptimizer.recordFrameTime(30.0); // 33 FPS
        }

        expect(RenderOptimizer.isLowPerformanceMode, isTrue);
        expect(RenderOptimizer.currentFPS, lessThan(40.0));
      });

      test('should recover from low performance mode', () {
        // First, trigger low performance mode
        for (int i = 0; i < 15; i++) {
          RenderOptimizer.recordFrameTime(30.0);
        }
        expect(RenderOptimizer.isLowPerformanceMode, isTrue);

        // Then record good frame times
        for (int i = 0; i < 5; i++) {
          RenderOptimizer.recordFrameTime(16.67);
        }

        expect(RenderOptimizer.isLowPerformanceMode, isFalse);
      });

      test('should provide performance statistics', () {
        RenderOptimizer.recordFrameTime(16.67);
        RenderOptimizer.recordFrameTime(20.0);

        final stats = RenderOptimizer.getPerformanceStats();

        expect(stats, containsPair('averageFrameTime', isA<double>()));
        expect(stats, containsPair('currentFPS', isA<double>()));
        expect(stats, containsPair('isLowPerformanceMode', isA<bool>()));
        expect(stats, containsPair('paintCacheSize', isA<int>()));
        expect(stats, containsPair('pathCacheSize', isA<int>()));
        expect(stats, containsPair('textPainterCacheSize', isA<int>()));
      });
    });

    group('Paint Caching', () {
      test('should cache paint objects', () {
        final paint1 = RenderOptimizer.getCachedPaint(
            'test', () => Paint()..color = Colors.red);
        final paint2 = RenderOptimizer.getCachedPaint(
            'test', () => Paint()..color = Colors.blue);

        // Should return the same cached object
        expect(identical(paint1, paint2), isTrue);
        expect(paint1.color.value,
            equals(Colors.red.value)); // Original color preserved
      });

      test('should cache different paint objects with different keys', () {
        final paint1 = RenderOptimizer.getCachedPaint(
            'test1', () => Paint()..color = Colors.red);
        final paint2 = RenderOptimizer.getCachedPaint(
            'test2', () => Paint()..color = Colors.blue);

        expect(identical(paint1, paint2), isFalse);
        expect(paint1.color.value, equals(Colors.red.value));
        expect(paint2.color.value, equals(Colors.blue.value));
      });
    });

    group('Path Caching', () {
      test('should cache path objects', () {
        final path1 = RenderOptimizer.getCachedPath('test', () {
          final path = Path();
          path.addRect(const Rect.fromLTWH(0, 0, 10, 10));
          return path;
        });

        final path2 = RenderOptimizer.getCachedPath('test', () {
          final path = Path();
          path.addRect(const Rect.fromLTWH(0, 0, 20, 20));
          return path;
        });

        // Should return the same cached object
        expect(identical(path1, path2), isTrue);
      });
    });

    group('TextPainter Caching', () {
      test('should cache text painter objects', () {
        final textPainter1 = RenderOptimizer.getCachedTextPainter('test', () {
          final painter = TextPainter(
            text: const TextSpan(text: 'Hello'),
            textDirection: TextDirection.ltr,
          );
          painter.layout();
          return painter;
        });

        final textPainter2 = RenderOptimizer.getCachedTextPainter('test', () {
          final painter = TextPainter(
            text: const TextSpan(text: 'World'),
            textDirection: TextDirection.ltr,
          );
          painter.layout();
          return painter;
        });

        // Should return the same cached object
        expect(identical(textPainter1, textPainter2), isTrue);
      });
    });

    group('Cache Management', () {
      test('should clear all caches', () {
        // Add items to caches
        RenderOptimizer.getCachedPaint('test', () => Paint());
        RenderOptimizer.getCachedPath('test', () => Path());
        RenderOptimizer.getCachedTextPainter(
            'test',
            () => TextPainter(
                  text: const TextSpan(text: 'test'),
                  textDirection: TextDirection.ltr,
                ));

        final statsBefore = RenderOptimizer.getPerformanceStats();
        expect(statsBefore['paintCacheSize'], greaterThan(0));
        expect(statsBefore['pathCacheSize'], greaterThan(0));
        expect(statsBefore['textPainterCacheSize'], greaterThan(0));

        RenderOptimizer.clearCaches();

        final statsAfter = RenderOptimizer.getPerformanceStats();
        expect(statsAfter['paintCacheSize'], equals(0));
        expect(statsAfter['pathCacheSize'], equals(0));
        expect(statsAfter['textPainterCacheSize'], equals(0));
      });
    });
  });

  group('DirtyRegionTracker', () {
    late DirtyRegionTracker tracker;

    setUp(() {
      tracker = DirtyRegionTracker();
    });

    test('should track dirty regions', () {
      expect(tracker.hasDirtyRegions, isFalse);

      const region1 = Rect.fromLTWH(0, 0, 100, 100);
      tracker.addDirtyRegion(region1);

      expect(tracker.hasDirtyRegions, isTrue);
      expect(tracker.dirtyRegions, hasLength(1));
      expect(tracker.combinedDirtyRegion, equals(region1));
    });

    test('should combine multiple dirty regions', () {
      const region1 = Rect.fromLTWH(0, 0, 100, 100);
      const region2 = Rect.fromLTWH(50, 50, 100, 100);

      tracker.addDirtyRegion(region1);
      tracker.addDirtyRegion(region2);

      expect(tracker.dirtyRegions, hasLength(2));
      expect(tracker.combinedDirtyRegion,
          equals(const Rect.fromLTWH(0, 0, 150, 150)));
    });

    test('should detect intersections with dirty regions', () {
      const dirtyRegion = Rect.fromLTWH(0, 0, 100, 100);
      tracker.addDirtyRegion(dirtyRegion);

      const intersectingRegion = Rect.fromLTWH(50, 50, 100, 100);
      const nonIntersectingRegion = Rect.fromLTWH(200, 200, 100, 100);

      expect(tracker.intersectsWithDirtyRegion(intersectingRegion), isTrue);
      expect(tracker.intersectsWithDirtyRegion(nonIntersectingRegion), isFalse);
    });

    test('should mark all dirty', () {
      const screenSize = Size(400, 600);
      tracker.markAllDirty(screenSize);

      expect(tracker.hasDirtyRegions, isTrue);
      expect(tracker.combinedDirtyRegion,
          equals(const Rect.fromLTWH(0, 0, 400, 600)));
    });

    test('should clear dirty regions', () {
      tracker.addDirtyRegion(const Rect.fromLTWH(0, 0, 100, 100));
      expect(tracker.hasDirtyRegions, isTrue);

      tracker.clear();
      expect(tracker.hasDirtyRegions, isFalse);
      expect(tracker.combinedDirtyRegion, isNull);
    });
  });

  group('DrawBatch', () {
    late DrawBatch batch;

    setUp(() {
      batch = DrawBatch();
    });

    test('should batch drawing operations', () {
      expect(batch.operationCount, equals(0));

      batch.addRect(const Rect.fromLTWH(0, 0, 100, 100), Paint());
      batch.addCircle(const Offset(50, 50), 25, Paint());

      expect(batch.operationCount, equals(2));
    });

    test('should clear batched operations', () {
      batch.addRect(const Rect.fromLTWH(0, 0, 100, 100), Paint());
      expect(batch.operationCount, equals(1));

      batch.clear();
      expect(batch.operationCount, equals(0));
    });

    // Note: Testing execute() would require a mock Canvas, which is complex
    // The execute functionality is tested through integration tests
  });
}
