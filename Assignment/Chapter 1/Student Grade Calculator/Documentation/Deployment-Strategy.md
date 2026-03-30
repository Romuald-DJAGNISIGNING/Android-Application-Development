# Deployment Strategy

## 1. Packaging targets

- Dart version
  - Target: Windows desktop executable
  - Packaging: release folder containing `.exe`, DLLs, and runtime assets
- Kotlin version
  - Target: Android APK
  - Packaging: debug and release builds from Gradle

## 2. Runtime strategy

- Offline-first by default.
- No backend is required for grading.
- Export and share features work locally first.
- Cloud support uses the platform storage mechanism:
  - Desktop: synced folders such as OneDrive or Dropbox.
  - Android: Storage Access Framework providers such as Drive.

## 3. Delivery strategy by platform

### Flutter desktop

1. User imports a local file.
2. Report is generated locally.
3. User chooses:
- local save path
- cloud-synced folder
- system share action

### Android

1. User imports through the document picker.
2. Report is generated in memory.
3. User chooses:
- local device storage
- cloud-backed document provider
- Android share sheet

## 4. Extension strategy

New services should follow this rule:

- Add a new interface implementation.
- Register it in the factory or delivery service.
- Keep the grading engine untouched.

This keeps the code open for extension and closed for unnecessary changes in the core grading module.
