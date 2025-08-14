import 'package:flappy_bird_flutter/utils/render_optimizer.dart';
import 'package:flappy_bird_flutter/widgets/performance_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GamePerformanceOverlay', () {
    setUp(() {
      RenderOptimizer.reset();
    });

    tearDown(() {
      RenderOptimizer.clearCaches();
      RenderOptimizer.reset();
    });

    testWidgets('should show overlay in debug mode', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: GamePerformanceOverlay(
            showOverlay: true,
            child: Scaffold(
              body: Center(child: Text('Test')),
            ),
          ),
        ),
      );

      // Should show the collapsed performance panel
      expect(find.byIcon(Icons.speed), findsOneWidget);
      expect(find.text('Test'), findsOneWidget);
    });

    testWidgets('should hide overlay when showOverlay is false',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: GamePerformanceOverlay(
            showOverlay: false,
            child: Scaffold(
              body: Center(child: Text('Test')),
            ),
          ),
        ),
      );

      // Should not show the performance panel
      expect(find.byIcon(Icons.speed), findsNothing);
      expect(find.text('Test'), findsOneWidget);
    });

    testWidgets('should expand when tapped', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: GamePerformanceOverlay(
            showOverlay: true,
            child: Scaffold(
              body: Center(child: Text('Test')),
            ),
          ),
        ),
      );

      // Initially collapsed
      expect(find.text('Performance'), findsNothing);

      // Tap to expand
      await tester.tap(find.byIcon(Icons.speed));
      await tester.pumpAndSettle();

      // Should show expanded panel
      expect(find.text('Performance'), findsOneWidget);
      expect(find.text('FPS'), findsOneWidget);
      expect(find.text('Frame Time'), findsOneWidget);
      expect(find.text('Mode'), findsOneWidget);
    });

    testWidgets('should collapse when expanded panel is tapped',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: GamePerformanceOverlay(
            showOverlay: true,
            child: Scaffold(
              body: Center(child: Text('Test')),
            ),
          ),
        ),
      );

      // Expand first
      await tester.tap(find.byIcon(Icons.speed));
      await tester.pumpAndSettle();
      expect(find.text('Performance'), findsOneWidget);

      // Tap to collapse
      await tester.tap(find.text('Performance'));
      await tester.pumpAndSettle();

      // Should be collapsed again
      expect(find.text('Performance'), findsNothing);
      expect(find.byIcon(Icons.speed), findsOneWidget);
    });

    testWidgets('should show cache statistics when expanded', (tester) async {
      // Add some items to cache
      RenderOptimizer.getCachedPaint('test', () => Paint());
      RenderOptimizer.getCachedPath('test', () => Path());

      await tester.pumpWidget(
        const MaterialApp(
          home: GamePerformanceOverlay(
            showOverlay: true,
            child: Scaffold(
              body: Center(child: Text('Test')),
            ),
          ),
        ),
      );

      // Expand panel
      await tester.tap(find.byIcon(Icons.speed));
      await tester.pumpAndSettle();

      // Should show cache statistics
      expect(find.text('Cache Stats:'), findsOneWidget);
      expect(find.text('Paints'), findsOneWidget);
      expect(find.text('Paths'), findsOneWidget);
      expect(find.text('Texts'), findsOneWidget);
    });

    testWidgets('should show clear cache button when expanded', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: GamePerformanceOverlay(
            showOverlay: true,
            child: Scaffold(
              body: Center(child: Text('Test')),
            ),
          ),
        ),
      );

      // Expand panel
      await tester.tap(find.byIcon(Icons.speed));
      await tester.pumpAndSettle();

      // Should show clear cache button
      expect(find.text('Clear Cache'), findsOneWidget);
    });

    testWidgets('should clear caches when clear button is pressed',
        (tester) async {
      // Add items to cache
      RenderOptimizer.getCachedPaint('test', () => Paint());
      RenderOptimizer.getCachedPath('test', () => Path());

      await tester.pumpWidget(
        const MaterialApp(
          home: GamePerformanceOverlay(
            showOverlay: true,
            child: Scaffold(
              body: Center(child: Text('Test')),
            ),
          ),
        ),
      );

      // Verify caches have items
      final statsBefore = RenderOptimizer.getPerformanceStats();
      expect(statsBefore['paintCacheSize'], greaterThan(0));
      expect(statsBefore['pathCacheSize'], greaterThan(0));

      // Expand panel and tap clear cache
      await tester.tap(find.byIcon(Icons.speed));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Clear Cache'));
      await tester.pumpAndSettle();

      // Verify caches are cleared
      final statsAfter = RenderOptimizer.getPerformanceStats();
      expect(statsAfter['paintCacheSize'], equals(0));
      expect(statsAfter['pathCacheSize'], equals(0));

      // Should show snackbar
      expect(find.text('Caches cleared'), findsOneWidget);
    });

    testWidgets('should show different colors based on performance mode',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: GamePerformanceOverlay(
            showOverlay: true,
            child: Scaffold(
              body: Center(child: Text('Test')),
            ),
          ),
        ),
      );

      // Initially should show green (high performance)
      final collapsedPanel = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(GamePerformanceOverlay),
              matching: find.byType(Container),
            )
            .first,
      );

      expect(
        (collapsedPanel.decoration as BoxDecoration).border,
        isA<Border>().having(
          (border) => (border as Border).top.color,
          'border color',
          Colors.green,
        ),
      );

      // Trigger low performance mode
      for (int i = 0; i < 15; i++) {
        RenderOptimizer.recordFrameTime(30.0);
      }

      await tester.pump();

      // Should now show red border (low performance)
      final updatedPanel = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(GamePerformanceOverlay),
              matching: find.byType(Container),
            )
            .first,
      );

      expect(
        (updatedPanel.decoration as BoxDecoration).border,
        isA<Border>().having(
          (border) => (border as Border).top.color,
          'border color',
          Colors.red,
        ),
      );
    });
  });

  group('PerformanceMonitoringMixin', () {
    testWidgets('should track widget lifetime', (tester) async {
      late _TestWidgetState testWidget;

      await tester.pumpWidget(
        MaterialApp(
          home: _TestWidget(
            onCreate: (widget) => testWidget = widget,
          ),
        ),
      );

      // Wait a bit
      await tester.pump(const Duration(milliseconds: 100));

      // Widget lifetime should be tracked
      expect(testWidget.widgetLifetime.inMilliseconds, greaterThan(0));
    });
  });
}

class _TestWidget extends StatefulWidget {
  final Function(_TestWidgetState) onCreate;

  const _TestWidget({required this.onCreate});

  @override
  State<_TestWidget> createState() => _TestWidgetState();
}

class _TestWidgetState extends State<_TestWidget>
    with PerformanceMonitoringMixin {
  @override
  void initState() {
    super.initState();
    widget.onCreate(this);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Test Widget')),
    );
  }
}
