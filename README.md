# TidyDay

TidyDay is an Android task list built with Flutter, Firebase Authentication, Cloud Firestore, and BLoC. Sign in with Google to add, edit, complete, reopen, and delete tasks. A task can have notes and a due date.

## Run on Android

Install Flutter and the Android SDK, then start a Google Play emulator or connect an Android 7.0 or later device with Google Play services. The project was built with Flutter 3.44.5 and Dart 3.12.2.

```sh
flutter pub get
flutter run
```

The included configuration targets Firebase project `tidyday-ahmed` and Android package `com.ahmed.tidyday`. Google Sign-In checks the signing certificate, so a build signed with a different debug key needs that key's SHA-1 and SHA-256 registered in Firebase. On Windows, open the `android` directory and run `.\gradlew.bat signingReport`. [Firebase Android sign-in setup](https://firebase.google.com/docs/auth/android/google-signin)

## Connect another Firebase project

1. Create a Firebase project, enable the Google provider in Authentication, and create its default Firestore database.
2. Register `com.ahmed.tidyday` as an Android app and add your signing fingerprints. Refresh the Firebase configuration after enabling Google Sign-In and registering the fingerprints. [FlutterFire setup](https://firebase.google.com/docs/flutter/setup)
3. Run the commands below from the project folder, substituting your project ID.

```sh
flutterfire configure --project YOUR_PROJECT_ID --platforms android --yes --overwrite-firebase-options
firebase deploy --only firestore:rules --project YOUR_PROJECT_ID
```

Tasks are stored at `users/{uid}/tasks/{taskId}`. Firestore rules grant access to the signed-in owner and validate the task fields. A due date is stored as `YYYY-MM-DD` so it stays on the selected calendar day across time zones.

## Check and build

```sh
flutter analyze
flutter test
flutter build apk --debug
```

The installable debug APK is at `build/app/outputs/flutter-apk/app-debug.apk`.

The Firebase CLI and Node.js can check the Firestore rules locally.

```sh
firebase emulators:exec --only auth,firestore --project demo-tidyday "node tools/test-firestore-rules.mjs"
```

## Source layout

- `lib/controller` contains the authentication and task BLoCs.
- `lib/core` contains the app theme and Google sign-in service.
- `lib/data` contains the task model and Firestore data source.
- `lib/view` contains screens and shared widgets.
