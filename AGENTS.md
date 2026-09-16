# NutriScanner Agent Guidelines & Repository Rules

Welcome to **NutriScanner** (NutriScan AI). This file defines the core architecture, platform boundaries, coding rules, and subagent delegation structure for any AI assistant or developer working on this codebase.

---

## 1. Supported Platforms & Scope

> [!IMPORTANT]
> **Active Target Platforms**: This application is strictly configured and maintained for **Android** and **Web**.
> - **DO NOT** add, configure, or introduce dependencies or boilerplate for iOS, macOS, Windows, or Linux.
> - Ensure all Flutter plugins and dependencies in `pubspec.yaml` support Android and Web.

- **Android**:
  - Targets smartphones, tablets, and specifically **foldable devices** (e.g., Samsung Galaxy Fold series).
  - Must support dynamic folding postures (unfolded dual-pane, cover screen, and tabletop/flex mode) with hinge avoidance.
  - Smooth 120Hz LTPO refresh rate scrolling (`BouncingScrollPhysics`) across Touch, Mouse, Trackpad, and Stylus/S-Pen.
- **Web**:
  - Modern web browsers (Chrome, Safari, Edge, Firefox).
  - Fluid responsiveness from narrow mobile viewports up to ultra-wide desktop monitors.

---

## 2. Codebase Structure

```text
NutriScanner/
├── AGENTS.md                                # Root agent rules and repository instructions
├── README.md                                # Project overview and platform guide
├── .agents/                                 # Customization system root
│   ├── subagents/                           # Specialized agent definitions and roles
│   └── skills/                              # Procedural runbooks and skills
│       ├── flutter-foldable-ui/             # Galaxy Fold & adaptive layout recipes
│       ├── gemini-vision-pipeline/          # Multimodal Gemini API & prompt recipes
│       ├── flutter-testing-quality/         # Test suites, mock fixtures & quality checks
│       ├── android-web-build/               # Android APK/AAB & Web build commands
│       └── nutrition-data-modeling/         # Models, macros recalculation & data schemas
└── nutri_client/                            # Flutter project root
    ├── pubspec.yaml                         # Dependencies (platforms: android, web)
    ├── .env.example                         # Environment variable template
    ├── android/                             # Android native configurations & manifests
    ├── web/                                 # Web entry points, icons & manifest
    ├── lib/
    │   ├── main.dart                        # App entry point, theme & 120Hz scroll physics
    │   ├── models/                          # Nutrition, macro, and ingredient data models
    │   │   └── nutrition_analysis.dart
    │   ├── services/                        # External services (Gemini Multi-modal API)
    │   │   └── gemini_service.dart
    │   ├── utils/                           # Screen & posture utilities
    │   │   └── foldable_layout.dart
    │   └── widgets/                         # Reusable UI widgets
    │       ├── donut_chart.dart             # Animated nutrition macro donut chart
    │       ├── header.dart                  # Responsive branding header
    │       ├── loading_view.dart            # Holographic laser scanner UI
    │       ├── results_view.dart            # Dual-pane / tabletop / cover screen results
    │       └── upload_zone.dart             # 1-tap capture & image dropzone
    └── test/                                # Automated tests
        └── nutrition_analysis_test.dart
```

---

## 3. Architecture & Coding Conventions

### Flutter & Dart Standards
- **Dart SDK**: `^3.11.5` | **Flutter SDK**: `^3.22.0`.
- **Strict Null Safety**: All code must strictly conform to null safety. Never use non-null assertions (`!`) unless guaranteed by preceding logic or guards.
- **Lint Compliance**: Code must pass `flutter analyze` with 0 warnings or errors, adhering to `flutter_lints`.
- **Theme & Design Language**:
  - Primary color palette: Emerald Green (`#10b981`), Dark Slate (`#1e293b`), Light Slate background (`#f8fafc`).
  - Font: Google Fonts Inter (`GoogleFonts.inter()`).
  - Material 3 enabled (`useMaterial3: true`).

### Foldable & Layout Invariants
- Always use `FoldableLayout` utilities (`lib/utils/foldable_layout.dart`) for screen classification and hinge detection.
- **Cover Screen (< 600 dp)**: Compact single-column vertical layout. Actions must be 1-tap thumb-accessible.
- **Main Screen (>= 600 dp)**: Dual-pane side-by-side layout (e.g. food image/macro donut on the left pane, ingredients/health details on the right pane).
- **Hinge Crease Avoidance**: Avoid rendering text, action buttons, or interactive chart centers directly across active display hinges (`DisplayFeatureType.hinge` or `fold`).
- **Tabletop / Flex Mode**: When partially folded (`FoldableLayout.isTabletopMode(context)` is true), position the visual content on the top half and interactive controls on the bottom half.

### Security & API Keys
- **NEVER** hardcode the Google Gemini API key in source code.
- Always load keys through `flutter_dotenv` via the `.env` asset file.
- Keep `.env` in `.gitignore`. Provide `.env.example` with dummy values.
- Never log or print the raw API key to console logs or error messages.

### Quality & Testing
- Every modification to `NutritionAnalysis`, `MacroData`, or `Ingredient` must include unit tests verifying:
  1. `fromJson` deserialization (including null/empty edge cases).
  2. `toJson` serialization.
  3. `copyWith` field preservation.
- UI changes should include widget tests verifying responsiveness across both Cover Screen and Main Screen dimensions.

---

## 4. Specialized Subagents

When tackling specific domains in NutriScanner, consult or delegate to the appropriate subagent:

| Role | Specification File | Specialty |
| :--- | :--- | :--- |
| **Flutter Architect** | [.agents/subagents/flutter_architect.md](.agents/subagents/flutter_architect.md) | State management, widget composition, performance, dependencies. |
| **Foldable UX Specialist** | [.agents/subagents/foldable_ux_specialist.md](.agents/subagents/foldable_ux_specialist.md) | Samsung Fold main/cover layouts, hinge avoidance, tabletop mode. |
| **Gemini Vision Engineer** | [.agents/subagents/gemini_vision_engineer.md](.agents/subagents/gemini_vision_engineer.md) | Prompt engineering, structured JSON schemas, multimodal payloads. |
| **QA Automation Engineer** | [.agents/subagents/qa_test_automation_engineer.md](.agents/subagents/qa_test_automation_engineer.md) | Widget tests, responsive test harnesses, mock data, CI/CD checks. |
| **Platform Release Engineer** | [.agents/subagents/platform_release_engineer.md](.agents/subagents/platform_release_engineer.md) | Android Gradle/APK/AAB, Web release optimization, GitHub Actions. |

---

## 5. Skills & Runbooks

Operational runbooks are located in `.agents/skills/`:
- `flutter-foldable-ui`: Step-by-step procedures for foldable screen & tabletop layouts.
- `gemini-vision-pipeline`: Updating Gemini prompts, structured schemas, and mock testing.
- `flutter-testing-quality`: Commands and guidelines for running and extending tests.
- `android-web-build`: Build procedures for Android release APK/AAB and Web release bundles.
- `nutrition-data-modeling`: Data model modification, micronutrients, and macro recalculations.
