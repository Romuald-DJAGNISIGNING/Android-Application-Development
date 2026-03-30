# Chapter 1 - Student Grade Calculator

This folder contains the Chapter 1 assignment in two distinct implementations:

- `Dart Version`: Flutter Windows desktop app.
- `Kotlin Version`: Native Android app with Jetpack Compose.

## What was extended in this version

- The grading logic still stays in the core layer.
- Import, export, sharing, and storage are now isolated behind service interfaces.
- A factory method now chooses the correct exporter at runtime.
- Abstract exporter classes hold the shared formatting and transformation logic.
- The delivery layer now supports multiple output formats:
  - Excel
  - CSV
  - JSON
  - PDF
  - Word-compatible RTF
- Sharing is now part of the application flow:
  - Flutter desktop uses the system share integration.
  - Android uses the native share sheet, so WhatsApp, Bluetooth, and Quick Share can be selected if they are available on the device.
- Cloud-ready delivery is part of the design:
  - Flutter desktop can copy reports into a synced folder such as OneDrive, Dropbox, or Google Drive Desktop.
  - Android can save through the Storage Access Framework to local or cloud-backed document providers.

## Documentation pack

- [Architecture](./Documentation/Architecture.md)
- [Class Diagram](./Documentation/Class-Diagram.md)
- [Component Diagram](./Documentation/Component-Diagram.md)
- [Sequence Diagram](./Documentation/Sequence-Diagram.md)
- [ER Diagram](./Documentation/ER-Diagram.md)
- [Activity Diagram](./Documentation/Activity-Diagram.md)
- [Use Case Diagram](./Documentation/Use-Case-Diagram.md)
- [Deployment Strategy](./Documentation/Deployment-Strategy.md)

## Main design ideas

- `StudentInputParser` keeps file parsing removable.
- `ReportExporter` keeps each export format isolated.
- `AbstractReportExporter` avoids duplicating row/summary formatting code.
- `ReportExporterFactory` is the factory method used by the delivery layer.
- `ReportDeliveryService` is the coordinator that the UI actually calls.
- `ReportShareService` keeps sharing out of the grading engine and out of the UI widgets.

## Submission note

The two versions are intentionally different in UI style, but they follow the same grading rules and the same delivery architecture so the lecturer can compare them side by side.
