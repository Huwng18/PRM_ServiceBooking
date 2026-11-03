# Service Booking — Flutter PRM393

A learning/demo **Flutter mobile application** for service appointments. Features: mock sign-in, browse/search services, details, date/time picker, create appointments, show history, cancel appointments, local persistence, Provider state management, unit tests and widget test.

## IMPORTANT: current limitations
- Verified on Windows with Flutter 3.47.9: `flutter pub get`, `flutter analyze` (no issues), and `flutter test` (5 tests passed). A debug APK was built and the full booking flow was checked on the `ServiceBooking_API_36` emulator: sign in, view a service, book, restart, view the saved booking, cancel, and sign out.
- Mock login: any valid email + password >= 6 characters; this is **not a secure authentication system**. Do not use actual credentials.
- All bookings are saved on this device through SQLite database. For production use, consider a remote backend with server-side booking validation.
- Services are demo seed data. No payments, notifications, map, or chat.
- Generated `android/` and `ios/` platform folders are included. Building iOS requires macOS and Xcode.

## Setup
1. Install Flutter SDK and Android SDK; Android Studio can manage the SDK and emulator. Restart your IDE after adding Flutter to `PATH`.
2. Open a terminal inside this directory. On this Windows machine, use the existing junction below to avoid Flutter analyzer errors with the Unicode `Kì 8` directory:

   ```powershell
   cd C:\Users\HUNG\develop\prm-servicebooking
   ```

   This junction points to the original project; edits in either location affect the same files. On another machine, keep the project in a directory whose full path uses ASCII characters.
3. Run `flutter pub get`.
4. Check setup with `flutter doctor`; review and accept any missing Android SDK licenses using `flutter doctor --android-licenses`.
5. Start the configured Android emulator:

   ```powershell
   flutter emulators
   flutter emulators --launch ServiceBooking_API_36
   flutter devices
   flutter run -d emulator-5554
   ```

   Wait for Android to finish booting. Replace `emulator-5554` with the Android device ID printed by `flutter devices` if it differs. A connected Android phone with USB debugging enabled can also be selected by its device ID.
6. Run `flutter test` (unit and widget tests) and `flutter analyze`.
7. Build an Android debug APK with `flutter build apk --debug`. For a release artifact, use `flutter build apk --release` or `flutter build appbundle --release`; configure your own release signing before distributing it.

If Flutter version complains about package dependencies, run `flutter pub outdated` to select compatible versions. Ensure Android SDK and licenses are configured.

## Functional flow
Login (mock) -> service list/search -> service detail -> booking form (date/time/note) -> booking history -> cancellation -> logout. Persisted appointments stay saved after app restart.

## UI preview

The refreshed interface uses a consistent teal and cream palette, service-specific icons, clearer booking steps, and Vietnamese date/time pickers. Screenshots from the Android emulator: [Login](docs/screenshots/login.png), [Services](docs/screenshots/home.png), [Service detail](docs/screenshots/service-detail.png), [Booking form](docs/screenshots/booking-form.png), [Bookings](docs/screenshots/bookings.png), [Account](docs/screenshots/account.png), and [Vietnamese date picker](docs/screenshots/date-picker-vi.png).

## Architecture
`lib/models`: data entities; `lib/data`: demo catalog + persistence repository; `lib/providers`: ChangeNotifier session and booking state + business rules; `lib/screens`: Material UI; `test`: unit and widget tests.

## PRM393 alignment
- UI: Material 3, Scaffold, Card/ListTile, NavigationBar, Forms, DatePicker, TimePicker.
- State management: Provider + ChangeNotifier.
- Database requirement: **implemented (SQLite)**. SQLite (`sqflite`) stores bookings in a local database; SharedPreferences stores only the mock session. The demo service catalog is hardcoded.
- Deployment: Android debug APK build and emulator runtime were verified. Release signing and release builds are still pending.
- Testing: all 5 unit/widget tests passed and static analysis reported no issues on Windows. Run them again after changing the code.
- Technical report, group contributions, presentation slides and a 15-minute demo need group-specific updates.

## Project report
Use `docs/REPORT_GUIDE.md` to produce your team’s report. This is an instructional sample, not a ready-to-submit individual/group assignment.
