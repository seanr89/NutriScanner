---
name: gemini-vision-pipeline
description: >-
  Use this skill when modifying Google Gemini API prompts, structured JSON output schemas,
  image byte preprocessing, multimodal payload construction, or testing food recognition in NutriScanner.
---

# Gemini Vision Pipeline Skill

This skill provides procedures and best practices for extending and maintaining the multimodal food analysis pipeline in `nutri_client/lib/services/gemini_service.dart`.

---

## 1. Overview of the Gemini Multimodal Pipeline

NutriScanner sends food photographs directly to Google's Gemini Vision API (`gemini-3.7-flash` or newer) with a structured JSON schema, ensuring deterministic, strongly-typed responses that map cleanly to `NutritionAnalysis`.

```text
[Camera/Gallery Image] 
        │
        ▼ (Uint8List bytes + MIME type)
[base64Encode] ──► [Gemini Multimodal generateContent]
                          │ (responseMimeType: application/json)
                          ▼
                   [Structured JSON]
                          │
                          ▼
                 [NutritionAnalysis.fromJson]
```

---

## 2. Modifying or Extending the Output Schema

When adding new nutritional fields (e.g. `glycemicIndex`, `allergenWarnings`, `dietaryTags`):

1. **Update `responseSchema` in `gemini_service.dart`**:
   Add the property under `properties` with a clear description so Gemini understands the expected value:
   ```dart
   'allergenWarnings': {
     'type': 'ARRAY',
     'description': 'Potential allergens present in the dish (e.g., Dairy, Nuts, Gluten)',
     'items': {'type': 'STRING'},
   },
   ```

2. **Update the Vision Prompt**:
   Instruct the model explicitly on how to assess the new metric:
   ```text
   "Identify this food dish and provide a detailed nutritional analysis... Also flag any prominent common allergens."
   ```

3. **Update Data Models**:
   Update `nutri_client/lib/models/nutrition_analysis.dart`:
   - Add field: `final List<String> allergenWarnings;`
   - Update `fromJson`: `List<String>.from(json['allergenWarnings'] as List? ?? [])`
   - Update `toJson`: `'allergenWarnings': allergenWarnings`
   - Update `copyWith` method.

4. **Update Unit Tests**:
   Add serialization test cases in `nutri_client/test/nutrition_analysis_test.dart`.

---

## 3. Handling Image Bytes & MIME Types

Ensure supported MIME types are properly mapped from the picker:
```dart
// Accepted formats: image/jpeg, image/png, image/webp, image/heic
final mimeType = determineMimeType(fileName) ?? 'image/jpeg';
final base64Image = base64Encode(imageBytes);

final inlineDataPart = {
  'inlineData': {
    'mimeType': mimeType,
    'data': base64Image,
  }
};
```

---

## 4. Error Handling & Edge Cases

Always handle the following scenarios gracefully in `GeminiService`:

| Scenario | Symptom | Mitigation / Recovery |
| :--- | :--- | :--- |
| **Missing API Key** | Empty or invalid key in `.env` | Throw explicit `Exception('Gemini API Key is empty. Please configure it in .env')`. |
| **Non-Food Image** | Photo of car, dog, text document | Check `confidenceScore < 30` or `foodName == 'Unknown'`; show polite prompt to user: *"We couldn't clearly identify food in this image. Please try another angle."* |
| **Network Failure** | `SocketException` or HTTP 5xx | Catch exception, show retry button without clearing the chosen image. |
| **Rate Limiting** | HTTP 429 Quota Exceeded | Present cooldown timer / polite notification: *"AI service is busy, please wait a moment."* |

---

## 5. Mock Testing Without Consuming API Quota

To test UI and model deserialization without making real Gemini API calls, use fixture data:

```dart
final mockResponse = '''
{
  "foodName": "Mediterranean Greek Salad",
  "calories": 320,
  "servingSize": "1 medium bowl (250g)",
  "macros": {
    "protein": 7.5,
    "carbs": 12.0,
    "fat": 26.0,
    "fiber": 4.5,
    "sugar": 5.0
  },
  "vitaminsAndMinerals": ["Vitamin C", "Vitamin K", "Calcium"],
  "healthSummary": "High in healthy monounsaturated fats from olive oil and fiber from fresh vegetables.",
  "confidenceScore": 96.0,
  "ingredients": [
    {"name": "Feta Cheese", "amount": "50g", "calories": 130, "protein": 7, "carbs": 2, "fat": 11, "fiber": 0, "sugar": 2},
    {"name": "Kalamata Olives", "amount": "30g", "calories": 70, "protein": 0.5, "carbs": 2, "fat": 7, "fiber": 1, "sugar": 0},
    {"name": "Cucumber & Tomato", "amount": "150g", "calories": 40, "protein": 1.5, "carbs": 7, "fat": 0.5, "fiber": 2.5, "sugar": 4}
  ]
}
''';

final analysis = NutritionAnalysis.fromJson(jsonDecode(mockResponse));
```
