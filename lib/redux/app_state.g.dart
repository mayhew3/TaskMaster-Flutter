// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_state.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AppState extends AppState {
  @override
  final bool isLoading;
  @override
  final bool loadFailed;
  @override
  final BuiltList<TaskItem> taskItems;
  @override
  final BuiltList<Sprint> sprints;
  @override
  final BuiltList<TaskRecurrence> taskRecurrences;
  @override
  final AppTab activeTab;
  @override
  final VisibilityFilter sprintListFilter;
  @override
  final VisibilityFilter taskListFilter;
  @override
  final GoogleSignIn googleSignIn;
  @override
  final UserCredential? firebaseUser;
  @override
  final GoogleSignInAccount? currentUser;
  @override
  final bool tokenRetrieved;

  factory _$AppState([void Function(AppStateBuilder)? updates]) =>
      (new AppStateBuilder()..update(updates))._build();

  _$AppState._(
      {required this.isLoading,
      required this.loadFailed,
      required this.taskItems,
      required this.sprints,
      required this.taskRecurrences,
      required this.activeTab,
      required this.sprintListFilter,
      required this.taskListFilter,
      required this.googleSignIn,
      this.firebaseUser,
      this.currentUser,
      required this.tokenRetrieved})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(isLoading, r'AppState', 'isLoading');
    BuiltValueNullFieldError.checkNotNull(
        loadFailed, r'AppState', 'loadFailed');
    BuiltValueNullFieldError.checkNotNull(taskItems, r'AppState', 'taskItems');
    BuiltValueNullFieldError.checkNotNull(sprints, r'AppState', 'sprints');
    BuiltValueNullFieldError.checkNotNull(
        taskRecurrences, r'AppState', 'taskRecurrences');
    BuiltValueNullFieldError.checkNotNull(activeTab, r'AppState', 'activeTab');
    BuiltValueNullFieldError.checkNotNull(
        sprintListFilter, r'AppState', 'sprintListFilter');
    BuiltValueNullFieldError.checkNotNull(
        taskListFilter, r'AppState', 'taskListFilter');
    BuiltValueNullFieldError.checkNotNull(
        googleSignIn, r'AppState', 'googleSignIn');
    BuiltValueNullFieldError.checkNotNull(
        tokenRetrieved, r'AppState', 'tokenRetrieved');
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
        isLoading == other.isLoading &&
        loadFailed == other.loadFailed &&
        taskItems == other.taskItems &&
        sprints == other.sprints &&
        taskRecurrences == other.taskRecurrences &&
        activeTab == other.activeTab &&
        sprintListFilter == other.sprintListFilter &&
        taskListFilter == other.taskListFilter &&
        googleSignIn == other.googleSignIn &&
        firebaseUser == other.firebaseUser &&
        currentUser == other.currentUser &&
        tokenRetrieved == other.tokenRetrieved;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, isLoading.hashCode);
    _$hash = $jc(_$hash, loadFailed.hashCode);
    _$hash = $jc(_$hash, taskItems.hashCode);
    _$hash = $jc(_$hash, sprints.hashCode);
    _$hash = $jc(_$hash, taskRecurrences.hashCode);
    _$hash = $jc(_$hash, activeTab.hashCode);
    _$hash = $jc(_$hash, sprintListFilter.hashCode);
    _$hash = $jc(_$hash, taskListFilter.hashCode);
    _$hash = $jc(_$hash, googleSignIn.hashCode);
    _$hash = $jc(_$hash, firebaseUser.hashCode);
    _$hash = $jc(_$hash, currentUser.hashCode);
    _$hash = $jc(_$hash, tokenRetrieved.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AppState')
          ..add('isLoading', isLoading)
          ..add('loadFailed', loadFailed)
          ..add('taskItems', taskItems)
          ..add('sprints', sprints)
          ..add('taskRecurrences', taskRecurrences)
          ..add('activeTab', activeTab)
          ..add('sprintListFilter', sprintListFilter)
          ..add('taskListFilter', taskListFilter)
          ..add('googleSignIn', googleSignIn)
          ..add('firebaseUser', firebaseUser)
          ..add('currentUser', currentUser)
          ..add('tokenRetrieved', tokenRetrieved))
        .toString();
  }
}

class AppStateBuilder implements Builder<AppState, AppStateBuilder> {
  _$AppState? _$v;

  bool? _isLoading;
  bool? get isLoading => _$this._isLoading;
  set isLoading(bool? isLoading) => _$this._isLoading = isLoading;

  bool? _loadFailed;
  bool? get loadFailed => _$this._loadFailed;
  set loadFailed(bool? loadFailed) => _$this._loadFailed = loadFailed;

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

  AppTab? _activeTab;
  AppTab? get activeTab => _$this._activeTab;
  set activeTab(AppTab? activeTab) => _$this._activeTab = activeTab;

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

  AppStateBuilder();

  AppStateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _isLoading = $v.isLoading;
      _loadFailed = $v.loadFailed;
      _taskItems = $v.taskItems.toBuilder();
      _sprints = $v.sprints.toBuilder();
      _taskRecurrences = $v.taskRecurrences.toBuilder();
      _activeTab = $v.activeTab;
      _sprintListFilter = $v.sprintListFilter.toBuilder();
      _taskListFilter = $v.taskListFilter.toBuilder();
      _googleSignIn = $v.googleSignIn;
      _firebaseUser = $v.firebaseUser;
      _currentUser = $v.currentUser;
      _tokenRetrieved = $v.tokenRetrieved;
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
              isLoading: BuiltValueNullFieldError.checkNotNull(
                  isLoading, r'AppState', 'isLoading'),
              loadFailed: BuiltValueNullFieldError.checkNotNull(
                  loadFailed, r'AppState', 'loadFailed'),
              taskItems: taskItems.build(),
              sprints: sprints.build(),
              taskRecurrences: taskRecurrences.build(),
              activeTab: BuiltValueNullFieldError.checkNotNull(
                  activeTab, r'AppState', 'activeTab'),
              sprintListFilter: sprintListFilter.build(),
              taskListFilter: taskListFilter.build(),
              googleSignIn: BuiltValueNullFieldError.checkNotNull(
                  googleSignIn, r'AppState', 'googleSignIn'),
              firebaseUser: firebaseUser,
              currentUser: currentUser,
              tokenRetrieved: BuiltValueNullFieldError.checkNotNull(
                  tokenRetrieved, r'AppState', 'tokenRetrieved'));
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'taskItems';
        taskItems.build();
        _$failedField = 'sprints';
        sprints.build();
        _$failedField = 'taskRecurrences';
        taskRecurrences.build();

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
