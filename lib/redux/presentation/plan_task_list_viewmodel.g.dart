// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plan_task_list_viewmodel.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PlanTaskListViewModel extends PlanTaskListViewModel {
  @override
  final BuiltList<TaskItem> allTaskItems;
  @override
  final BuiltList<Sprint> allSprints;
  @override
  final BuiltList<TaskItem> recentlyCompleted;
  @override
  final Sprint? lastSprint;
  @override
  final Sprint? activeSprint;
  @override
  final String personDocId;

  factory _$PlanTaskListViewModel(
          [void Function(PlanTaskListViewModelBuilder)? updates]) =>
      (new PlanTaskListViewModelBuilder()..update(updates))._build();

  _$PlanTaskListViewModel._(
      {required this.allTaskItems,
      required this.allSprints,
      required this.recentlyCompleted,
      this.lastSprint,
      this.activeSprint,
      required this.personDocId})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(
        allTaskItems, r'PlanTaskListViewModel', 'allTaskItems');
    BuiltValueNullFieldError.checkNotNull(
        allSprints, r'PlanTaskListViewModel', 'allSprints');
    BuiltValueNullFieldError.checkNotNull(
        recentlyCompleted, r'PlanTaskListViewModel', 'recentlyCompleted');
    BuiltValueNullFieldError.checkNotNull(
        personDocId, r'PlanTaskListViewModel', 'personDocId');
  }

  @override
  PlanTaskListViewModel rebuild(
          void Function(PlanTaskListViewModelBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PlanTaskListViewModelBuilder toBuilder() =>
      new PlanTaskListViewModelBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PlanTaskListViewModel &&
        allTaskItems == other.allTaskItems &&
        allSprints == other.allSprints &&
        recentlyCompleted == other.recentlyCompleted &&
        lastSprint == other.lastSprint &&
        activeSprint == other.activeSprint &&
        personDocId == other.personDocId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, allTaskItems.hashCode);
    _$hash = $jc(_$hash, allSprints.hashCode);
    _$hash = $jc(_$hash, recentlyCompleted.hashCode);
    _$hash = $jc(_$hash, lastSprint.hashCode);
    _$hash = $jc(_$hash, activeSprint.hashCode);
    _$hash = $jc(_$hash, personDocId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PlanTaskListViewModel')
          ..add('allTaskItems', allTaskItems)
          ..add('allSprints', allSprints)
          ..add('recentlyCompleted', recentlyCompleted)
          ..add('lastSprint', lastSprint)
          ..add('activeSprint', activeSprint)
          ..add('personDocId', personDocId))
        .toString();
  }
}

class PlanTaskListViewModelBuilder
    implements Builder<PlanTaskListViewModel, PlanTaskListViewModelBuilder> {
  _$PlanTaskListViewModel? _$v;

  ListBuilder<TaskItem>? _allTaskItems;
  ListBuilder<TaskItem> get allTaskItems =>
      _$this._allTaskItems ??= new ListBuilder<TaskItem>();
  set allTaskItems(ListBuilder<TaskItem>? allTaskItems) =>
      _$this._allTaskItems = allTaskItems;

  ListBuilder<Sprint>? _allSprints;
  ListBuilder<Sprint> get allSprints =>
      _$this._allSprints ??= new ListBuilder<Sprint>();
  set allSprints(ListBuilder<Sprint>? allSprints) =>
      _$this._allSprints = allSprints;

  ListBuilder<TaskItem>? _recentlyCompleted;
  ListBuilder<TaskItem> get recentlyCompleted =>
      _$this._recentlyCompleted ??= new ListBuilder<TaskItem>();
  set recentlyCompleted(ListBuilder<TaskItem>? recentlyCompleted) =>
      _$this._recentlyCompleted = recentlyCompleted;

  SprintBuilder? _lastSprint;
  SprintBuilder get lastSprint => _$this._lastSprint ??= new SprintBuilder();
  set lastSprint(SprintBuilder? lastSprint) => _$this._lastSprint = lastSprint;

  SprintBuilder? _activeSprint;
  SprintBuilder get activeSprint =>
      _$this._activeSprint ??= new SprintBuilder();
  set activeSprint(SprintBuilder? activeSprint) =>
      _$this._activeSprint = activeSprint;

  String? _personDocId;
  String? get personDocId => _$this._personDocId;
  set personDocId(String? personDocId) => _$this._personDocId = personDocId;

  PlanTaskListViewModelBuilder();

  PlanTaskListViewModelBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _allTaskItems = $v.allTaskItems.toBuilder();
      _allSprints = $v.allSprints.toBuilder();
      _recentlyCompleted = $v.recentlyCompleted.toBuilder();
      _lastSprint = $v.lastSprint?.toBuilder();
      _activeSprint = $v.activeSprint?.toBuilder();
      _personDocId = $v.personDocId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PlanTaskListViewModel other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$PlanTaskListViewModel;
  }

  @override
  void update(void Function(PlanTaskListViewModelBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PlanTaskListViewModel build() => _build();

  _$PlanTaskListViewModel _build() {
    _$PlanTaskListViewModel _$result;
    try {
      _$result = _$v ??
          new _$PlanTaskListViewModel._(
              allTaskItems: allTaskItems.build(),
              allSprints: allSprints.build(),
              recentlyCompleted: recentlyCompleted.build(),
              lastSprint: _lastSprint?.build(),
              activeSprint: _activeSprint?.build(),
              personDocId: BuiltValueNullFieldError.checkNotNull(
                  personDocId, r'PlanTaskListViewModel', 'personDocId'));
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'allTaskItems';
        allTaskItems.build();
        _$failedField = 'allSprints';
        allSprints.build();
        _$failedField = 'recentlyCompleted';
        recentlyCompleted.build();
        _$failedField = 'lastSprint';
        _lastSprint?.build();
        _$failedField = 'activeSprint';
        _activeSprint?.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            r'PlanTaskListViewModel', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
