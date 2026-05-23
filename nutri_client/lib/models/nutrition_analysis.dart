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

class NutritionAnalysis {
  final String foodName;
  final double calories;
  final String servingSize;
  final MacroData macros;
  final List<String> vitaminsAndMinerals;
  final String healthSummary;
  final double confidenceScore;

  NutritionAnalysis({
    required this.foodName,
    required this.calories,
    required this.servingSize,
    required this.macros,
    required this.vitaminsAndMinerals,
    required this.healthSummary,
    required this.confidenceScore,
  });

  factory NutritionAnalysis.fromJson(Map<String, dynamic> json) {
    return NutritionAnalysis(
      foodName: json['foodName'] as String? ?? 'Unknown Dish',
      calories: (json['calories'] as num?)?.toDouble() ?? 0.0,
      servingSize: json['servingSize'] as String? ?? '',
      macros: MacroData.fromJson(json['macros'] as Map<String, dynamic>? ?? {}),
      vitaminsAndMinerals: List<String>.from(json['vitaminsAndMinerals'] as List? ?? []),
      healthSummary: json['healthSummary'] as String? ?? '',
      confidenceScore: (json['confidenceScore'] as num?)?.toDouble() ?? 0.0,
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
      };
}
