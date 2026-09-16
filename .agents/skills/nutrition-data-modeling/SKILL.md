---
name: nutrition-data-modeling
description: >-
  Use this skill when extending nutrition models, adding macronutrients or micronutrients,
  adjusting portion calculation algorithms, or implementing live ingredient recalculation in NutriScanner.
---

# Nutrition Data Modeling & Recalculation Skill

This skill provides data structures, mathematical relationships, and procedures for modifying nutritional data models and portion calculations in NutriScanner.

---

## 1. Core Model Hierarchy

The data architecture in `nutri_client/lib/models/nutrition_analysis.dart` consists of three interconnected classes:

```text
NutritionAnalysis
├── foodName (String)
├── calories (double)
├── servingSize (String)
├── macros (MacroData)
│   ├── protein (double, grams)
│   ├── carbs (double, grams)
│   ├── fat (double, grams)
│   ├── fiber (double, grams)
│   └── sugar (double, grams)
├── vitaminsAndMinerals (List<String>)
├── healthSummary (String)
├── confidenceScore (double, 0-100)
└── ingredients (List<Ingredient>)
    └── [name, amount, calories, protein, carbs, fat, fiber, sugar]
```

---

## 2. Dynamic Recalculation Principle

When a user edits, adds, or deletes an ingredient in the `ResultsView` UI, the total meal macros and calories must dynamically update to match the sum of the constituent ingredients:

### Calorie & Macro Aggregation Formula
```dart
NutritionAnalysis recalculateFromIngredients(
  NutritionAnalysis currentAnalysis,
  List<Ingredient> updatedIngredients,
) {
  double totalCalories = 0.0;
  double totalProtein = 0.0;
  double totalCarbs = 0.0;
  double totalFat = 0.0;
  double totalFiber = 0.0;
  double totalSugar = 0.0;

  for (final ing in updatedIngredients) {
    totalCalories += ing.calories;
    totalProtein += ing.protein;
    totalCarbs += ing.carbs;
    totalFat += ing.fat;
    totalFiber += ing.fiber;
    totalSugar += ing.sugar;
  }

  return currentAnalysis.copyWith(
    calories: double.parse(totalCalories.toStringAsFixed(1)),
    macros: MacroData(
      protein: double.parse(totalProtein.toStringAsFixed(1)),
      carbs: double.parse(totalCarbs.toStringAsFixed(1)),
      fat: double.parse(totalFat.toStringAsFixed(1)),
      fiber: double.parse(totalFiber.toStringAsFixed(1)),
      sugar: double.parse(totalSugar.toStringAsFixed(1)),
    ),
    ingredients: updatedIngredients,
  );
}
```

### Proportional Portion Scaling Formula
When the portion size of an ingredient is changed by factor $k = \frac{\text{newWeight}}{\text{oldWeight}}$:
$$\text{calories}_{\text{new}} = \text{calories}_{\text{old}} \times k$$
$$\text{protein}_{\text{new}} = \text{protein}_{\text{old}} \times k$$
$$\text{carbs}_{\text{new}} = \text{carbs}_{\text{old}} \times k$$
$$\text{fat}_{\text{new}} = \text{fat}_{\text{old}} \times k$$

---

## 3. Extending the Nutrition Schema

When adding a new nutritional parameter (e.g., `sodium` or `glycemicIndex`):

1. **Update `MacroData` or `NutritionAnalysis`**:
   ```dart
   class MacroData {
     final double protein;
     final double carbs;
     final double fat;
     final double fiber;
     final double sugar;
     final double sodium; // [NEW] in mg

     const MacroData({
       required this.protein,
       required this.carbs,
       required this.fat,
       required this.fiber,
       required this.sugar,
       this.sodium = 0.0,
     });
   }
   ```

2. **Update `fromJson` and `toJson`**:
   Always provide fallback defaults to preserve backward compatibility:
   ```dart
   sodium: (json['sodium'] as num?)?.toDouble() ?? 0.0,
   ```

3. **Update `gemini_service.dart` schema**:
   Register `'sodium'` under `properties` with type `'NUMBER'`.

4. **Update UI Widgets**:
   - Add display badge/bar in `nutri_client/lib/widgets/results_view.dart`.
   - Update Donut / breakdown charts if applicable.

---

## 4. Verification Checklist
- [ ] Round-trip JSON serialization test in `nutrition_analysis_test.dart`.
- [ ] Test with zero / negative values handled gracefully.
- [ ] Test dynamic recalculation retains two-decimal-place precision without float rounding artifacts.
