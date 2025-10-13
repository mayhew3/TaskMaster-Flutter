# Quick Start: Begin Migration

Ready to start the Redux → Riverpod migration? Follow these steps to get Phase 0 done today.

---

## ⚠️ STOP! Have You Written Tests Yet?

**Before proceeding, complete the testing phase in `.claude/TESTING_PLAN.md`.**

Migrating without tests is extremely risky. You need:
- ✅ 5+ critical path integration tests
- ✅ 15+ screen widget tests
- ✅ >70% code coverage

**Estimated time for testing:** 2 weeks

**Why it matters:** During migration, you'll rewrite state management, models, and business logic. Without tests, you won't know what broke until users report bugs.

If you've already completed testing, continue below. Otherwise, start with TESTING_PLAN.md first.

---

## Prerequisites

- ✅ Flutter 3.32.5+ installed
- ✅ Dart 3.8+ installed
- ✅ **Testing phase complete** (see TESTING_PLAN.md)
- ✅ All tests passing (101+ tests)
- ✅ Git branch ready for migration
- ✅ Baseline metrics recorded (optional but recommended)

---

## Step 1: Create Migration Branch (2 minutes)

```bash
# Make sure you're on main and up to date
git checkout main
git pull

# Create migration branch
git checkout -b feat/riverpod-migration

# Create backup branch (just in case)
git checkout -b backup-redux-original
git checkout feat/riverpod-migration
```

---

## Step 2: Record Baseline Metrics (5 minutes)

```bash
# Count files
find lib -name "*.dart" | wc -l > .claude/baseline_files.txt

# Time build
flutter clean
time flutter pub run build_runner build --delete-conflicting-outputs

# Time tests
time flutter test

# Record these in .claude/METRICS.md
```

---

## Step 3: Add Dependencies (2 minutes)

Edit `pubspec.yaml`:

```yaml
dependencies:
  # ADD THESE
  flutter_riverpod: ^2.6.1
  riverpod_annotation: ^2.6.1
  go_router: ^14.6.2
  freezed_annotation: ^2.4.4

dev_dependencies:
  # ADD THESE
  riverpod_generator: ^2.6.2
  freezed: ^2.5.7
```

```bash
flutter pub get
```

---

## Step 4: Create Directory Structure (1 minute)

```bash
mkdir -p lib/core/providers
mkdir -p lib/core/services
mkdir -p lib/core/router
mkdir -p lib/features/tasks/data
mkdir -p lib/features/tasks/domain
mkdir -p lib/features/tasks/presentation
mkdir -p lib/features/tasks/providers
mkdir -p lib/features/sprints/data
mkdir -p lib/features/sprints/domain
mkdir -p lib/features/sprints/presentation
mkdir -p lib/features/sprints/providers
mkdir -p lib/features/auth/data
mkdir -p lib/features/auth/domain
mkdir -p lib/features/auth/presentation
mkdir -p lib/features/auth/providers
```

---

## Step 5: Wrap App with ProviderScope (3 minutes)

Edit `lib/main.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //  Initialize logger
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // WRAP TaskMasterApp with ProviderScope
  runApp(
    ProviderScope(
      child: TaskMasterApp(),
    ),
  );
}
```

Test it:
```bash
flutter run
# App should work exactly as before
```

---

## Step 6: Create Core Firebase Providers (10 minutes)

Create `lib/core/providers/firebase_providers.dart`:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'firebase_providers.g.dart';

@riverpod
FirebaseFirestore firestore(FirestoreRef ref) {
  final instance = FirebaseFirestore.instance;

  const serverEnv = String.fromEnvironment('SERVER', defaultValue: 'heroku');
  if (serverEnv == 'local') {
    instance.useFirestoreEmulator('127.0.0.1', 8085);
    instance.settings = const Settings(persistenceEnabled: false);
  } else {
    instance.settings = const Settings(
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  return instance;
}

@riverpod
FirebaseAuth firebaseAuth(FirebaseAuthRef ref) => FirebaseAuth.instance;
```

Create `lib/core/providers/auth_providers.dart`:

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'firebase_providers.dart';

part 'auth_providers.g.dart';

@riverpod
GoogleSignIn googleSignIn(GoogleSignInRef ref) => GoogleSignIn.instance;

@riverpod
Stream<User?> authStateChanges(AuthStateChangesRef ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return auth.authStateChanges();
}

@riverpod
User? currentUser(CurrentUserRef ref) {
  final authState = ref.watch(authStateChangesProvider);
  return authState.maybeWhen(
    data: (user) => user,
    orElse: () => null,
  );
}

@riverpod
Future<String?> personDocId(PersonDocIdRef ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;

  final firestore = ref.watch(firestoreProvider);
  final snapshot = await firestore
      .collection('persons')
      .where('email', isEqualTo: user.email)
      .get();

  return snapshot.docs.firstOrNull?.id;
}
```

---

## Step 7: Generate Code (2 minutes)

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Expected output: Should see `.g.dart` files created next to your providers.

---

## Step 8: Test Everything Still Works (3 minutes)

```bash
# Run app
flutter run

# Run tests
flutter test

# Both should work exactly as before
```

---

## Step 9: Commit Phase 0 (2 minutes)

```bash
git add .
git commit -m "Phase 0: Set up Riverpod foundation

- Add Riverpod, Freezed, go_router dependencies
- Create directory structure for feature-based architecture
- Add core Firebase and auth providers
- Wrap app with ProviderScope
- App still fully functional with Redux"
```

---

## ✅ Phase 0 Complete!

**Time spent:** ~30 minutes

**What you have now:**
- ✅ Riverpod infrastructure in place
- ✅ App still works identically to before
- ✅ Foundation ready for incremental migration
- ✅ Clean commit showing exactly what changed

**Next steps:**
- Read `.claude/MIGRATION_PLAN.md` Phase 1
- Start implementing stream providers for tasks
- Create first business logic service

**Or take a break!** Phase 0 is a great stopping point. The app is fully functional and you can continue whenever ready.

---

## Troubleshooting

### Build runner fails

```bash
# Clean and retry
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Import errors

Make sure you have `part 'filename.g.dart';` at the top of files with `@riverpod` annotations.

### App crashes on startup

Check that ProviderScope is wrapping the entire app in `main.dart`.

### Tests fail

Check if tests are importing Redux-specific mocks that need updating.

---

## Questions?

Add them to `.claude/QUESTIONS.md` and we'll address them in the next session!

## Celebrate! 🎉

You just set up a modern Flutter architecture foundation without breaking anything. Nice work!
