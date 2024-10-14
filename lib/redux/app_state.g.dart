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
  final UserCredential? firebaseUser;
  @override
  final GoogleSignInAccount? currentUser;
  @override
  final bool tokenRetrieved;
  @override
  final bool offlineMode;
  @override
  final TimezoneHelper timezoneHelper;
  @override
  final int nextId;
  @override
  final NotificationHelper notificationHelper;

  factory _$AppState([void Function(AppStateBuilder)? updates]) =>
      (new AppStateBuilder()..update(updates))._build();

  _$AppState._(
      {required this.taskItems,
      required this.sprints,
      required this.taskRecurrences,
      required this.isLoading,
      required this.loadFailed,
      required this.recentlyCompleted,
      required this.activeTab,
      required this.allNavItems,
      required this.sprintListFilter,
      required this.taskListFilter,
      this.personDocId,
      required this.googleSignIn,
      this.firebaseUser,
      this.currentUser,
      required this.tokenRetrieved,
      required this.offlineMode,
      required this.timezoneHelper,
      required this.nextId,
      required this.notificationHelper})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(taskItems, r'AppState', 'taskItems');
    BuiltValueNullFieldError.checkNotNull(sprints, r'AppState', 'sprints');
    BuiltValueNullFieldError.checkNotNull(
        taskRecurrences, r'AppState', 'taskRecurrences');
    BuiltValueNullFieldError.checkNotNull(isLoading, r'AppState', 'isLoading');
    BuiltValueNullFieldError.checkNotNull(
        loadFailed, r'AppState', 'loadFailed');
    BuiltValueNullFieldError.checkNotNull(
        recentlyCompleted, r'AppState', 'recentlyCompleted');
    BuiltValueNullFieldError.checkNotNull(activeTab, r'AppState', 'activeTab');
    BuiltValueNullFieldError.checkNotNull(
        allNavItems, r'AppState', 'allNavItems');
    BuiltValueNullFieldError.checkNotNull(
        sprintListFilter, r'AppState', 'sprintListFilter');
    BuiltValueNullFieldError.checkNotNull(
        taskListFilter, r'AppState', 'taskListFilter');
    BuiltValueNullFieldError.checkNotNull(
        googleSignIn, r'AppState', 'googleSignIn');
    BuiltValueNullFieldError.checkNotNull(
        tokenRetrieved, r'AppState', 'tokenRetrieved');
    BuiltValueNullFieldError.checkNotNull(
        offlineMode, r'AppState', 'offlineMode');
    BuiltValueNullFieldError.checkNotNull(
        timezoneHelper, r'AppState', 'timezoneHelper');
    BuiltValueNullFieldError.checkNotNull(nextId, r'AppState', 'nextId');
    BuiltValueNullFieldError.checkNotNull(
        notificationHelper, r'AppState', 'notificationHelper');
  }

  @override
  AppState rebuild(void Function(AppStateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AppStateBuilder toBuilder() => new AppStateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AppState &&
        taskItems == other.taskItems &&
        sprints == other.sprints &&
        taskRecurrences == other.taskRecurrences &&
        isLoading == other.isLoading &&
        loadFailed == other.loadFailed &&
        recentlyCompleted == other.recentlyCompleted &&
        activeTab == other.activeTab &&
        allNavItems == other.allNavItems &&
        sprintListFilter == other.sprintListFilter &&
        taskListFilter == other.taskListFilter &&
        personDocId == other.personDocId &&
        googleSignIn == other.googleSignIn &&
        firebaseUser == other.firebaseUser &&
        currentUser == other.currentUser &&
        tokenRetrieved == other.tokenRetrieved &&
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
    _$hash = $jc(_$hash, isLoading.hashCode);
    _$hash = $jc(_$hash, loadFailed.hashCode);
    _$hash = $jc(_$hash, recentlyCompleted.hashCode);
    _$hash = $jc(_$hash, activeTab.hashCode);
    _$hash = $jc(_$hash, allNavItems.hashCode);
    _$hash = $jc(_$hash, sprintListFilter.hashCode);
    _$hash = $jc(_$hash, taskListFilter.hashCode);
    _$hash = $jc(_$hash, personDocId.hashCode);
    _$hash = $jc(_$hash, googleSignIn.hashCode);
    _$hash = $jc(_$hash, firebaseUser.hashCode);
    _$hash = $jc(_$hash, currentUser.hashCode);
    _$hash = $jc(_$hash, tokenRetrieved.hashCode);
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
          ..add('isLoading', isLoading)
          ..add('loadFailed', loadFailed)
          ..add('recentlyCompleted', recentlyCompleted)
          ..add('activeTab', activeTab)
          ..add('allNavItems', allNavItems)
          ..add('sprintListFilter', sprintListFilter)
          ..add('taskListFilter', taskListFilter)
          ..add('personDocId', personDocId)
          ..add('googleSignIn', googleSignIn)
          ..add('firebaseUser', firebaseUser)
          ..add('currentUser', currentUser)
          ..add('tokenRetrieved', tokenRetrieved)
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
      _$this._taskItems ??= new ListBuilder<TaskItem>();
  set taskItems(ListBuilder<TaskItem>? taskItems) =>
      _$this._taskItems = taskItems;

  ListBuilder<Sprint>? _sprints;
  ListBuilder<Sprint> get sprints =>
      _$this._sprints ??= new ListBuilder<Sprint>();
  set sprints(ListBuilder<Sprint>? sprints) => _$this._sprints = sprints;

  ListBuilder<TaskRecurrence>? _taskRecurrences;
  ListBuilder<TaskRecurrence> get taskRecurrences =>
      _$this._taskRecurrences ??= new ListBuilder<TaskRecurrence>();
  set taskRecurrences(ListBuilder<TaskRecurrence>? taskRecurrences) =>
      _$this._taskRecurrences = taskRecurrences;

  bool? _isLoading;
  bool? get isLoading => _$this._isLoading;
  set isLoading(bool? isLoading) => _$this._isLoading = isLoading;

  bool? _loadFailed;
  bool? get loadFailed => _$this._loadFailed;
  set loadFailed(bool? loadFailed) => _$this._loadFailed = loadFailed;

  ListBuilder<TaskItem>? _recentlyCompleted;
  ListBuilder<TaskItem> get recentlyCompleted =>
      _$this._recentlyCompleted ??= new ListBuilder<TaskItem>();
  set recentlyCompleted(ListBuilder<TaskItem>? recentlyCompleted) =>
      _$this._recentlyCompleted = recentlyCompleted;

  TopNavItemBuilder? _activeTab;
  TopNavItemBuilder get activeTab =>
      _$this._activeTab ??= new TopNavItemBuilder();
  set activeTab(TopNavItemBuilder? activeTab) => _$this._activeTab = activeTab;

  ListBuilder<TopNavItem>? _allNavItems;
  ListBuilder<TopNavItem> get allNavItems =>
      _$this._allNavItems ??= new ListBuilder<TopNavItem>();
  set allNavItems(ListBuilder<TopNavItem>? allNavItems) =>
      _$this._allNavItems = allNavItems;

  VisibilityFilterBuilder? _sprintListFilter;
  VisibilityFilterBuilder get sprintListFilter =>
      _$this._sprintListFilter ??= new VisibilityFilterBuilder();
  set sprintListFilter(VisibilityFilterBuilder? sprintListFilter) =>
      _$this._sprintListFilter = sprintListFilter;

  VisibilityFilterBuilder? _taskListFilter;
  VisibilityFilterBuilder get taskListFilter =>
      _$this._taskListFilter ??= new VisibilityFilterBuilder();
  set taskListFilter(VisibilityFilterBuilder? taskListFilter) =>
      _$this._taskListFilter = taskListFilter;

  String? _personDocId;
  String? get personDocId => _$this._personDocId;
  set personDocId(String? personDocId) => _$this._personDocId = personDocId;

  GoogleSignIn? _googleSignIn;
  GoogleSignIn? get googleSignIn => _$this._googleSignIn;
  set googleSignIn(GoogleSignIn? googleSignIn) =>
      _$this._googleSignIn = googleSignIn;

  UserCredential? _firebaseUser;
  UserCredential? get firebaseUser => _$this._firebaseUser;
  set firebaseUser(UserCredential? firebaseUser) =>
      _$this._firebaseUser = firebaseUser;

  GoogleSignInAccount? _currentUser;
  GoogleSignInAccount? get currentUser => _$this._currentUser;
  set currentUser(GoogleSignInAccount? currentUser) =>
      _$this._currentUser = currentUser;

  bool? _tokenRetrieved;
  bool? get tokenRetrieved => _$this._tokenRetrieved;
  set tokenRetrieved(bool? tokenRetrieved) =>
      _$this._tokenRetrieved = tokenRetrieved;

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
      _isLoading = $v.isLoading;
      _loadFailed = $v.loadFailed;
      _recentlyCompleted = $v.recentlyCompleted.toBuilder();
      _activeTab = $v.activeTab.toBuilder();
      _allNavItems = $v.allNavItems.toBuilder();
      _sprintListFilter = $v.sprintListFilter.toBuilder();
      _taskListFilter = $v.taskListFilter.toBuilder();
      _personDocId = $v.personDocId;
      _googleSignIn = $v.googleSignIn;
      _firebaseUser = $v.firebaseUser;
      _currentUser = $v.currentUser;
      _tokenRetrieved = $v.tokenRetrieved;
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
    ArgumentError.checkNotNull(other, 'other');
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
      _$result = _$v ??
          new _$AppState._(
              taskItems: taskItems.build(),
              sprints: sprints.build(),
              taskRecurrences: taskRecurrences.build(),
              isLoading: BuiltValueNullFieldError.checkNotNull(
                  isLoading, r'AppState', 'isLoading'),
              loadFailed: BuiltValueNullFieldError.checkNotNull(
                  loadFailed, r'AppState', 'loadFailed'),
              recentlyCompleted: recentlyCompleted.build(),
              activeTab: activeTab.build(),
              allNavItems: allNavItems.build(),
              sprintListFilter: sprintListFilter.build(),
              taskListFilter: taskListFilter.build(),
              personDocId: personDocId,
              googleSignIn: BuiltValueNullFieldError.checkNotNull(
                  googleSignIn, r'AppState', 'googleSignIn'),
              firebaseUser: firebaseUser,
              currentUser: currentUser,
              tokenRetrieved: BuiltValueNullFieldError.checkNotNull(
                  tokenRetrieved, r'AppState', 'tokenRetrieved'),
              offlineMode: BuiltValueNullFieldError.checkNotNull(
                  offlineMode, r'AppState', 'offlineMode'),
              timezoneHelper: BuiltValueNullFieldError.checkNotNull(
                  timezoneHelper, r'AppState', 'timezoneHelper'),
              nextId: BuiltValueNullFieldError.checkNotNull(
                  nextId, r'AppState', 'nextId'),
              notificationHelper: BuiltValueNullFieldError.checkNotNull(
                  notificationHelper, r'AppState', 'notificationHelper'));
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
        throw new BuiltValueNestedFieldError(
            r'AppState', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
