# Architecture Overview

The application is built as a layered mini-system instead of a single script:

1. Presentation layer
- Flutter widgets and Riverpod controller in Dart.
- Compose screen and ViewModel in Kotlin.

2. Core/domain layer
- Grade models, validation issues, summary models, grading rules, and analytics.
- This layer decides how marks become grades.

3. Service layer
- File import parsers.
- Report delivery coordinator.
- Exporters.
- Share service.

4. Infrastructure layer
- Excel writer.
- PDF writer.
- CSV/JSON/RTF writers.
- Android document picker and Android share sheet.
- Desktop file picker and desktop share integration.

## OOP decisions used on purpose

- Interfaces:
  - `StudentInputParser`
  - `ReportExporter`
  - `ReportShareService`
  - `CloudSyncService` in the Dart version
- Abstract classes:
  - `BaseReportExporter` in Dart
  - `AbstractReportExporter` in Kotlin
- Factory method:
  - `ReportExporterFactory.create(format)`
- Coordinator/service object:
  - `ReportDeliveryService`

## Why this matters

If a lecturer asks to remove JSON export or add a new exporter later, the grading engine does not change. The app only swaps the concrete exporter implementation behind the interface.

## Main runtime flow

1. Import file.
2. Parse rows.
3. Grade rows.
4. Build analytics.
5. Select export format and destination.
6. Use factory method to resolve the correct exporter.
7. Export the report.
8. Optionally share the exported artifact.
