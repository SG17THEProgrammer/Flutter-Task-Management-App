# Task Management App (Track B)

A polished, functional task management app built with Flutter using local Hive database for persistence. Designed with a clean Material 3 UI and smooth transitions.

## Features

- **Task CRUD Operations**: Create, Read, Update, Delete tasks
- **Task Model**: Title, Description, Due Date, Status (To-Do, In Progress, Done), and optional Blocked By relationship
- **Blocked Tasks**: Tasks blocked by incomplete tasks appear greyed out and cannot be edited until the blocking task is completed
- **Search & Filter**: Debounced search (300ms) by title; filter by status
- **Form Drafts**: Unfinished task drafts are preserved when app is minimized or user navigates back
- **2-Second Delay Simulation**: All create/update operations simulate a network delay with proper loading state and button disabling
- **UI/UX Polish**: Material 3 theme, smooth page transitions, responsive design

## Project Structure

```
lib/
├── main.dart
├── models/
│   ├── task.dart
│   └── task.g.dart (generated)
├── screens/
│   ├── main_screen.dart
│   └── task_form_screen.dart
├── widgets/
│   └── task_card.dart
├── services/
│   ├── task_dao.dart
│   └── debouncer.dart
└── utils/
    └── date_extensions.dart
```

## Setup Instructions

### Prerequisites

- Flutter SDK (>= 3.4.0)
- Android Studio or VS Code with Flutter extension

### Installation

1. Clone or download this project
2. Open terminal in the project directory
3. Install dependencies:

```bash
flutter pub get
```

4. Generate Hive adapters:

```bash
flutter pub run build_runner build
```

5. Run the app:

```bash
flutter run
```

### IDE Setup (Optional)

For automatic code generation in VS Code/Android Studio, you may install the `build_runner` and `Hive` extensions, but the command line method above works consistently.

## Track B Implementation Notes

- **State Management**: Provider pattern
- **Database**: Hive (NoSQL, local, fast)
- **UI**: Material Design 3 with custom theming
- **Screens**:
  - `MainScreen`: Task list with search, filter, and FAB for adding tasks
  - `TaskFormScreen`: Create/Edit task modal
- **Widgets**:
  - `TaskCard`: Displays task with status, due date, and blocking state

## Build & Release

To build an APK:

```bash
flutter build apk
```

For iOS (requires macOS):

```bash
flutter build ios
```

Built with Flutter & Hive for the Track B assignment.

## AI usage
I used Claude Code for the app
Used MAGIC prompt strategy to get the most out of the LLM.
For the resolutions of errors, just provided the errors to the claude code. No need to give anything extra as claude code remembers the context already 🙂 
