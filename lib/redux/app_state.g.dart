// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_state.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AppState extends AppState {
  @override
  final BuiltList<TaskItem> taskItems;
  @override
  final BuiltList<Sprint> sprints;
  @override
  final BuiltList<TaskRecurrence> taskRecurrences;
  @override
  final StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? taskListener;
  @override
  final StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? sprintListener;
  @override
  final StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
  taskRecurrenceListener;
  @override
  final Map<String, StreamSubscription<QuerySnapshot<Map<String, dynamic>>>>?
  sprintAssignmentListeners;
  @override
  final bool tasksLoading;
  @override
  final bool sprintsLoading;
  @override
  final bool taskRecurrencesLoading;
  @override
  final bool isLoading;
  @override
  final bool loadFailed;
  @override
  final BuiltList<TaskItem> recentlyCompleted;
  @override
  final TopNavItem activeTab;
  @override
  final BuiltList<TopNavItem> allNavItems;
  @override
  final VisibilityFilter sprintListFilter;
  @override
  final VisibilityFilter taskListFilter;
  @override
  final String? personDocId;
  @override
  final GoogleSignIn googleSignIn;
  @override
  final bool googleInitialized;
  @override
  final UserCredential? firebaseUser;
  @override
  final GoogleSignInAccount? currentUser;
  @override
  final bool offlineMode;
  @override
  final TimezoneHelper timezoneHelper;
  @override
  final int nextId;
  @override
  final NotificationHelper notificationHelper;

  factory _$AppState([void Function(AppStateBuilder)? updates]) =>
      (AppStateBuilder()..update(updates))._build();

  _$AppState._({
    required this.taskItems,
    required this.sprints,
    required this.taskRecurrences,
    this.taskListener,
    this.sprintListener,
    this.taskRecurrenceListener,
    this.sprintAssignmentListeners,
    required this.tasksLoading,
    required this.sprintsLoading,
    required this.taskRecurrencesLoading,
    required this.isLoading,
    required this.loadFailed,
    required this.recentlyCompleted,
    required this.activeTab,
    required this.allNavItems,
    required this.sprintListFilter,
    required this.taskListFilter,
    this.personDocId,
    required this.googleSignIn,
    required this.googleInitialized,
    this.firebaseUser,
    this.currentUser,
    required this.offlineMode,
    required this.timezoneHelper,
    required this.nextId,
    required this.notificationHelper,
  }) : super._();
  @override
  AppState rebuild(void Function(AppStateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AppStateBuilder toBuilder() => AppStateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AppState &&
        taskItems == other.taskItems &&
        sprints == other.sprints &&
        taskRecurrences == other.taskRecurrences &&
        taskListener == other.taskListener &&
        sprintListener == other.sprintListener &&
        taskRecurrenceListener == other.taskRecurrenceListener &&
        sprintAssignmentListeners == other.sprintAssignmentListeners &&
        tasksLoading == other.tasksLoading &&
        sprintsLoading == other.sprintsLoading &&
        taskRecurrencesLoading == other.taskRecurrencesLoading &&
        isLoading == other.isLoading &&
        loadFailed == other.loadFailed &&
        recentlyCompleted == other.recentlyCompleted &&
        activeTab == other.activeTab &&
        allNavItems == other.allNavItems &&
        sprintListFilter == other.sprintListFilter &&
        taskListFilter == other.taskListFilter &&
        personDocId == other.personDocId &&
        googleSignIn == other.googleSignIn &&
        googleInitialized == other.googleInitialized &&
        firebaseUser == other.firebaseUser &&
        currentUser == other.currentUser &&
        offlineMode == other.offlineMode &&
        timezoneHelper == other.timezoneHelper &&
        nextId == other.nextId &&
        notificationHelper == other.notificationHelper;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, taskItems.hashCode);
    _$hash = $jc(_$hash, sprints.hashCode);
    _$hash = $jc(_$hash, taskRecurrences.hashCode);
    _$hash = $jc(_$hash, taskListener.hashCode);
    _$hash = $jc(_$hash, sprintListener.hashCode);
    _$hash = $jc(_$hash, taskRecurrenceListener.hashCode);
    _$hash = $jc(_$hash, sprintAssignmentListeners.hashCode);
    _$hash = $jc(_$hash, tasksLoading.hashCode);
    _$hash = $jc(_$hash, sprintsLoading.hashCode);
    _$hash = $jc(_$hash, taskRecurrencesLoading.hashCode);
    _$hash = $jc(_$hash, isLoading.hashCode);
    _$hash = $jc(_$hash, loadFailed.hashCode);
    _$hash = $jc(_$hash, recentlyCompleted.hashCode);
    _$hash = $jc(_$hash, activeTab.hashCode);
    _$hash = $jc(_$hash, allNavItems.hashCode);
    _$hash = $jc(_$hash, sprintListFilter.hashCode);
    _$hash = $jc(_$hash, taskListFilter.hashCode);
    _$hash = $jc(_$hash, personDocId.hashCode);
    _$hash = $jc(_$hash, googleSignIn.hashCode);
    _$hash = $jc(_$hash, googleInitialized.hashCode);
    _$hash = $jc(_$hash, firebaseUser.hashCode);
    _$hash = $jc(_$hash, currentUser.hashCode);
    _$hash = $jc(_$hash, offlineMode.hashCode);
    _$hash = $jc(_$hash, timezoneHelper.hashCode);
    _$hash = $jc(_$hash, nextId.hashCode);
    _$hash = $jc(_$hash, notificationHelper.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AppState')
          ..add('taskItems', taskItems)
          ..add('sprints', sprints)
          ..add('taskRecurrences', taskRecurrences)
          ..add('taskListener', taskListener)
          ..add('sprintListener', sprintListener)
          ..add('taskRecurrenceListener', taskRecurrenceListener)
          ..add('sprintAssignmentListeners', sprintAssignmentListeners)
          ..add('tasksLoading', tasksLoading)
          ..add('sprintsLoading', sprintsLoading)
          ..add('taskRecurrencesLoading', taskRecurrencesLoading)
          ..add('isLoading', isLoading)
          ..add('loadFailed', loadFailed)
          ..add('recentlyCompleted', recentlyCompleted)
          ..add('activeTab', activeTab)
          ..add('allNavItems', allNavItems)
          ..add('sprintListFilter', sprintListFilter)
          ..add('taskListFilter', taskListFilter)
          ..add('personDocId', personDocId)
          ..add('googleSignIn', googleSignIn)
          ..add('googleInitialized', googleInitialized)
          ..add('firebaseUser', firebaseUser)
          ..add('currentUser', currentUser)
          ..add('offlineMode', offlineMode)
          ..add('timezoneHelper', timezoneHelper)
          ..add('nextId', nextId)
          ..add('notificationHelper', notificationHelper))
        .toString();
  }
}

class AppStateBuilder implements Builder<AppState, AppStateBuilder> {
  _$AppState? _$v;

  ListBuilder<TaskItem>? _taskItems;
  ListBuilder<TaskItem> get taskItems =>
      _$this._taskItems ??= ListBuilder<TaskItem>();
  set taskItems(ListBuilder<TaskItem>? taskItems) =>
      _$this._taskItems = taskItems;

  ListBuilder<Sprint>? _sprints;
  ListBuilder<Sprint> get sprints => _$this._sprints ??= ListBuilder<Sprint>();
  set sprints(ListBuilder<Sprint>? sprints) => _$this._sprints = sprints;

  ListBuilder<TaskRecurrence>? _taskRecurrences;
  ListBuilder<TaskRecurrence> get taskRecurrences =>
      _$this._taskRecurrences ??= ListBuilder<TaskRecurrence>();
  set taskRecurrences(ListBuilder<TaskRecurrence>? taskRecurrences) =>
      _$this._taskRecurrences = taskRecurrences;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _taskListener;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? get taskListener =>
      _$this._taskListener;
  set taskListener(
    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? taskListener,
  ) => _$this._taskListener = taskListener;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sprintListener;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? get sprintListener =>
      _$this._sprintListener;
  set sprintListener(
    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? sprintListener,
  ) => _$this._sprintListener = sprintListener;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
  _taskRecurrenceListener;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
  get taskRecurrenceListener => _$this._taskRecurrenceListener;
  set taskRecurrenceListener(
    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
    taskRecurrenceListener,
  ) => _$this._taskRecurrenceListener = taskRecurrenceListener;

  Map<String, StreamSubscription<QuerySnapshot<Map<String, dynamic>>>>?
  _sprintAssignmentListeners;
  Map<String, StreamSubscription<QuerySnapshot<Map<String, dynamic>>>>?
  get sprintAssignmentListeners => _$this._sprintAssignmentListeners;
  set sprintAssignmentListeners(
    Map<String, StreamSubscription<QuerySnapshot<Map<String, dynamic>>>>?
    sprintAssignmentListeners,
  ) => _$this._sprintAssignmentListeners = sprintAssignmentListeners;

  bool? _tasksLoading;
  bool? get tasksLoading => _$this._tasksLoading;
  set tasksLoading(bool? tasksLoading) => _$this._tasksLoading = tasksLoading;

  bool? _sprintsLoading;
  bool? get sprintsLoading => _$this._sprintsLoading;
  set sprintsLoading(bool? sprintsLoading) =>
      _$this._sprintsLoading = sprintsLoading;

  bool? _taskRecurrencesLoading;
  bool? get taskRecurrencesLoading => _$this._taskRecurrencesLoading;
  set taskRecurrencesLoading(bool? taskRecurrencesLoading) =>
      _$this._taskRecurrencesLoading = taskRecurrencesLoading;

  bool? _isLoading;
  bool? get isLoading => _$this._isLoading;
  set isLoading(bool? isLoading) => _$this._isLoading = isLoading;

  bool? _loadFailed;
  bool? get loadFailed => _$this._loadFailed;
  set loadFailed(bool? loadFailed) => _$this._loadFailed = loadFailed;

  ListBuilder<TaskItem>? _recentlyCompleted;
  ListBuilder<TaskItem> get recentlyCompleted =>
      _$this._recentlyCompleted ??= ListBuilder<TaskItem>();
  set recentlyCompleted(ListBuilder<TaskItem>? recentlyCompleted) =>
      _$this._recentlyCompleted = recentlyCompleted;

  TopNavItemBuilder? _activeTab;
  TopNavItemBuilder get activeTab => _$this._activeTab ??= TopNavItemBuilder();
  set activeTab(TopNavItemBuilder? activeTab) => _$this._activeTab = activeTab;

  ListBuilder<TopNavItem>? _allNavItems;
  ListBuilder<TopNavItem> get allNavItems =>
      _$this._allNavItems ??= ListBuilder<TopNavItem>();
  set allNavItems(ListBuilder<TopNavItem>? allNavItems) =>
      _$this._allNavItems = allNavItems;

  VisibilityFilterBuilder? _sprintListFilter;
  VisibilityFilterBuilder get sprintListFilter =>
      _$this._sprintListFilter ??= VisibilityFilterBuilder();
  set sprintListFilter(VisibilityFilterBuilder? sprintListFilter) =>
      _$this._sprintListFilter = sprintListFilter;

  VisibilityFilterBuilder? _taskListFilter;
  VisibilityFilterBuilder get taskListFilter =>
      _$this._taskListFilter ??= VisibilityFilterBuilder();
  set taskListFilter(VisibilityFilterBuilder? taskListFilter) =>
      _$this._taskListFilter = taskListFilter;

  String? _personDocId;
  String? get personDocId => _$this._personDocId;
  set personDocId(String? personDocId) => _$this._personDocId = personDocId;

  GoogleSignIn? _googleSignIn;
  GoogleSignIn? get googleSignIn => _$this._googleSignIn;
  set googleSignIn(GoogleSignIn? googleSignIn) =>
      _$this._googleSignIn = googleSignIn;

  bool? _googleInitialized;
  bool? get googleInitialized => _$this._googleInitialized;
  set googleInitialized(bool? googleInitialized) =>
      _$this._googleInitialized = googleInitialized;

  UserCredential? _firebaseUser;
  UserCredential? get firebaseUser => _$this._firebaseUser;
  set firebaseUser(UserCredential? firebaseUser) =>
      _$this._firebaseUser = firebaseUser;

  GoogleSignInAccount? _currentUser;
  GoogleSignInAccount? get currentUser => _$this._currentUser;
  set currentUser(GoogleSignInAccount? currentUser) =>
      _$this._currentUser = currentUser;

  bool? _offlineMode;
  bool? get offlineMode => _$this._offlineMode;
  set offlineMode(bool? offlineMode) => _$this._offlineMode = offlineMode;

  TimezoneHelper? _timezoneHelper;
  TimezoneHelper? get timezoneHelper => _$this._timezoneHelper;
  set timezoneHelper(TimezoneHelper? timezoneHelper) =>
      _$this._timezoneHelper = timezoneHelper;

  int? _nextId;
  int? get nextId => _$this._nextId;
  set nextId(int? nextId) => _$this._nextId = nextId;

  NotificationHelper? _notificationHelper;
  NotificationHelper? get notificationHelper => _$this._notificationHelper;
  set notificationHelper(NotificationHelper? notificationHelper) =>
      _$this._notificationHelper = notificationHelper;

  AppStateBuilder();

  AppStateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _taskItems = $v.taskItems.toBuilder();
      _sprints = $v.sprints.toBuilder();
      _taskRecurrences = $v.taskRecurrences.toBuilder();
      _taskListener = $v.taskListener;
      _sprintListener = $v.sprintListener;
      _taskRecurrenceListener = $v.taskRecurrenceListener;
      _sprintAssignmentListeners = $v.sprintAssignmentListeners;
      _tasksLoading = $v.tasksLoading;
      _sprintsLoading = $v.sprintsLoading;
      _taskRecurrencesLoading = $v.taskRecurrencesLoading;
      _isLoading = $v.isLoading;
      _loadFailed = $v.loadFailed;
      _recentlyCompleted = $v.recentlyCompleted.toBuilder();
      _activeTab = $v.activeTab.toBuilder();
      _allNavItems = $v.allNavItems.toBuilder();
      _sprintListFilter = $v.sprintListFilter.toBuilder();
      _taskListFilter = $v.taskListFilter.toBuilder();
      _personDocId = $v.personDocId;
      _googleSignIn = $v.googleSignIn;
      _googleInitialized = $v.googleInitialized;
      _firebaseUser = $v.firebaseUser;
      _currentUser = $v.currentUser;
      _offlineMode = $v.offlineMode;
      _timezoneHelper = $v.timezoneHelper;
      _nextId = $v.nextId;
      _notificationHelper = $v.notificationHelper;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AppState other) {
    _$v = other as _$AppState;
  }

  @override
  void update(void Function(AppStateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AppState build() => _build();

  _$AppState _build() {
    _$AppState _$result;
    try {
      _$result =
          _$v ??
          _$AppState._(
            taskItems: taskItems.build(),
            sprints: sprints.build(),
            taskRecurrences: taskRecurrences.build(),
            taskListener: taskListener,
            sprintListener: sprintListener,
            taskRecurrenceListener: taskRecurrenceListener,
            sprintAssignmentListeners: sprintAssignmentListeners,
            tasksLoading: BuiltValueNullFieldError.checkNotNull(
              tasksLoading,
              r'AppState',
              'tasksLoading',
            ),
            sprintsLoading: BuiltValueNullFieldError.checkNotNull(
              sprintsLoading,
              r'AppState',
              'sprintsLoading',
            ),
            taskRecurrencesLoading: BuiltValueNullFieldError.checkNotNull(
              taskRecurrencesLoading,
              r'AppState',
              'taskRecurrencesLoading',
            ),
            isLoading: BuiltValueNullFieldError.checkNotNull(
              isLoading,
              r'AppState',
              'isLoading',
            ),
            loadFailed: BuiltValueNullFieldError.checkNotNull(
              loadFailed,
              r'AppState',
              'loadFailed',
            ),
            recentlyCompleted: recentlyCompleted.build(),
            activeTab: activeTab.build(),
            allNavItems: allNavItems.build(),
            sprintListFilter: sprintListFilter.build(),
            taskListFilter: taskListFilter.build(),
            personDocId: personDocId,
            googleSignIn: BuiltValueNullFieldError.checkNotNull(
              googleSignIn,
              r'AppState',
              'googleSignIn',
            ),
            googleInitialized: BuiltValueNullFieldError.checkNotNull(
              googleInitialized,
              r'AppState',
              'googleInitialized',
            ),
            firebaseUser: firebaseUser,
            currentUser: currentUser,
            offlineMode: BuiltValueNullFieldError.checkNotNull(
              offlineMode,
              r'AppState',
              'offlineMode',
            ),
            timezoneHelper: BuiltValueNullFieldError.checkNotNull(
              timezoneHelper,
              r'AppState',
              'timezoneHelper',
            ),
            nextId: BuiltValueNullFieldError.checkNotNull(
              nextId,
              r'AppState',
              'nextId',
            ),
            notificationHelper: BuiltValueNullFieldError.checkNotNull(
              notificationHelper,
              r'AppState',
              'notificationHelper',
            ),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'taskItems';
        taskItems.build();
        _$failedField = 'sprints';
        sprints.build();
        _$failedField = 'taskRecurrences';
        taskRecurrences.build();

        _$failedField = 'recentlyCompleted';
        recentlyCompleted.build();
        _$failedField = 'activeTab';
        activeTab.build();
        _$failedField = 'allNavItems';
        allNavItems.build();
        _$failedField = 'sprintListFilter';
        sprintListFilter.build();
        _$failedField = 'taskListFilter';
        taskListFilter.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'AppState',
          _$failedField,
          e.toString(),
        );
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
