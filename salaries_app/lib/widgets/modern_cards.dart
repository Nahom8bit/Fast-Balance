import 'package:flutter/material.dart';

/// Modern card design system with enhanced visual hierarchy
class ModernCard extends StatelessWidget {
  final Widget child;
  final String? title;
  final IconData? icon;
  final Color? accentColor;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final double? elevation;
  final BorderRadius? borderRadius;
  final bool showGradient;

  const ModernCard({
    super.key,
    required this.child,
    this.title,
    this.icon,
    this.accentColor,
    this.onTap,
    this.padding,
    this.elevation,
    this.borderRadius,
    this.showGradient = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Card(
      elevation: elevation ?? 2,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        side: BorderSide(
          color: accentColor?.withValues(alpha: 0.1) ?? 
                 (isDark ? Colors.grey[800]! : Colors.grey[200]!),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        child: Container(
          padding: padding ?? const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: borderRadius ?? BorderRadius.circular(16),
            gradient: showGradient && accentColor != null
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    accentColor!.withValues(alpha: 0.05),
                    Colors.transparent,
                  ],
                )
              : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null || icon != null)
                Row(
                  children: [
                    if (icon != null) ...[
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: accentColor?.withValues(alpha: 0.1) ?? 
                                 theme.colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          icon,
                          color: accentColor ?? theme.colorScheme.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    if (title != null)
                      Expanded(
                        child: Text(
                          title!,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: accentColor ?? theme.colorScheme.primary,
                          ),
                        ),
                      ),
                  ],
                ),
              if (title != null || icon != null) 
                const SizedBox(height: 16),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

/// Enhanced KPI card with modern design
class ModernKPICard extends StatelessWidget {
  final String title;
  final double value;
  final double change;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const ModernKPICard({
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
    
    return ModernCard(
      accentColor: color,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: changeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: changeColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPositive ? Icons.trending_up : Icons.trending_down,
                      color: changeColor,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${change.abs().toStringAsFixed(1)}%',
                      style: TextStyle(
                        color: changeColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value.toStringAsFixed(2),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Enhanced form card with better styling
class ModernFormCard extends StatelessWidget {
  final Widget child;
  final String? title;
  final IconData? icon;
  final Color? accentColor;
  final EdgeInsets? padding;

  const ModernFormCard({
    super.key,
    required this.child,
    this.title,
    this.icon,
    this.accentColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ModernCard(
      accentColor: accentColor,
      padding: padding ?? const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null || icon != null)
            Row(
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    color: accentColor ?? Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                ],
                if (title != null)
                  Expanded(
                    child: Text(
                      title!,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: accentColor ?? Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
              ],
            ),
          if (title != null || icon != null) const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}

/// Enhanced list card for displaying items
class ModernListCard extends StatelessWidget {
  final List<Widget> children;
  final String? title;
  final IconData? icon;
  final Color? accentColor;
  final EdgeInsets? padding;
  final bool showDivider;

  const ModernListCard({
    super.key,
    required this.children,
    this.title,
    this.icon,
    this.accentColor,
    this.padding,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return ModernCard(
      accentColor: accentColor,
      padding: padding ?? const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null || icon != null)
            Row(
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    color: accentColor ?? Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                ],
                if (title != null)
                  Expanded(
                    child: Text(
                      title!,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: accentColor ?? Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
              ],
            ),
          if (title != null || icon != null) const SizedBox(height: 16),
          ...children.asMap().entries.map((entry) {
            final index = entry.key;
            final child = entry.value;
            
            return Column(
              children: [
                child,
                if (showDivider && index < children.length - 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Divider(
                      color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
                      height: 1,
                    ),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

/// Enhanced status card for displaying status information
class ModernStatusCard extends StatelessWidget {
  final String title;
  final String status;
  final IconData icon;
  final Color statusColor;
  final String? description;
  final VoidCallback? onTap;

  const ModernStatusCard({
    super.key,
    required this.title,
    required this.status,
    required this.icon,
    required this.statusColor,
    this.description,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ModernCard(
      accentColor: statusColor,
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: statusColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
                if (description != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    description!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onTap != null)
            Icon(
              Icons.chevron_right,
              color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
            ),
        ],
      ),
    );
  }
}

/// Enhanced action card for buttons and actions
class ModernActionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isLoading;

  const ModernActionCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ModernCard(
      accentColor: color,
      onTap: isLoading ? null : onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: isLoading
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                )
              : Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
            size: 16,
          ),
        ],
      ),
    );
  }
}
