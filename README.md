# GymLogger

An offline Flutter workout logger with four- and five-day training plans.
Set entries, workout completion, and the selected plan are saved on the device.

Run with `flutter run`. Build an Android APK with `flutter build apk --release`.

## Branding

The Dart package is `gym_logger`; the Android and iOS display name is GymLogger.
The existing Android application ID and iOS bundle identifier are retained so
updates preserve installed-app identity and local workout data.

The original logo is in `assets/branding/gym_logger_logo.png`. Launcher icons
are committed for Android and iOS. Regenerate their platform sizes on Windows
with `powershell -NoProfile -ExecutionPolicy Bypass -File tool/generate_icons.ps1`.

See `assets/branding/README.md` for the logo generation prompt and
`assets/data/README.md` for workout data and local storage details.
