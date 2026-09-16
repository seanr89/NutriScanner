---
name: flutter-testing-quality
description: >-
  Use this skill when running, writing, or debugging Flutter automated tests, static analysis
  (flutter analyze), responsive widget tests, or continuous integration checks in NutriScanner.
---

# Flutter Testing & Quality Assurance Skill

This skill provides step-by-step procedures for writing, executing, and maintaining automated tests and code quality in NutriScanner.

---

## 1. Quality Checklist Before Merging
Every change must satisfy:
1. **Static Analysis**: `flutter analyze` runs with 0 errors and 0 warnings.
2. **Unit Tests**: All model serialization and calculation tests pass.
3. **Widget Tests**: All responsive UI tests pass across compact and expanded viewports.
4. **Zero iOS/Desktop Drift**: No unsupported platform code or dependencies added.

---

## 2. Running Verification Commands

Execute commands in the `nutri_client/` directory:

```bash
# 1. Run static analysis
flutter analyze

# 2. Run all tests
flutter test

# 3. Run a specific test file
flutter test test/nutrition_analysis_test.dart

# 4. Run tests with coverage output
flutter test --coverage
```

---

## 3. Writing Unit Tests for Nutrition Models

Whenever editing or creating data classes:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_client/models/nutrition_analysis.dart';

void main() {
  group('NewFeature Model Serialization', () {
    test('Round-trip serialization preserves all fields', () {
      final sample = {
        'protein': 25.0,
        'carbs': 35.0,
        'fat': 10.0,
        'fiber': 4.0,
        'sugar': 2.0,
      };

      final model = MacroData.fromJson(sample);
      expect(model.protein, 25.0);

      final json = model.toJson();
      expect(json['protein'], 25.0);
    });

    test('Handles missing / null fields with safe defaults', () {
      final model = MacroData.fromJson({});
      expect(model.protein, 0.0);
      expect(model.carbs, 0.0);
    });
  });
}
```

---

## 4. Writing Responsive Widget Tests

Always reset the test viewport in `addTearDown` to prevent side effects on subsequent tests:

```dart
testWidgets('Adaptive layout test on Cover Screen', (WidgetTester tester) async {
  // Simulate narrow cover screen
  tester.view.physicalSize = const Size(1248, 1972);
  tester.view.devicePixelRatio = 2.625;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: ResultsView(
          analysis: mockAnalysis,
          imageBytes: mockBytes,
          onAnalyzeAnother: () {},
          onAnalysisChanged: (_) {},
        ),
      ),
    ),
  );

  // Assert expected widgets exist in single-column format
  expect(find.text('Macronutrients'), findsOneWidget);
});
```

---

## 5. Troubleshooting Common Test Failures

| Issue | Likely Cause | Solution |
| :--- | :--- | :--- |
| **`A RenderFlex overflowed by ... pixels`** | Fixed widget dimensions on narrow cover screen (<480dp). | Wrap column in `SingleChildScrollView`, or adjust flex values. |
| **`LateInitializationError`** | Late variable accessed before assignment in widget state. | Check lifecycle in `initState()` and provide nullable fallback. |
| **Viewport sizing leaking between tests** | Missing `addTearDown(tester.view.resetPhysicalSize)`. | Ensure every test setting `physicalSize` calls `resetPhysicalSize` in teardown. |
| **Timer / Animation pending** | Ongoing animation (e.g. laser scanner) not settled. | Use `await tester.pumpAndSettle()` or pump specific duration `await tester.pump(const Duration(seconds: 1))`. |
