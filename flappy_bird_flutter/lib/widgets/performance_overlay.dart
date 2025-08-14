import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../utils/render_optimizer.dart';

/// Performance monitoring overlay widget for debugging and optimization
class GamePerformanceOverlay extends StatefulWidget {
  final Widget child;
  final bool showOverlay;

  const GamePerformanceOverlay({
    super.key,
    required this.child,
    this.showOverlay = kDebugMode,
  });

  @override
  State<GamePerformanceOverlay> createState() => _GamePerformanceOverlayState();
}

class _GamePerformanceOverlayState extends State<GamePerformanceOverlay>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.showOverlay) {
      return widget.child;
    }

    return Stack(
      children: [
        widget.child,
        Positioned(
          top: 40,
          right: 10,
          child: _buildPerformancePanel(),
        ),
      ],
    );
  }

  Widget _buildPerformancePanel() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          width: _isExpanded ? 250 : 60,
          height: _isExpanded ? 200 : 60,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.8),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: RenderOptimizer.isLowPerformanceMode
                  ? Colors.red
                  : Colors.green,
              width: 2,
            ),
          ),
          child: _isExpanded ? _buildExpandedPanel() : _buildCollapsedPanel(),
        );
      },
    );
  }

  Widget _buildCollapsedPanel() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isExpanded = true;
          _animationController.forward();
        });
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.speed,
              color: RenderOptimizer.isLowPerformanceMode
                  ? Colors.red
                  : Colors.green,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              RenderOptimizer.currentFPS.toStringAsFixed(0),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedPanel() {
    final stats = RenderOptimizer.getPerformanceStats();

    return GestureDetector(
      onTap: () {
        setState(() {
          _isExpanded = false;
          _animationController.reverse();
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Performance',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  RenderOptimizer.isLowPerformanceMode
                      ? Icons.warning
                      : Icons.check_circle,
                  color: RenderOptimizer.isLowPerformanceMode
                      ? Colors.red
                      : Colors.green,
                  size: 16,
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildStatRow('FPS', '${stats['currentFPS'].toStringAsFixed(1)}'),
            _buildStatRow('Frame Time',
                '${stats['averageFrameTime'].toStringAsFixed(1)}ms'),
            _buildStatRow('Mode',
                stats['isLowPerformanceMode'] ? 'Low Perf' : 'High Perf'),
            const SizedBox(height: 4),
            const Text(
              'Cache Stats:',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            _buildStatRow('Paints', '${stats['paintCacheSize']}', fontSize: 10),
            _buildStatRow('Paths', '${stats['pathCacheSize']}', fontSize: 10),
            _buildStatRow('Texts', '${stats['textPainterCacheSize']}',
                fontSize: 10),
            const SizedBox(height: 4),
            _buildClearCacheButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, {double fontSize = 12}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white70,
              fontSize: fontSize,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClearCacheButton() {
    return SizedBox(
      width: double.infinity,
      height: 20,
      child: ElevatedButton(
        onPressed: () {
          RenderOptimizer.clearCaches();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Caches cleared'),
              duration: Duration(seconds: 1),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.withOpacity(0.7),
          padding: EdgeInsets.zero,
        ),
        child: const Text(
          'Clear Cache',
          style: TextStyle(fontSize: 10, color: Colors.white),
        ),
      ),
    );
  }
}

/// Performance monitoring mixin for widgets that need performance tracking
mixin PerformanceMonitoringMixin<T extends StatefulWidget> on State<T> {
  final Stopwatch _widgetStopwatch = Stopwatch();

  @override
  void initState() {
    super.initState();
    _startPerformanceMonitoring();
  }

  @override
  void dispose() {
    _stopPerformanceMonitoring();
    super.dispose();
  }

  void _startPerformanceMonitoring() {
    _widgetStopwatch.start();
  }

  void _stopPerformanceMonitoring() {
    _widgetStopwatch.stop();
  }

  /// Records a performance measurement
  void recordPerformanceMeasurement(String operation, VoidCallback callback) {
    final stopwatch = Stopwatch()..start();
    callback();
    stopwatch.stop();

    if (kDebugMode) {
      print('Performance: $operation took ${stopwatch.elapsedMicroseconds}μs');
    }
  }

  /// Gets the total widget lifetime
  Duration get widgetLifetime => _widgetStopwatch.elapsed;
}
