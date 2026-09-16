# NutriScanner Workspace Rules & Agent Instructions

This file is the `.agents/` configuration entrypoint for Antigravity, delegating to the comprehensive repository rules defined in [AGENTS.md](../AGENTS.md).

## Quick Summary of Invariants
1. **Target Platforms**: Strictly **Android** and **Web**. No iOS or desktop dependencies.
2. **Foldable UX**: Samsung Galaxy Fold screen classes (Cover < 600dp, Main >= 600dp) and Tabletop/Flex posture support.
3. **AI Vision**: Google Gemini API via `gemini_service.dart` with strict JSON schema parsing.
4. **Security**: Never hardcode API keys. Always use `.env` and `flutter_dotenv`.
5. **Quality**: Code must pass `flutter analyze` and `flutter test` cleanly.

## Available Subagents
- `flutter-architect`: State management, widget composition, architecture.
- `foldable-ux-specialist`: Samsung Fold dual-pane, tabletop mode, hinge gutters.
- `gemini-vision-engineer`: Gemini prompt design, multimodal input, JSON schemas.
- `qa-test-automation-engineer`: Unit tests, responsive widget tests, CI checks.
- `platform-release-engineer`: Android builds (APK/AAB), Web builds, GitHub Actions.

See [.agents/subagents/](subagents/) and [.agents/skills/](skills/) for detailed runbooks.
