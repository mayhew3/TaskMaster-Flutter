// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_screen_viewmodel.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$HomeScreenViewModel extends HomeScreenViewModel {
  @override
  final TopNavItem activeTab;
  @override
  final bool tasksLoading;
  @override
  final bool sprintsLoading;
  @override
  final bool taskRecurrencesLoading;
  @override
  final GoogleSignInAccount? currentUser;
  @override
  final UserCredential? firebaseUser;
  @override
  final String? personDocId;
  @override
  final TimezoneHelper timezoneHelper;

  factory _$HomeScreenViewModel(
          [void Function(HomeScreenViewModelBuilder)? updates]) =>
      (new HomeScreenViewModelBuilder()..update(updates))._build();

  _$HomeScreenViewModel._(
      {required this.activeTab,
      required this.tasksLoading,
      required this.sprintsLoading,
      required this.taskRecurrencesLoading,
      this.currentUser,
      this.firebaseUser,
      this.personDocId,
      required this.timezoneHelper})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(
        activeTab, r'HomeScreenViewModel', 'activeTab');
    BuiltValueNullFieldError.checkNotNull(
        tasksLoading, r'HomeScreenViewModel', 'tasksLoading');
    BuiltValueNullFieldError.checkNotNull(
        sprintsLoading, r'HomeScreenViewModel', 'sprintsLoading');
    BuiltValueNullFieldError.checkNotNull(taskRecurrencesLoading,
        r'HomeScreenViewModel', 'taskRecurrencesLoading');
    BuiltValueNullFieldError.checkNotNull(
        timezoneHelper, r'HomeScreenViewModel', 'timezoneHelper');
  }

  @override
  HomeScreenViewModel rebuild(
          void Function(HomeScreenViewModelBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  HomeScreenViewModelBuilder toBuilder() =>
      new HomeScreenViewModelBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is HomeScreenViewModel &&
        activeTab == other.activeTab &&
        tasksLoading == other.tasksLoading &&
        sprintsLoading == other.sprintsLoading &&
        taskRecurrencesLoading == other.taskRecurrencesLoading &&
        currentUser == other.currentUser &&
        firebaseUser == other.firebaseUser &&
        personDocId == other.personDocId &&
        timezoneHelper == other.timezoneHelper;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, activeTab.hashCode);
    _$hash = $jc(_$hash, tasksLoading.hashCode);
    _$hash = $jc(_$hash, sprintsLoading.hashCode);
    _$hash = $jc(_$hash, taskRecurrencesLoading.hashCode);
    _$hash = $jc(_$hash, currentUser.hashCode);
    _$hash = $jc(_$hash, firebaseUser.hashCode);
    _$hash = $jc(_$hash, personDocId.hashCode);
    _$hash = $jc(_$hash, timezoneHelper.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'HomeScreenViewModel')
          ..add('activeTab', activeTab)
          ..add('tasksLoading', tasksLoading)
          ..add('sprintsLoading', sprintsLoading)
          ..add('taskRecurrencesLoading', taskRecurrencesLoading)
          ..add('currentUser', currentUser)
          ..add('firebaseUser', firebaseUser)
          ..add('personDocId', personDocId)
          ..add('timezoneHelper', timezoneHelper))
        .toString();
  }
}

class HomeScreenViewModelBuilder
    implements Builder<HomeScreenViewModel, HomeScreenViewModelBuilder> {
  _$HomeScreenViewModel? _$v;

  TopNavItemBuilder? _activeTab;
  TopNavItemBuilder get activeTab =>
      _$this._activeTab ??= new TopNavItemBuilder();
  set activeTab(TopNavItemBuilder? activeTab) => _$this._activeTab = activeTab;

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

  GoogleSignInAccount? _currentUser;
  GoogleSignInAccount? get currentUser => _$this._currentUser;
  set currentUser(GoogleSignInAccount? currentUser) =>
      _$this._currentUser = currentUser;

  UserCredential? _firebaseUser;
  UserCredential? get firebaseUser => _$this._firebaseUser;
  set firebaseUser(UserCredential? firebaseUser) =>
      _$this._firebaseUser = firebaseUser;

  String? _personDocId;
  String? get personDocId => _$this._personDocId;
  set personDocId(String? personDocId) => _$this._personDocId = personDocId;

  TimezoneHelper? _timezoneHelper;
  TimezoneHelper? get timezoneHelper => _$this._timezoneHelper;
  set timezoneHelper(TimezoneHelper? timezoneHelper) =>
      _$this._timezoneHelper = timezoneHelper;

  HomeScreenViewModelBuilder();

  HomeScreenViewModelBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _activeTab = $v.activeTab.toBuilder();
      _tasksLoading = $v.tasksLoading;
      _sprintsLoading = $v.sprintsLoading;
      _taskRecurrencesLoading = $v.taskRecurrencesLoading;
      _currentUser = $v.currentUser;
      _firebaseUser = $v.firebaseUser;
      _personDocId = $v.personDocId;
      _timezoneHelper = $v.timezoneHelper;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(HomeScreenViewModel other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$HomeScreenViewModel;
  }

  @override
  void update(void Function(HomeScreenViewModelBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  HomeScreenViewModel build() => _build();

  _$HomeScreenViewModel _build() {
    _$HomeScreenViewModel _$result;
    try {
      _$result = _$v ??
          new _$HomeScreenViewModel._(
              activeTab: activeTab.build(),
              tasksLoading: BuiltValueNullFieldError.checkNotNull(
                  tasksLoading, r'HomeScreenViewModel', 'tasksLoading'),
              sprintsLoading: BuiltValueNullFieldError.checkNotNull(
                  sprintsLoading, r'HomeScreenViewModel', 'sprintsLoading'),
              taskRecurrencesLoading: BuiltValueNullFieldError.checkNotNull(
                  taskRecurrencesLoading,
                  r'HomeScreenViewModel',
                  'taskRecurrencesLoading'),
              currentUser: currentUser,
              firebaseUser: firebaseUser,
              personDocId: personDocId,
              timezoneHelper: BuiltValueNullFieldError.checkNotNull(
                  timezoneHelper, r'HomeScreenViewModel', 'timezoneHelper'));
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'activeTab';
        activeTab.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            r'HomeScreenViewModel', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
