import 'package:flutter/material.dart';

/// Responsive layout breakpoints
class ResponsiveBreakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
  static const double largeDesktop = 1600;
}

/// Responsive layout widget that adapts to screen size
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? largeDesktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.largeDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= ResponsiveBreakpoints.largeDesktop) {
          return largeDesktop ?? desktop ?? tablet ?? mobile;
        } else if (constraints.maxWidth >= ResponsiveBreakpoints.desktop) {
          return desktop ?? tablet ?? mobile;
        } else if (constraints.maxWidth >= ResponsiveBreakpoints.tablet) {
          return tablet ?? mobile;
        } else {
          return mobile;
        }
      },
    );
  }
}

/// Responsive grid layout
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing = 16.0,
    this.runSpacing = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = _getCrossAxisCount(constraints.maxWidth);
        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: runSpacing,
            childAspectRatio: _getChildAspectRatio(constraints.maxWidth),
          ),
          itemCount: children.length,
          itemBuilder: (context, index) => children[index],
        );
      },
    );
  }

  int _getCrossAxisCount(double width) {
    if (width >= ResponsiveBreakpoints.largeDesktop) {
      return 4;
    } else if (width >= ResponsiveBreakpoints.desktop) {
      return 3;
    } else if (width >= ResponsiveBreakpoints.tablet) {
      return 2;
    } else {
      return 1;
    }
  }

  double _getChildAspectRatio(double width) {
    if (width >= ResponsiveBreakpoints.largeDesktop) {
      return 1.5;
    } else if (width >= ResponsiveBreakpoints.desktop) {
      return 1.3;
    } else if (width >= ResponsiveBreakpoints.tablet) {
      return 1.2;
    } else {
      return 1.0;
    }
  }
}

/// Responsive padding widget
class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final EdgeInsets? mobilePadding;
  final EdgeInsets? tabletPadding;
  final EdgeInsets? desktopPadding;

  const ResponsivePadding({
    super.key,
    required this.child,
    this.mobilePadding,
    this.tabletPadding,
    this.desktopPadding,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        EdgeInsets padding;
        if (constraints.maxWidth >= ResponsiveBreakpoints.desktop) {
          padding = desktopPadding ?? const EdgeInsets.all(24.0);
        } else if (constraints.maxWidth >= ResponsiveBreakpoints.tablet) {
          padding = tabletPadding ?? const EdgeInsets.all(16.0);
        } else {
          padding = mobilePadding ?? const EdgeInsets.all(8.0);
        }
        return Padding(padding: padding, child: child);
      },
    );
  }
}

/// Responsive text widget
class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const ResponsiveText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final fontSize = _getFontSize(constraints.maxWidth);
        final responsiveStyle = style?.copyWith(fontSize: fontSize) ??
            TextStyle(fontSize: fontSize);

        return Text(
          text,
          style: responsiveStyle,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
        );
      },
    );
  }

  double _getFontSize(double width) {
    if (width >= ResponsiveBreakpoints.largeDesktop) {
      return 18.0;
    } else if (width >= ResponsiveBreakpoints.desktop) {
      return 16.0;
    } else if (width >= ResponsiveBreakpoints.tablet) {
      return 14.0;
    } else {
      return 12.0;
    }
  }
}

/// Responsive button widget
class ResponsiveButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final ButtonStyle? style;
  final bool isOutlined;

  const ResponsiveButton(
    this.text, {
    super.key,
    this.onPressed,
    this.icon,
    this.style,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = constraints.maxWidth < ResponsiveBreakpoints.tablet;
        
        if (isSmall) {
          return _buildCompactButton(context);
        } else {
          return _buildFullButton(context);
        }
      },
    );
  }

  Widget _buildCompactButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: isOutlined
          ? OutlinedButton.icon(
              onPressed: onPressed,
              icon: icon != null ? Icon(icon, size: 16) : const SizedBox.shrink(),
              label: Text(text, style: const TextStyle(fontSize: 12)),
              style: style,
            )
          : ElevatedButton.icon(
              onPressed: onPressed,
              icon: icon != null ? Icon(icon, size: 16) : const SizedBox.shrink(),
              label: Text(text, style: const TextStyle(fontSize: 12)),
              style: style,
            ),
    );
  }

  Widget _buildFullButton(BuildContext context) {
    return isOutlined
        ? OutlinedButton.icon(
            onPressed: onPressed,
            icon: icon != null ? Icon(icon) : const SizedBox.shrink(),
            label: Text(text),
            style: style,
          )
        : ElevatedButton.icon(
            onPressed: onPressed,
            icon: icon != null ? Icon(icon) : const SizedBox.shrink(),
            label: Text(text),
            style: style,
          );
  }
}

/// Responsive card widget
class ResponsiveCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double? elevation;
  final BorderRadius? borderRadius;

  const ResponsiveCard({
    super.key,
    required this.child,
    this.padding,
    this.elevation,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final responsivePadding = _getPadding(constraints.maxWidth);
        final responsiveElevation = _getElevation(constraints.maxWidth);
        final responsiveBorderRadius = _getBorderRadius(constraints.maxWidth);

        return Card(
          elevation: elevation ?? responsiveElevation,
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? responsiveBorderRadius,
          ),
          child: Padding(
            padding: padding ?? responsivePadding,
            child: child,
          ),
        );
      },
    );
  }

  EdgeInsets _getPadding(double width) {
    if (width >= ResponsiveBreakpoints.desktop) {
      return const EdgeInsets.all(24.0);
    } else if (width >= ResponsiveBreakpoints.tablet) {
      return const EdgeInsets.all(16.0);
    } else {
      return const EdgeInsets.all(12.0);
    }
  }

  double _getElevation(double width) {
    if (width >= ResponsiveBreakpoints.desktop) {
      return 4.0;
    } else if (width >= ResponsiveBreakpoints.tablet) {
      return 2.0;
    } else {
      return 1.0;
    }
  }

  BorderRadius _getBorderRadius(double width) {
    if (width >= ResponsiveBreakpoints.desktop) {
      return BorderRadius.circular(16.0);
    } else if (width >= ResponsiveBreakpoints.tablet) {
      return BorderRadius.circular(12.0);
    } else {
      return BorderRadius.circular(8.0);
    }
  }
}

/// Responsive spacing widget
class ResponsiveSpacing extends StatelessWidget {
  final double? height;
  final double? width;

  const ResponsiveSpacing({
    super.key,
    this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final responsiveHeight = _getSpacing(constraints.maxWidth);
        return SizedBox(
          height: height ?? responsiveHeight,
          width: width ?? responsiveHeight,
        );
      },
    );
  }

  double _getSpacing(double width) {
    if (width >= ResponsiveBreakpoints.desktop) {
      return 24.0;
    } else if (width >= ResponsiveBreakpoints.tablet) {
      return 16.0;
    } else {
      return 8.0;
    }
  }
} 