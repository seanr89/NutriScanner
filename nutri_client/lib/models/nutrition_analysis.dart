class MacroData {
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final double sugar;

  MacroData({
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
    required this.sugar,
  });

  factory MacroData.fromJson(Map<String, dynamic> json) {
    return MacroData(
      protein: (json['protein'] as num?)?.toDouble() ?? 0.0,
      carbs: (json['carbs'] as num?)?.toDouble() ?? 0.0,
      fat: (json['fat'] as num?)?.toDouble() ?? 0.0,
      fiber: (json['fiber'] as num?)?.toDouble() ?? 0.0,
      sugar: (json['sugar'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
        'fiber': fiber,
        'sugar': sugar,
      };
}

class Ingredient {
  final String name;
  final String amount;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final double sugar;

  Ingredient({
    required this.name,
    required this.amount,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
    required this.sugar,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      name: json['name'] as String? ?? '',
      amount: json['amount'] as String? ?? '',
      calories: (json['calories'] as num?)?.toDouble() ?? 0.0,
      protein: (json['protein'] as num?)?.toDouble() ?? 0.0,
      carbs: (json['carbs'] as num?)?.toDouble() ?? 0.0,
      fat: (json['fat'] as num?)?.toDouble() ?? 0.0,
      fiber: (json['fiber'] as num?)?.toDouble() ?? 0.0,
      sugar: (json['sugar'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'amount': amount,
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
        'fiber': fiber,
        'sugar': sugar,
      };
}

class NutritionAnalysis {
  final String foodName;
  final double calories;
  final String servingSize;
  final MacroData macros;
  final List<String> vitaminsAndMinerals;
  final String healthSummary;
  final double confidenceScore;
  final List<Ingredient> ingredients;

  NutritionAnalysis({
    required this.foodName,
    required this.calories,
    required this.servingSize,
    required this.macros,
    required this.vitaminsAndMinerals,
    required this.healthSummary,
    required this.confidenceScore,
    required this.ingredients,
  });

  factory NutritionAnalysis.fromJson(Map<String, dynamic> json) {
    final foodName = json['foodName'] as String? ?? 'Unknown Dish';
    final servingSize = json['servingSize'] as String? ?? '';
    final calories = (json['calories'] as num?)?.toDouble() ?? 0.0;
    final macros = MacroData.fromJson(json['macros'] as Map<String, dynamic>? ?? {});
    final vitaminsAndMinerals = List<String>.from(json['vitaminsAndMinerals'] as List? ?? []);
    final healthSummary = json['healthSummary'] as String? ?? '';
    final confidenceScore = (json['confidenceScore'] as num?)?.toDouble() ?? 0.0;

    final parsedIngredients = (json['ingredients'] as List?)
            ?.map((e) => Ingredient.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    // Fallback if empty to enable editing/adding
    if (parsedIngredients.isEmpty) {
      parsedIngredients.add(Ingredient(
        name: foodName,
        amount: servingSize.isNotEmpty ? servingSize : '1 serving',
        calories: calories,
        protein: macros.protein,
        carbs: macros.carbs,
        fat: macros.fat,
        fiber: macros.fiber,
        sugar: macros.sugar,
      ));
    }

    return NutritionAnalysis(
      foodName: foodName,
      calories: calories,
      servingSize: servingSize,
      macros: macros,
      vitaminsAndMinerals: vitaminsAndMinerals,
      healthSummary: healthSummary,
      confidenceScore: confidenceScore,
      ingredients: parsedIngredients,
    );
  }

  Map<String, dynamic> toJson() => {
        'foodName': foodName,
        'calories': calories,
        'servingSize': servingSize,
        'macros': macros.toJson(),
        'vitaminsAndMinerals': vitaminsAndMinerals,
        'healthSummary': healthSummary,
        'confidenceScore': confidenceScore,
        'ingredients': ingredients.map((e) => e.toJson()).toList(),
      };

  NutritionAnalysis copyWith({
    String? foodName,
    double? calories,
    String? servingSize,
    MacroData? macros,
    List<String>? vitaminsAndMinerals,
    String? healthSummary,
    double? confidenceScore,
    List<Ingredient>? ingredients,
  }) {
    return NutritionAnalysis(
      foodName: foodName ?? this.foodName,
      calories: calories ?? this.calories,
      servingSize: servingSize ?? this.servingSize,
      macros: macros ?? this.macros,
      vitaminsAndMinerals: vitaminsAndMinerals ?? this.vitaminsAndMinerals,
      healthSummary: healthSummary ?? this.healthSummary,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      ingredients: ingredients ?? this.ingredients,
    );
  }
}
