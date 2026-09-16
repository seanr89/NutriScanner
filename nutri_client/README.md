# NutriScan AI Client (`nutri_client`)

A Flutter-based frontend client for **NutriScan AI**, delivering real-time multi-modal food analysis, calorie tracking, and nutritional insights.

---

## Target Platforms

This project is explicitly configured and maintained for:
1. **Android** (API Level 21+)
   - Standard phone form factors.
   - Foldable devices (optimized for **Samsung Galaxy Fold** 7.6" Main Screen, 5.5" Cover Screen, and Tabletop/Flex Mode).
2. **Web**
   - High-performance, responsive web application supporting modern Chromium, WebKit, and Gecko browsers.

> **Note**: iOS and Desktop platforms (macOS, Windows, Linux) are not currently configured or supported.

---

## Configuration

Platform targets are defined in `pubspec.yaml`:

```yaml
platforms:
  android:
  web:
```

### Environment Setup

The client loads your Gemini API key using `flutter_dotenv`:

1. Copy the example environment file:
   ```bash
   cp .env.example .env
   ```
2. Insert your key:
   ```env
   GEMINI_API_KEY=AIzaSy...
   ```

---

## Features & Responsive Architecture

- **Adaptive Breakpoints (`lib/utils/foldable_layout.dart`)**:
  - `Compact (< 600 dp)`: One-handed mobile experience for Cover Screens and standard phones.
  - `Medium (600 - 839 dp)`: Dual-pane dashboard for Foldables in portrait posture.
  - `Expanded (>= 840 dp)`: Expansive multi-column layouts for Foldables in landscape, tablets, and desktop web.
  - `Tabletop / Flex Mode`: Automatic layout split when a foldable device is half-opened on a table.
- **Fluid 120Hz LTPO AMOLED Support**:
  - `BouncingScrollPhysics` with touch, mouse, trackpad, and S-Pen gesture support.
- **Interactive Nutrition Dashboard**:
  - Proportional animated donut chart (`DonutChart`).
  - Dynamic ingredient list with real-time recalculation of calories and macronutrients upon adding, editing, or deleting items.

---

## Development Commands

```bash
# Get dependencies
flutter pub get

# Static code analysis
flutter analyze

# Run on Android
flutter run -d android

# Run on Web (Chrome)
flutter run -d chrome

# Run test suite
flutter test
```
