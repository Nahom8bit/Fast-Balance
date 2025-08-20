import 'package:flutter/material.dart';
import '../currency_formatter.dart';
import 'loading_states.dart';

/// Optimized KPI Card widget with const constructor for better performance
class KPICard extends StatelessWidget {
  final String title;
  final double value;
  final double change;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const KPICard({
    super.key,
    required this.title,
    required this.value,
    required this.change,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = change >= 0;
    final changeColor = isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.05),
                color.withValues(alpha: 0.02),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(context),
                const SizedBox(height: 12),
                _buildValue(context),
                const SizedBox(height: 8),
                _buildChangeIndicator(context, changeColor, isPositive),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildValue(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        CurrencyFormatter.format(value),
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).textTheme.titleLarge?.color,
          letterSpacing: -0.5,
        ),
      ),
    );
  }

  Widget _buildChangeIndicator(BuildContext context, Color changeColor, bool isPositive) {
    return Row(
      children: [
        Icon(
          isPositive ? Icons.trending_up : Icons.trending_down,
          color: changeColor,
          size: 12,
        ),
        const SizedBox(width: 3),
        Expanded(
          child: Text(
            '${change.abs().toStringAsFixed(1)}% from last period',
            style: TextStyle(
              color: changeColor,
              fontWeight: FontWeight.w600,
              fontSize: 9,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// Optimized KPI Card with loading state
class KPICardLoading extends StatelessWidget {
  const KPICardLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return LoadingStates.skeletonKPICard();
  }
}

/// KPI Card with error state
class KPICardError extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const KPICardError({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Error',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: onRetry,
                child: const Text('Retry', style: TextStyle(fontSize: 10)),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 