---
name: flutter-foldable-ui
description: >-
  Use this skill when developing, testing, or refactoring responsive and foldable layouts
  for NutriScanner, specifically for Samsung Galaxy Fold devices (cover screen, main unfolded screen,
  tabletop/flex mode), hinge crease avoidance, and adaptive screen breakpoints.
---

# Flutter Foldable & Responsive UI Skill

This skill provides step-by-step guidance, code patterns, and test recipes for developing adaptive Flutter user interfaces targeting foldable hardware (such as the Samsung Galaxy Fold) and responsive web.

---

## 1. Window Size Classes & Breakpoints

NutriScanner follows Material 3 adaptive design principles defined in `nutri_client/lib/utils/foldable_layout.dart`:

| Window Size Class | Width Range (dp) | Target Device State | UI Strategy |
| :--- | :--- | :--- | :--- |
| **Compact** | `< 600 dp` | Galaxy Fold Cover Screen, standard phones | Single-column scrollable layout, thumb-accessible primary CTA, centered compact donut chart. |
| **Medium** | `600 - 839 dp` | Galaxy Fold Main Screen (Portrait), small tablets | Dual-pane layout, food photo & donut on left pane, ingredients & insights on right pane. |
| **Expanded** | `>= 840 dp` | Galaxy Fold Main Screen (Landscape), desktop web | Spacious dual-pane dashboard, expanded card containers, side-by-side comparison. |

### Helper Methods
```dart
import 'package:nutri_client/utils/foldable_layout.dart';

// Classify width
final sizeClass = FoldableLayout.getSizeClass(MediaQuery.sizeOf(context).width);

// Check screen type
final isMainScreen = FoldableLayout.isFoldableMainScreen(context); // width >= 600
final isCover = FoldableLayout.isCoverScreen(context);              // width < 600
```

---

## 2. Hinge & Crease Avoidance

Foldable devices feature a physical hinge or display fold that distorts UI elements placed across it.

### Detecting Display Features
```dart
import 'dart:ui';
import 'package:nutri_client/utils/foldable_layout.dart';

final hinge = FoldableLayout.getHingeOrFold(context);
if (hinge != null) {
  // hinge.bounds contains Rect of the physical crease
  // hinge.state: DisplayFeatureState.postureHalfOpened, etc.
}
```

### Hinge Gutter Pattern for Dual-Pane Layouts
When laying out two panes on an unfolded foldable:
```dart
Widget buildDualPane(BuildContext context, Widget leftPane, Widget rightPane) {
  final hinge = FoldableLayout.getHingeOrFold(context);
  final gutterWidth = (hinge != null && hinge.bounds.width > 0)
      ? hinge.bounds.width
      : 24.0; // fallback standard gutter

  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(flex: 5, child: leftPane),
      SizedBox(width: gutterWidth),
      Expanded(flex: 6, child: rightPane),
    ],
  );
}
```

---

## 3. Tabletop / Flex Mode Posture

When the user partially folds the Samsung Fold into a 90-degree laptop-like angle and rests it on a table:
- **Upper Half (Vertical)**: Display food photo, holographic scanner, or results chart.
- **Lower Half (Horizontal)**: Control surface for ingredient editing, action buttons, recalculations.

```dart
final isTabletop = FoldableLayout.isTabletopMode(context);

if (isTabletop) {
  return Column(
    children: [
      // Top pane (viewing)
      Expanded(child: foodDisplayPane),
      const Divider(height: 1),
      // Bottom pane (interaction)
      Expanded(child: interactiveControlsPane),
    ],
  );
}
```

---

## 4. 120Hz LTPO Smooth Scroll & Multi-Input

Ensure all scrollable views integrate with the app-level 120Hz scrolling physics:
- Physics: `const BouncingScrollPhysics()`
- Drag Devices: Touch, Mouse, Trackpad, Stylus / S-Pen.
- Avoid heavy layout recalculations or non-const widgets in `ListView.builder` or `SingleChildScrollView`.

---

## 5. Writing Widget Tests for Foldable Viewports

Always verify new UI widgets against both Cover Screen and Main Screen dimensions:

```dart
import 'package:flutter_test/flutter_test.dart';

testWidgets('Renders properly on Galaxy Fold Cover Screen', (WidgetTester tester) async {
  // 5.5" Cover Screen: 1248 x 1972 @ 428ppi (~475 x 751 dp)
  tester.view.physicalSize = const Size(1248, 1972);
  tester.view.devicePixelRatio = 2.625;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(const MyApp());
  // Assert cover screen layout
});

testWidgets('Renders properly on Galaxy Fold Main Screen', (WidgetTester tester) async {
  // 7.6" Main Screen: 1848 x 2448 @ 403ppi (~704 x 932 dp)
  tester.view.physicalSize = const Size(1848, 2448);
  tester.view.devicePixelRatio = 2.625;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(const MyApp());
  // Assert dual-pane layout
});
```
