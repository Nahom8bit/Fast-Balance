import 'package:flutter/material.dart';
import 'kpi_card.dart';

/// KPI Grid widget for displaying KPI cards in a responsive grid
class KPIGrid extends StatelessWidget {
  final Map<String, dynamic> kpis;
  final VoidCallback? onCardTap;

  const KPIGrid({
    super.key,
    required this.kpis,
    this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: _getCrossAxisCount(context),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 2.5,
      children: [
        KPICard(
          title: 'Cash',
          value: kpis['cash'] ?? 0.0,
          change: kpis['cashChange'] ?? 0.0,
          icon: Icons.shopping_bag,
          color: const Color(0xFF10B981),
          onTap: onCardTap,
        ),
        KPICard(
          title: 'TPA (POS)',
          value: kpis['tpa'] ?? 0.0,
          change: kpis['tpaChange'] ?? 0.0,
          icon: Icons.credit_card,
          color: const Color(0xFF3B82F6),
          onTap: onCardTap,
        ),
        KPICard(
          title: 'Expenses',
          value: kpis['expenses'] ?? 0.0,
          change: kpis['expensesChange'] ?? 0.0,
          icon: Icons.receipt_long,
          color: const Color(0xFFEF4444),
          onTap: onCardTap,
        ),
        KPICard(
          title: 'Discrepancies',
          value: kpis['discrepancies'] ?? 0.0,
          change: kpis['discrepanciesChange'] ?? 0.0,
          icon: Icons.warning,
          color: const Color(0xFFF59E0B),
          onTap: onCardTap,
        ),
      ],
    );
  }

  /// Get responsive cross axis count based on screen width
  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) {
      return 4; // Large desktop
    } else if (width > 800) {
      return 3; // Medium desktop/tablet
    } else if (width > 600) {
      return 2; // Small desktop/tablet
    } else {
      return 1; // Mobile
    }
  }
}

/// KPI Grid with loading state
class KPIGridLoading extends StatelessWidget {
  const KPIGridLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: _getCrossAxisCount(context),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 2.5,
      children: List.generate(4, (index) => const KPICardLoading()),
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) {
      return 4;
    } else if (width > 800) {
      return 3;
    } else if (width > 600) {
      return 2;
    } else {
      return 1;
    }
  }
}

/// KPI Grid with error state
class KPIGridError extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const KPIGridError({
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
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 48,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load KPI data',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 