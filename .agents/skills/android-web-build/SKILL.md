---
name: android-web-build
description: >-
  Use this skill when building, releasing, packaging, or troubleshooting Android APK/AAB builds
  and Web releases for NutriScanner, or maintaining GitHub Actions CI/CD workflows.
---

# Android & Web Platform Build Skill

This skill provides step-by-step procedures for building and packaging NutriScanner for **Android** and **Web**, ensuring optimal release performance and troubleshooting build issues.

---

## 1. Prerequisites & Environment Setup

- **Flutter SDK**: `^3.22.0` (channel `stable`)
- **Dart SDK**: `^3.11.5`
- **Java / JDK**: OpenJDK 17 (`zulu-17` or `temurin-17`)
- **Android SDK**: API 21+ (`minSdkVersion = 21`, `targetSdkVersion = 34+`)
- **Environment**: `.env` file present in `nutri_client/` with `GEMINI_API_KEY` defined

Verify your local environment:
```bash
flutter doctor -v
```

---

## 2. Android Build Procedures

Run inside `nutri_client/`:

### Building Debug APK (for fast emulator / local device testing)
```bash
flutter build apk --debug
# Output: build/app/outputs/flutter-apk/app-debug.apk
```

### Building Release APK (for direct sideloading or CI releases)
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Building Android App Bundle (AAB for Google Play Store)
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

### Android Native Permissions
Ensure `nutri_client/android/app/src/main/AndroidManifest.xml` includes only necessary permissions:
- `android.permission.INTERNET`: For Gemini API calls.
- `android.permission.CAMERA`: For taking food photos directly in-app.
- `android.permission.READ_MEDIA_IMAGES`: For gallery photo selection on Android 13+ (API 33+).

---

## 3. Web Build Procedures

Run inside `nutri_client/`:

### Local Web Development Run
```bash
flutter run -d chrome
```

### Production Web Build
```bash
flutter build web --release
# Output: build/web/
```

### Key Web Performance Configurations
- **Renderer**: By default, modern Flutter web uses HTML + CanvasKit / WebAssembly automatically.
- **Assets**: Ensure `.env` is listed under `assets:` in `pubspec.yaml` so web builds bundle the environment configuration.
- **Base HREF**: If deploying to a subpath (e.g. `https://domain.com/nutriscan/`), specify:
  ```bash
  flutter build web --release --base-href "/nutriscan/"
  ```

---

## 4. GitHub Actions CI/CD Maintenance

The automated build pipeline lives in `.github/workflows/android_build.yml`:
1. Checks out repository code.
2. Sets up JDK 17 (`actions/setup-java@v4` with `distribution: 'zulu'`).
3. Installs Flutter stable (`subosito/flutter-action@v2`).
4. Injects secret `GEMINI_API_KEY` into `nutri_client/.env`.
5. Runs `flutter pub get`.
6. Executes `flutter analyze`.
7. Executes `flutter test`.
8. Compiles `flutter build apk --release`.
9. Uploads `app-release.apk` artifact for 7-day download.

### Troubleshooting CI Failures
- **Gradle OOM Error**: Add `org.gradle.jvmargs=-Xmx4g -XX:MaxMetaspaceSize=512m` in `nutri_client/android/gradle.properties`.
- **Secret Missing**: In GitHub repo settings, verify `GEMINI_API_KEY` is added under *Secrets and variables > Actions*.
- **JDK Compatibility**: Always verify Gradle version supports JDK 17.
