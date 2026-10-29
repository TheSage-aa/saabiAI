import 'package:flutter/material.dart';

/// Breakpoints for responsive layout — matches Figma / common device sizes.
abstract class SaabiBreakpoints {
  /// Mobile portrait  (< 600 px wide)
  static const mobile = 600.0;

  /// Tablet landscape / small desktop  (600 – 1024 px)
  static const tablet = 1024.0;

  /// Full desktop  (> 1024 px)
}

enum LayoutSize { mobile, tablet, desktop }

extension BuildContextLayout on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;

  LayoutSize get layoutSize {
    final w = screenWidth;
    if (w < SaabiBreakpoints.mobile) return LayoutSize.mobile;
    if (w < SaabiBreakpoints.tablet) return LayoutSize.tablet;
    return LayoutSize.desktop;
  }

  bool get isMobile => layoutSize == LayoutSize.mobile;
  bool get isTablet => layoutSize == LayoutSize.tablet;
  bool get isDesktop => layoutSize == LayoutSize.desktop;

  /// Whether a side rail / sidebar should be shown instead of bottom nav.
  bool get useSidebar => layoutSize != LayoutSize.mobile;

  /// Horizontal content padding — wider on bigger screens.
  double get contentPadding {
    switch (layoutSize) {
      case LayoutSize.mobile:
        return 16;
      case LayoutSize.tablet:
        return 32;
      case LayoutSize.desktop:
        return 48;
    }
  }

  /// Max width for content area on desktop (so it doesn't stretch too wide).
  double get contentMaxWidth {
    switch (layoutSize) {
      case LayoutSize.mobile:
        return double.infinity;
      case LayoutSize.tablet:
        return 720;
      case LayoutSize.desktop:
        return 900;
    }
  }
}

/// Wraps content so it never gets wider than [contentMaxWidth] on large screens.
class ResponsiveContent extends StatelessWidget {
  const ResponsiveContent({super.key, required this.child, this.maxWidth});
  final Widget child;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    final max = maxWidth ?? context.contentMaxWidth;
    if (max == double.infinity) return child;
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: max),
        child: child,
      ),
    );
  }
}

/// Renders different widgets depending on screen size.
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  @override
  Widget build(BuildContext context) {
    switch (context.layoutSize) {
      case LayoutSize.mobile:
        return mobile;
      case LayoutSize.tablet:
        return tablet ?? mobile;
      case LayoutSize.desktop:
        return desktop ?? tablet ?? mobile;
    }
  }
}
