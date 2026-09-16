import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:nutri_client/main.dart';
import 'package:nutri_client/models/nutrition_analysis.dart';
import 'package:nutri_client/services/gemini_service.dart';
import 'package:nutri_client/widgets/loading_view.dart';
import 'package:nutri_client/widgets/upload_zone.dart';

// Valid 1x1 transparent PNG bytes for testing Image.memory widgets
final kTestPngBytes = Uint8List.fromList(<int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
  0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
  0x42, 0x60, 0x82,
]);

// Sample valid Gemini response body with structured JSON
const String kValidGeminiResponseBody = '''
{
  "candidates": [
    {
      "content": {
        "parts": [
          {
            "text": "{\\"foodName\\": \\"Mediterranean Bowl\\", \\"calories\\": 420.0, \\"servingSize\\": \\"1 bowl (300g)\\", \\"macros\\": {\\"protein\\": 24.0, \\"carbs\\": 45.0, \\"fat\\": 16.0, \\"fiber\\": 8.0, \\"sugar\\": 4.0}, \\"vitaminsAndMinerals\\": [\\"Iron\\", \\"Vitamin C\\", \\"Folate\\"], \\"healthSummary\\": \\"A balanced nutrient-dense meal high in fiber and lean protein.\\", \\"confidenceScore\\": 95.0, \\"ingredients\\": [{\\"name\\": \\"Quinoa\\", \\"amount\\": \\"100g\\", \\"calories\\": 120.0, \\"protein\\": 4.5, \\"carbs\\": 21.0, \\"fat\\": 2.0, \\"fiber\\": 3.0, \\"sugar\\": 1.0}, {\\"name\\": \\"Grilled Chicken\\", \\"amount\\": \\"120g\\", \\"calories\\": 200.0, \\"protein\\": 18.0, \\"carbs\\": 0.0, \\"fat\\": 10.0, \\"fiber\\": 0.0, \\"sugar\\": 0.0}]}"
          }
        ]
      }
    }
  ]
}
''';

void main() {
  group('GeminiService.analyzeFoodImage Tests', () {
    test('Constructs multimodal payload and parses successful response', () async {
      String? requestedUrl;
      Map<String, dynamic>? sentPayload;

      final mockClient = MockClient((request) async {
        requestedUrl = request.url.toString();
        sentPayload = jsonDecode(request.body) as Map<String, dynamic>;

        return http.Response(kValidGeminiResponseBody, 200, headers: {
          'content-type': 'application/json',
        });
      });

      final result = await GeminiService.analyzeFoodImage(
        imageBytes: kTestPngBytes,
        mimeType: 'image/png',
        apiKey: 'test_secret_api_key',
        client: mockClient,
      );

      // Verify URL contains API key
      expect(requestedUrl, contains('key=test_secret_api_key'));

      // Verify payload structure
      expect(sentPayload, isNotNull);
      final contents = sentPayload!['contents'] as List;
      expect(contents, isNotEmpty);
      final parts = contents[0]['parts'] as List;
      final inlineData = parts[0]['inlineData'];
      expect(inlineData['mimeType'], 'image/png');
      expect(inlineData['data'], base64Encode(kTestPngBytes));

      // Verify parsed output
      expect(result.foodName, 'Mediterranean Bowl');
      expect(result.calories, 420.0);
      expect(result.servingSize, '1 bowl (300g)');
      expect(result.macros.protein, 24.0);
      expect(result.macros.carbs, 45.0);
      expect(result.macros.fat, 16.0);
      expect(result.vitaminsAndMinerals, contains('Iron'));
      expect(result.confidenceScore, 95.0);
      expect(result.ingredients.length, 2);
      expect(result.ingredients[0].name, 'Quinoa');
    });

    test('Throws informative exception when Gemini returns non-200 HTTP code', () async {
      final mockClient = MockClient((request) async {
        return http.Response('{"error": {"message": "API key not valid."}}', 400);
      });

      expect(
        () => GeminiService.analyzeFoodImage(
          imageBytes: kTestPngBytes,
          mimeType: 'image/png',
          apiKey: 'invalid_key',
          client: mockClient,
        ),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Failed to communicate with Gemini API: 400'),
        )),
      );
    });

    test('Throws exception when candidates or parts text is missing', () async {
      final mockClient = MockClient((request) async {
        return http.Response('{"candidates": []}', 200);
      });

      expect(
        () => GeminiService.analyzeFoodImage(
          imageBytes: kTestPngBytes,
          mimeType: 'image/png',
          apiKey: 'key',
          client: mockClient,
        ),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('No analysis result received from Gemini.'),
        )),
      );
    });

    test('Throws exception when text cannot be parsed as JSON', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'candidates': [
              {
                'content': {
                  'parts': [
                    {'text': 'Not a valid JSON payload'}
                  ]
                }
              }
            ]
          }),
          200,
        );
      });

      expect(
        () => GeminiService.analyzeFoodImage(
          imageBytes: kTestPngBytes,
          mimeType: 'image/png',
          apiKey: 'key',
          client: mockClient,
        ),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Failed to parse nutrition analysis JSON from response'),
        )),
      );
    });
  });

  group('UploadZone Widget Tests', () {
    testWidgets('Renders headline, drop zone, and 1-tap direct action buttons',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UploadZone(
              onPhotoSelected: (bytes, mime, name) {},
            ),
          ),
        ),
      );

      // Verify branding and headline
      expect(find.text('Smart Visual Recognition'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is RichText &&
              widget.text.toPlainText().contains('Know What You'),
        ),
        findsOneWidget,
      );
      expect(find.text('Drop meal photo here, or tap to choose'), findsOneWidget);
      expect(find.text('Supports JPG, PNG, WEBP'), findsOneWidget);

      // Verify direct action buttons
      expect(find.text('Camera'), findsOneWidget);
      expect(find.text('Gallery'), findsOneWidget);
    });

    testWidgets('Adapts to widescreen layout when viewport >= 840dp',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UploadZone(
              onPhotoSelected: (bytes, mime, name) {},
            ),
          ),
        ),
      );

      // Feature chips are present on wide layout
      expect(find.text('Instant AI Scan'), findsOneWidget);
      expect(find.text('Macro Breakdown'), findsOneWidget);
      expect(find.text('Custom Portions'), findsOneWidget);
    });
  });

  group('LoadingView Widget Tests', () {
    testWidgets('Renders image and status text during scan',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingView(
              imageBytes: kTestPngBytes,
            ),
          ),
        ),
      );

      // Verify initial scanning status text is rendered
      expect(find.text('Scanning food dish...'), findsOneWidget);

      // Verify the image is displayed
      expect(find.byType(Image), findsOneWidget);

      // Pump 1.5 seconds to advance the status message timer
      await tester.pump(const Duration(milliseconds: 1500));
      expect(find.text('Deconstructing macro ratios...'), findsOneWidget);
    });
  });

  group('End-to-End Scan and Process Flow in MyHomePage', () {
    testWidgets('Full flow: Upload -> Scanning -> Results -> Reset to Upload',
        (WidgetTester tester) async {
      final sampleAnalysis = NutritionAnalysis(
        foodName: 'Greek Yogurt Parfait',
        calories: 280,
        servingSize: '1 cup',
        macros: const MacroData(protein: 15, carbs: 32, fat: 8, fiber: 4, sugar: 18),
        vitaminsAndMinerals: ['Calcium', 'Probiotics'],
        healthSummary: 'High in protein and probiotics.',
        confidenceScore: 97,
        ingredients: [
          Ingredient(
            name: 'Greek Yogurt',
            amount: '150g',
            calories: 140,
            protein: 14,
            carbs: 6,
            fat: 5,
            fiber: 0,
            sugar: 6,
          ),
          Ingredient(
            name: 'Mixed Berries',
            amount: '50g',
            calories: 40,
            protein: 0.5,
            carbs: 9,
            fat: 0.3,
            fiber: 3,
            sugar: 7,
          ),
        ],
      );

      // Render MyHomePage with injected mock foodAnalyzer
      await tester.pumpWidget(
        MaterialApp(
          home: MyHomePage(
            foodAnalyzer: ({required imageBytes, required mimeType, required apiKey}) async {
              // Simulate API delay
              await Future.delayed(const Duration(milliseconds: 50));
              return sampleAnalysis;
            },
          ),
        ),
      );

      // 1. Initial State: AppScanState.idle with UploadZone
      expect(find.byKey(const ValueKey('upload_zone')), findsOneWidget);
      expect(find.text('Drop meal photo here, or tap to choose'), findsOneWidget);

      // 2. Trigger photo selection callback via UploadZone widget
      final uploadZone = tester.widget<UploadZone>(find.byType(UploadZone));
      uploadZone.onPhotoSelected(kTestPngBytes, 'image/png', 'sample_dish.png');

      // Re-render to reflect AppScanState.scanning
      await tester.pump();
      expect(find.byKey(const ValueKey('loading_view')), findsOneWidget);
      expect(find.text('Scanning food dish...'), findsOneWidget);

      // 3. Fast-forward through analyzer delay and animation transition
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      // 4. Results State: AppScanState.results with ResultsView
      expect(find.byKey(const ValueKey('results_view')), findsOneWidget);
      expect(find.text('Greek Yogurt Parfait'), findsOneWidget);
      expect(find.text('Greek Yogurt'), findsOneWidget);
      expect(find.text('Mixed Berries'), findsOneWidget);

      // 5. Tap "Analyze Another Photo" button to reset
      final analyzeAnotherBtn = find.text('Analyze Another Photo');
      expect(analyzeAnotherBtn, findsOneWidget);
      await tester.ensureVisible(analyzeAnotherBtn);
      await tester.pumpAndSettle();
      await tester.tap(analyzeAnotherBtn);
      await tester.pumpAndSettle();

      // 6. Verified reset to idle state
      expect(find.byKey(const ValueKey('upload_zone')), findsOneWidget);
    });

    testWidgets('Error flow: Analyzer failure transitions to error view and recovers',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MyHomePage(
            foodAnalyzer: ({required imageBytes, required mimeType, required apiKey}) async {
              throw Exception('Network connection failed.');
            },
          ),
        ),
      );

      // Trigger photo selection
      final uploadZone = tester.widget<UploadZone>(find.byType(UploadZone));
      uploadZone.onPhotoSelected(kTestPngBytes, 'image/png', 'photo.png');

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      // Verified error view displayed
      expect(find.byKey(const ValueKey('error_view')), findsOneWidget);
      expect(find.text('Analysis Failed'), findsOneWidget);

      // Tap Go Back button
      final tryAgainBtn = find.text('Go Back & Select Another Photo');
      expect(tryAgainBtn, findsOneWidget);
      await tester.tap(tryAgainBtn);
      await tester.pumpAndSettle();

      // Returns to UploadZone
      expect(find.byKey(const ValueKey('upload_zone')), findsOneWidget);
    });
  });
}
