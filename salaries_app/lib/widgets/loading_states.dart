import 'package:flutter/material.dart';

/// Loading state widgets for consistent UX across the app
class LoadingStates {
  
  /// Standard circular loading indicator
  static Widget circular({String? message}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  /// Skeleton loading for KPI cards
  static Widget skeletonKPICard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildShimmer(18, 18, borderRadius: 4),
                const SizedBox(width: 6),
                Expanded(child: _buildShimmer(11, double.infinity, borderRadius: 4)),
              ],
            ),
            const SizedBox(height: 12),
            _buildShimmer(20, double.infinity, borderRadius: 4),
            const SizedBox(height: 8),
            _buildShimmer(9, 120, borderRadius: 4),
          ],
        ),
      ),
    );
  }

  /// Skeleton loading for user cards
  static Widget skeletonUserCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildShimmer(48, 48, borderRadius: 12),
                const Spacer(),
                _buildShimmer(24, 24, borderRadius: 4),
              ],
            ),
            const SizedBox(height: 12),
            _buildShimmer(16, double.infinity, borderRadius: 4),
            const SizedBox(height: 4),
            _buildShimmer(12, 60, borderRadius: 12),
            const Spacer(),
            _buildShimmer(12, 100, borderRadius: 4),
          ],
        ),
      ),
    );
  }

  /// Skeleton loading for expense items
  static Widget skeletonExpenseItem() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          _buildShimmer(40, 40, borderRadius: 8),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildShimmer(14, double.infinity, borderRadius: 4),
                const SizedBox(height: 4),
                _buildShimmer(12, 80, borderRadius: 4),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _buildShimmer(16, 80, borderRadius: 16),
        ],
      ),
    );
  }

  /// Skeleton loading for settings form
  static Widget skeletonSettingsForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildShimmer(24, 200, borderRadius: 4),
        const SizedBox(height: 16),
        ...List.generate(4, (index) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildShimmer(56, double.infinity, borderRadius: 8),
        )),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(child: _buildShimmer(48, double.infinity, borderRadius: 8)),
            const SizedBox(width: 16),
            Expanded(child: _buildShimmer(48, double.infinity, borderRadius: 8)),
          ],
        ),
      ],
    );
  }

  /// Loading overlay for the entire screen
  static Widget overlay({String? message, Color? backgroundColor}) {
    return Container(
      color: backgroundColor ?? Colors.black.withValues(alpha: 0.3),
      child: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                if (message != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    message,
                    style: const TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Pulse animation loading for buttons
  static Widget pulseButton({
    required String text,
    double width = double.infinity,
    double height = 48,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 800),
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          colors: [
            Colors.grey[300]!,
            Colors.grey[100]!,
            Colors.grey[300]!,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// Data loading state with retry option
  static Widget dataLoading({
    String? message,
    VoidCallback? onRetry,
    String retryLabel = 'Retry',
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            message ?? 'Loading data...',
            style: const TextStyle(fontSize: 14),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(retryLabel),
            ),
          ],
        ],
      ),
    );
  }

  /// Helper method to build shimmer effect
  static Widget _buildShimmer(
    double height,
    double width, {
    double borderRadius = 0,
  }) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: _ShimmerWidget(),
    );
  }
}

/// Shimmer animation widget
class _ShimmerWidget extends StatefulWidget {
  @override
  _ShimmerWidgetState createState() => _ShimmerWidgetState();
}

class _ShimmerWidgetState extends State<_ShimmerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value, 0),
              colors: [
                Colors.grey[300]!,
                Colors.grey[100]!,
                Colors.grey[300]!,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}
