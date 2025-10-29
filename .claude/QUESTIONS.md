# Migration Questions & Answers

Track questions that come up during the migration and their answers.

---

## Questions

### Q: Should we migrate all models to Freezed, or keep some as built_value?

**A:** [To be determined based on experience]

Options:
1. **Migrate all to Freezed** - Most consistent, but more work upfront
2. **Keep built_value for complex models** - Less churn, but maintains dual systems
3. **Use Dart 3 records for simple DTOs** - Zero codegen for simple data

**Recommendation:** Start with Freezed for new models, keep built_value for existing until you're comfortable. Then migrate model-by-model when touching that code anyway.

---

### Q: How do we handle offline-first functionality with Riverpod?

**A:** [To be determined]

Options:
1. **Firestore offline persistence** (current approach) + Riverpod streams
2. **Local database (Hive/Drift)** + sync layer
3. **Hybrid**: Firestore for auth, local DB for tasks

**Recommendation:** Keep Firestore offline persistence initially. Consider local DB in post-migration phase if needed.

---

### Q: Should we use go_router for navigation right away?

**A:** [To be determined]

**Recommendation:**
- Phase 1: Keep existing navigation, just set up go_router infrastructure
- Phase 2: Switch one screen at a time using feature flags
- Phase 3: Fully migrate to go_router

Benefits: Can rollback easily if issues arise.

---

### Q: How do we handle notifications with Riverpod?

**A:** Current `NotificationHelper` can remain a service class. Access it via Riverpod provider:

```dart
@riverpod
NotificationHelper notificationHelper(NotificationHelperRef ref) {
  final timezoneHelper = ref.watch(timezoneHelperProvider);
  return NotificationHelper(
    plugin: NotificationHelper.initializeNotificationPlugin(),
    timezoneHelper: timezoneHelper,
  );
}

// Use in controllers
final helper = ref.read(notificationHelperProvider);
await helper.scheduleNotification(...);
```

---

### Q: What about the complex recurrence logic?

**A:** `RecurrenceHelper` is already well-isolated and stateless. Keep it as-is! Just call it from Riverpod controllers instead of Redux middleware:

```dart
@riverpod
class CompleteRecurringTask extends _$CompleteRecurringTask {
  @override
  FutureOr<void> build() {}

  Future<void> call(TaskItem task) async {
    final completionDate = DateTime.now();

    // Same logic, different caller
    final nextTask = RecurrenceHelper.createNextIteration(
      task,
      completionDate,
    );

    // Rest of completion logic...
  }
}
```

---

### Q: How do we test Riverpod providers?

**A:** Much simpler than Redux! See PATTERNS.md for details:

```dart
test('task count is correct', () {
  final container = ProviderContainer(
    overrides: [
      tasksProvider.overrideWith((ref) => Stream.value([task1, task2])),
    ],
  );

  expect(container.read(taskCountProvider), 2);
});
```

---

### Q: Can Redux and Riverpod coexist during migration?

**A:** Yes! That's the whole strategy. Use feature flags:

```dart
if (FeatureFlags.useRiverpodForStats) {
  return StatsScreenRiverpod();  // New
} else {
  return StatsCounter();          // Old Redux
}
```

Run: `flutter run --dart-define=USE_RIVERPOD_STATS=true`

---

### Q: What happens to the Redux store during migration?

**A:** It keeps running alongside Riverpod. Both can access Firestore simultaneously. Delete Redux only after all screens migrated.

---

### Q: How do we handle loading states?

**A:** AsyncValue handles this automatically:

```dart
final tasksAsync = ref.watch(tasksProvider);

tasksAsync.when(
  data: (tasks) => TaskList(tasks),
  loading: () => CircularProgressIndicator(),
  error: (err, stack) => ErrorWidget(err),
);
```

Much cleaner than Redux loading flags!

---

### Q: What if we need to rollback mid-migration?

**A:** Easy:
1. **Specific feature**: Change feature flag to `false`
2. **Entire migration**: `git checkout main`
3. **Specific commit**: `git checkout <commit-hash>`

Redux continues working throughout migration.

---

### Q: Should we use code generation or manual providers?

**A:** **Use code generation (`@riverpod`)** for everything. It's the modern recommended approach and provides:
- Better type safety
- Auto-dispose behavior
- Simpler syntax
- Better DevTools integration

Only use manual providers (`StateProvider`, etc.) for very simple UI state like toggles.

---

## Add Your Questions Here

### Q: [Your question]

**A:** [Answer TBD]

---

## Useful Resources

- [Riverpod FAQ](https://riverpod.dev/docs/introduction/faq)
- [go_router Migration Guide](https://pub.dev/packages/go_router#migration-guide)
- [Freezed vs built_value](https://pub.dev/packages/freezed#comparison-with-built_value)
