# NutriScanner (NutriScan AI)

**NutriScanner** is an AI-powered visual nutrition analyzer and meal tracking application built with Flutter and powered by Google Gemini Multi-modal AI. Users can snap or upload photos of meals and receive instant breakdowns of calories, macronutrients, dynamic ingredient lists, vitamins and minerals, and actionable dietary health insights.

---

## Supported Platforms

> [!IMPORTANT]
> **Active Target Platforms**: This application is specifically configured and supported for **Android** and **Web** at this time. Desktop (macOS, Windows, Linux) and iOS targets are not currently configured or supported.

- **Android**:
  - Full support for Android smartphones, tablets, and **Foldable devices**.
  - Specifically designed and tested for **Samsung Galaxy Fold** devices:
    - **Main Screen (7.6" Dynamic LTPO AMOLED 2X, 1848 x 2448, 403 ppi, 120Hz)**: Full dual-pane dashboard layout with center crease/hinge avoidance gutter.
    - **Cover Screen (5.5" Dynamic LTPO AMOLED 2X, 1248 x 1972, 428 ppi, 120Hz)**: Streamlined, compact single-column layout with responsive donut chart and 1-tap capture actions.
    - **Flex / Tabletop Mode**: Posture-aware layout splitting top viewing panel and bottom interactive control panel when partially folded.
    - **120Hz Refresh Rate**: Fluid `BouncingScrollPhysics` with multi-device input (Touch, Mouse, Trackpad, S-Pen).
- **Web**:
  - Fully responsive web app running on modern browsers (Chrome, Edge, Safari, Firefox).
  - Adapts fluidly across compact mobile web viewports up to ultra-wide desktop monitors.

---

## Key Features

- **Visual Food Recognition**: Upload or take photos directly with the device camera or gallery.
- **Holographic Scanning Animation**: Real-time laser scanning feedback while Gemini AI analyzes the dish.
- **Calorie & Macro Breakdown**:
  - Interactive, scalable animated Donut Chart.
  - Proportional breakdown of Protein, Carbs, Fat, Fiber, and Sugar.
- **Dynamic Ingredients & Portions**:
  - Automatic identification of constituent ingredients and estimated portion weights.
  - Full inline interactive editing: add, edit, or delete ingredients with automatic real-time macro recalculation.
- **Micronutrients & Vitamins**: Highlights prominent vitamins and minerals (e.g. Potassium, Omega-3, Vitamin C).
- **Health Insights**: AI-generated nutritional analysis and health context.

---

## Project Structure

```text
NutriScanner/
├── README.md                      # Root project overview & platform guide
└── nutri_client/                  # Flutter application root
    ├── pubspec.yaml               # Dependencies & platform declarations (android, web)
    ├── .env.example               # Template for environment variables
    ├── android/                   # Native Android application configuration
    ├── web/                       # Web application entry point and assets
    ├── lib/
    │   ├── main.dart              # App entry point, theme & 120Hz scroll physics
    │   ├── models/
    │   │   └── nutrition_analysis.dart # Nutrition, macro, and ingredient data models
    │   ├── services/
    │   │   └── gemini_service.dart     # Google Gemini multi-modal API integration
    │   ├── utils/
    │   │   └── foldable_layout.dart    # Window size classes, hinge gutter & flex mode
    │   └── widgets/
    │       ├── donut_chart.dart        # Responsive animated macronutrient chart
    │       ├── header.dart             # Responsive branding header
    │       ├── loading_view.dart       # Holographic laser scanner & analysis steps
    │       ├── results_view.dart       # Dual-pane / tabletop / cover screen results
    │       └── upload_zone.dart        # Interactive drop zone & 1-tap capture
    └── test/
        └── nutrition_analysis_test.dart # Unit and responsive widget tests
```

---

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (version 3.22.0 or higher)
- [Dart SDK](https://dart.dev/get-dart) (version 3.4.0 or higher)
- For Android: Android Studio / Android SDK (API level 21+)
- For Web: Google Chrome or any modern Chromium browser
- A [Google Gemini API Key](https://aistudio.google.com/)

### Installation & Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/seanr89/NutriScanner.git
   cd NutriScanner/nutri_client
   ```

2. **Install Flutter dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure Environment Variables:**
   Create a `.env` file in the `nutri_client/` directory:
   ```bash
   cp .env.example .env
   ```
   Add your Google Gemini API key:
   ```env
   GEMINI_API_KEY=your_actual_gemini_api_key_here
   ```

---

## Running the Application

### Android

Ensure an Android device or emulator is connected:
```bash
# Check connected devices
flutter devices

# Run on Android
flutter run -d android
```

### Web

Run locally in Google Chrome:
```bash
flutter run -d chrome
```

Build release bundle for Web deployment:
```bash
flutter build web --release
```

---

## Testing & Quality

Run the test suite and static analysis:

```bash
# Run static analysis
flutter analyze

# Run unit and widget tests
flutter test
```

---

## License

© 2026 NutriScan AI. Not medical advice. Estimates only.
