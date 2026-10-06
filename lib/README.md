# MVVM structure

- `app/`: app shell, theme configuration, and dependency wiring. Creates and
  disposes the home ViewModel for the app session.
- `models/`: plain Dart workout data, JSON conversion, and workout rules. These
  classes have no Flutter or platform dependencies.
- `repositories/`: injectable contracts and implementations for asset loading
  and local progress storage. File storage preserves the existing versioned
  JSON format, migration, and backup recovery.
- `ui/home/`: home view and its ViewModel, which handles loading, errors, retry,
  version metadata, and ownership of the shared workout ViewModel.
- `ui/workout/`: workout view and shared workout ViewModel. The ViewModel exposes
  model state and commands, serializes save requests, and reports saving/errors.
- `ui/changelog/`: static release notes and their view.
- `ui/core/`: reusable widgets and theme colors.

Views depend on models and ViewModels. ViewModels depend on models and repository
contracts; they never resolve platform services. `app/dependencies.dart` chooses
the concrete repositories and platform callbacks. No extra state-management or
dependency-injection package is required; views observe `ChangeNotifier` through
Flutter's listenable builders.

Keep transient visual state (expanded cards, focus, text controllers, navigation)
in views. Put workout rules in models, asynchronous screen state and commands in
ViewModels, and storage/asset access in repositories. Static views do not need an
empty ViewModel.

The workout ViewModel captures a detached snapshot for every edit and completes
queued saves even when disposed. Disposal stops notifications, not persistence.
The repository reports storage failures; the ViewModel retains edits for retry.

Run `flutter analyze` and `flutter test` from the project root.
