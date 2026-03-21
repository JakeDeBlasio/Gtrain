# GTrain Training Matrix

Flutter source scaffold for a training matrix app designed for web, iOS, and Android.

## What is included
- Users table with building, account, and template assignment
- Trainings table with title, description, renewal cadence, and attached source documents
- Templates table that auto-assigns trainings to users if they do not already have them
- User detail matrix with per-user assigned trainings and completion / renewal workflow
- Firebase Firestore + Firebase Storage repository layer
- GEODIS-inspired theme using:
  - Blue `#011956`
  - Orange `#e7672c`

## Firebase project
Target project: `gtrain-73d1b`

The app is wired to that project id, but platform-specific Firebase keys are still placeholders because they must be generated from your Firebase account.

## Setup
1. Install Flutter and FlutterFire CLI.
2. In this folder run:

```bash
flutter create . --platforms=web,ios,android
flutter pub get
flutterfire configure --project=gtrain-73d1b
```

3. Copy the generated Firebase values into `lib/config/firebase_project_config.dart` or replace that file with the generated `firebase_options.dart` pattern if you prefer.
4. Deploy rules:

```bash
firebase deploy --only firestore:rules,firestore:indexes,storage
```

5. Run the app:

```bash
flutter run -d chrome
```

## Firestore collections
- `users`
- `trainings`
- `templates`
- `assignments`

## Notes
- Adding a template to a user auto-creates missing assignment records.
- Removing a template from a user does **not** currently remove existing assignments. That is deliberate to avoid accidental data loss.
- Training documents are uploaded to Firebase Storage under `training_documents/{trainingId}/...`

## Suggested next improvements
- Firebase Auth + role-based admin access
- CSV import for users
- Expiration dashboards by building/account
- Signed document version history
- Push notifications and email reminders
