# SLA Task Tracker

A Flutter application for monitoring service-level agreement (SLA) tasks, assigning work to team members, and tracking delivery risk from a single dashboard.

The app is local-first. Tasks, team members, activity history, and sign-in preferences are stored on the device using `shared_preferences`.

## Features

- Dashboard with on-track, at-risk, overdue, and completed task counts
- Weekly SLA health chart for active tasks
- Task search and filtering by SLA status
- Create, edit, complete, reopen, and delete tasks
- Task details with SLA status, progress, assignee information, and activity history
- Team directory with member-level task and compliance views
- Local sign-in and first-time user creation
- Seeded demo data for a usable first launch
- Persistent local storage across app restarts
- Mouse, trackpad, touch, and standard wheel scrolling across supported screens

## Tech Stack

- Flutter
- Dart 3.13.4 or later
- Material 3 styling
- `shared_preferences` for local persistence

## Requirements

Install the Flutter SDK and verify the local environment:

```bash
flutter --version
flutter doctor
```

The project currently includes Flutter targets for Linux, Chrome, Android, iOS, macOS, and Windows.

## Getting Started

Clone the repository and enter the project directory:

```bash
git clone https://github.com/nakuwa23/sla-task-tracker.git
cd sla_task_tracker
```

Install dependencies:

```bash
flutter pub get
```

List available devices:

```bash
flutter devices
```

Run the application:

```bash
flutter run
```

Run against a specific target:

```bash
flutter run -d linux
flutter run -d chrome
flutter run -d macos
```

## Using The App

1. Launch the app and sign in with an email address.
2. Select an existing demo member or create a local profile when prompted.
3. Use the dashboard to review SLA health and active work.
4. Open **Tasks** to search, filter, create, and manage tasks.
5. Open a task to view its details, update it, mark it complete, or review its activity log.
6. Use **Team** to inspect member assignments and compliance.
7. Use **More** to sign out or review local app information.

## Project Structure

```text
lib/
  main.dart                 Application entry point and scroll configuration
  models/                   Task, SLA, team member, and activity models
  screens/                  Application screens and navigation flows
  services/                 Storage, seed data, state, and SLA calculations
  theme/                    Shared colors and Material theme
  utils/                    Formatting and shared utility functions
  widgets/                  Reusable task, status, avatar, and layout widgets
assets/
  images/                   Images used by the sign-in experience
test/
  widget_test.dart          Flutter widget tests
```

## Data And Storage

The app initializes its singleton `DataStore` during the splash flow. On first launch it creates demo members, tasks, and activity records. Changes are serialized to local `SharedPreferences` storage using versioned keys.

There is no remote API or server-side database in the current implementation. Clearing the application data resets the local workspace and restores the seeded demo data on the next launch.

## Validation

Run static analysis:

```bash
flutter analyze
```

Run tests:

```bash
flutter test
```

## Development Notes

- SLA status is calculated from task dates and completion state in `SlaCalculator`.
- Dashboard totals are derived from the current `DataStore` task collection.
- The shared `ScrollBehavior` supports desktop drag scrolling with a mouse or trackpad alongside normal wheel and touch gestures.