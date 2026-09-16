import 'dart:ui';
import 'package:flutter/material.dart';

/// Window size classes inspired by Material 3 adaptive design.
enum FoldableWindowSizeClass {
  /// Compact: Cover screen or standard phones (< 600 dp).
  compact,

  /// Medium: Folded open main screen in portrait, small tablets (600 - 839 dp).
  medium,

  /// Expanded: Folded open main screen in landscape, desktop, large tablets (>= 840 dp).
  expanded,
}

class FoldableLayout {
  /// Threshold between phone/cover screen and unfolded foldable / tablet.
  static const double compactBreakpoint = 600.0;

  /// Threshold between medium (portrait fold) and expanded (landscape fold / desktop).
  static const double expandedBreakpoint = 840.0;

  /// Get the current window size class based on available width.
  static FoldableWindowSizeClass getSizeClass(double width) {
    if (width < compactBreakpoint) {
      return FoldableWindowSizeClass.compact;
    } else if (width < expandedBreakpoint) {
      return FoldableWindowSizeClass.medium;
    } else {
      return FoldableWindowSizeClass.expanded;
    }
  }

  /// Returns true if the current screen width is suitable for dual-pane layout (>= 600 dp).
  /// This covers the 7.6" Samsung Fold main screen in both portrait (~704-740 dp)
  /// and landscape (~932-980 dp).
  static bool isFoldableMainScreen(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= compactBreakpoint;
  }

  /// Returns true if the screen is a narrow cover screen (< 600 dp).
  static bool isCoverScreen(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width < compactBreakpoint;
  }

  /// Detects if the device has an active hinge or fold feature (e.g. Samsung Fold crease).
  static DisplayFeature? getHingeOrFold(BuildContext context) {
    final features = MediaQuery.displayFeaturesOf(context);
    for (final feature in features) {
      if (feature.type == DisplayFeatureType.hinge ||
          feature.type == DisplayFeatureType.fold) {
        return feature;
      }
    }
    return null;
  }

  /// Returns true if the device is in tabletop/flex mode (partially folded with horizontal crease).
  static bool isTabletopPosture(BuildContext context) {
    final hinge = getHingeOrFold(context);
    if (hinge == null) return false;

    // Check if the hinge is horizontal (running across the screen horizontally)
    final isHorizontalHinge = hinge.bounds.width > hinge.bounds.height;

    // Posture is half-opened (Flex Mode) or horizontal fold
    return hinge.state == DisplayFeatureState.postureHalfOpened ||
        (isHorizontalHinge && hinge.bounds.height > 0);
  }

  /// Gets the hinge crease width/height to add safe gutter spacing so UI elements
  /// don't sit directly on the physical screen fold.
  static double getHingeGutter(BuildContext context) {
    final hinge = getHingeOrFold(context);
    if (hinge == null) return 24.0; // Default comfortable gutter between panes

    final isVerticalHinge = hinge.bounds.height >= hinge.bounds.width;
    if (isVerticalHinge) {
      return hinge.bounds.width.clamp(16.0, 48.0);
    } else {
      return hinge.bounds.height.clamp(16.0, 48.0);
    }
  }
}

/// Convenience alias for FoldableLayout.
typedef FoldableUtils = FoldableLayout;

