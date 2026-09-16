import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_client/models/nutrition_analysis.dart';
import 'package:nutri_client/utils/foldable_layout.dart';
import 'package:nutri_client/widgets/donut_chart.dart';
import 'package:nutri_client/widgets/header.dart';
import 'package:nutri_client/widgets/results_view.dart';

final kTestImageBytes = Uint8List.fromList(<int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
  0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
  0x42, 0x60, 0x82,
]);

void main() {
  group('NutritionAnalysis Model Tests', () {
    test('MacroData fromJson and toJson serialization', () {
      final jsonMap = {
        'protein': 30.5,
        'carbs': 40.0,
        'fat': 12.2,
        'fiber': 6.0,
        'sugar': 3.1,
      };

      final macro = MacroData.fromJson(jsonMap);

      expect(macro.protein, 30.5);
      expect(macro.carbs, 40.0);
      expect(macro.fat, 12.2);
      expect(macro.fiber, 6.0);
      expect(macro.sugar, 3.1);

      final backToJson = macro.toJson();
      expect(backToJson['protein'], 30.5);
      expect(backToJson['carbs'], 40.0);
      expect(backToJson['fat'], 12.2);
      expect(backToJson['fiber'], 6.0);
      expect(backToJson['sugar'], 3.1);
    });

    test('NutritionAnalysis fromJson and toJson serialization', () {
      final jsonMap = {
        'foodName': 'Avocado Salad',
        'calories': 250.0,
        'servingSize': '1 bowl',
        'macros': {
          'protein': 10.0,
          'carbs': 15.0,
          'fat': 20.0,
          'fiber': 5.0,
          'sugar': 2.0,
        },
        'vitaminsAndMinerals': ['Vitamin E', 'Potassium'],
        'healthSummary': 'Very healthy dish.',
        'confidenceScore': 90.0,
      };

      final analysis = NutritionAnalysis.fromJson(jsonMap);

      expect(analysis.foodName, 'Avocado Salad');
      expect(analysis.calories, 250.0);
      expect(analysis.servingSize, '1 bowl');
      expect(analysis.macros.protein, 10.0);
      expect(analysis.vitaminsAndMinerals.length, 2);
      expect(analysis.vitaminsAndMinerals[0], 'Vitamin E');
      expect(analysis.healthSummary, 'Very healthy dish.');
      expect(analysis.confidenceScore, 90.0);

      final backToJson = analysis.toJson();
      expect(backToJson['foodName'], 'Avocado Salad');
      expect(backToJson['calories'], 250.0);
      expect(backToJson['macros']['protein'], 10.0);
      expect(backToJson['vitaminsAndMinerals'][1], 'Potassium');
    });

    test('NutritionAnalysis fromJson with null values defaults safely', () {
      final jsonMap = <String, dynamic>{};
      final analysis = NutritionAnalysis.fromJson(jsonMap);

      expect(analysis.foodName, 'Unknown Dish');
      expect(analysis.calories, 0.0);
      expect(analysis.servingSize, '');
      expect(analysis.macros.protein, 0.0);
      expect(analysis.vitaminsAndMinerals, isEmpty);
      expect(analysis.healthSummary, '');
      expect(analysis.confidenceScore, 0.0);
    });
  });

  group('FoldableLayout Tests', () {
    test('Classifies window size classes correctly', () {
      // 5.5" Cover Screen (1248 x 1972 @ 428ppi -> ~475 dp)
      expect(FoldableLayout.getSizeClass(475), FoldableWindowSizeClass.compact);
      expect(FoldableLayout.getSizeClass(360), FoldableWindowSizeClass.compact);

      // 7.6" Main Screen Portrait (1848 x 2448 @ 403ppi -> ~704 - 739 dp)
      expect(FoldableLayout.getSizeClass(704), FoldableWindowSizeClass.medium);
      expect(FoldableLayout.getSizeClass(739), FoldableWindowSizeClass.medium);

      // 7.6" Main Screen Landscape (~932 dp)
      expect(FoldableLayout.getSizeClass(932), FoldableWindowSizeClass.expanded);
      expect(FoldableLayout.getSizeClass(1080), FoldableWindowSizeClass.expanded);
    });
  });

  group('Widget UI Smoke Tests', () {
    testWidgets('AppHeader renders title and branding',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppHeader(),
          ),
        ),
      );

      expect(find.text('NutriScan AI'), findsOneWidget);
    });

    testWidgets('DonutChart renders CustomPaint child with custom size',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DonutChart(
              protein: 30,
              carbs: 40,
              fat: 20,
              size: 140,
            ),
          ),
        ),
      );

      expect(find.byType(CustomPaint), findsAtLeastNWidgets(1));
    });

    testWidgets('ResultsView renders on Cover Screen viewport',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1248, 1972);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final dummyImage = kTestImageBytes;
      final dummyAnalysis = NutritionAnalysis(
        foodName: 'Grilled Salmon',
        calories: 450,
        servingSize: '200g fillet',
        macros: const MacroData(protein: 38, carbs: 2, fat: 28, fiber: 0, sugar: 0),
        vitaminsAndMinerals: ['Omega-3', 'Vitamin D'],
        healthSummary: 'Rich in lean protein and essential fatty acids.',
        confidenceScore: 94,
        ingredients: [
          Ingredient(
            name: 'Salmon Fillet',
            amount: '200g',
            calories: 400,
            protein: 36,
            carbs: 0,
            fat: 26,
            fiber: 0,
            sugar: 0,
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResultsView(
              analysis: dummyAnalysis,
              imageBytes: dummyImage,
              onAnalyzeAnother: () {},
              onAnalysisChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Grilled Salmon'), findsOneWidget);
      expect(find.text('Macronutrients'), findsOneWidget);
      expect(find.text('Ingredients & Portions'), findsOneWidget);
    });

    testWidgets('ResultsView renders on Main Screen (unfolded) viewport',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1848, 2448);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final dummyImage = kTestImageBytes;
      final dummyAnalysis = NutritionAnalysis(
        foodName: 'Avocado Toast',
        calories: 320,
        servingSize: '1 slice',
        macros: const MacroData(protein: 8, carbs: 30, fat: 18, fiber: 7, sugar: 2),
        vitaminsAndMinerals: ['Folate', 'Potassium'],
        healthSummary: 'High fiber, healthy monounsaturated fats.',
        confidenceScore: 92,
        ingredients: [
          Ingredient(
            name: 'Sourdough Bread',
            amount: '1 slice',
            calories: 160,
            protein: 5,
            carbs: 26,
            fat: 1,
            fiber: 2,
            sugar: 1,
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResultsView(
              analysis: dummyAnalysis,
              imageBytes: dummyImage,
              onAnalyzeAnother: () {},
              onAnalysisChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Avocado Toast'), findsOneWidget);
      expect(find.text('Macronutrients'), findsOneWidget);
      expect(find.text('Ingredients & Portions'), findsOneWidget);
      expect(find.text('Health Insight'), findsOneWidget);
    });
  });
}
