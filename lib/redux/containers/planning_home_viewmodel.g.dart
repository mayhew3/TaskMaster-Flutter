// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'planning_home_viewmodel.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PlanningHomeViewModel extends PlanningHomeViewModel {
  @override
  final Sprint? activeSprint;
  @override
  final bool isLoading;
  @override
  final bool loadFailed;

  factory _$PlanningHomeViewModel(
          [void Function(PlanningHomeViewModelBuilder)? updates]) =>
      (new PlanningHomeViewModelBuilder()..update(updates))._build();

  _$PlanningHomeViewModel._(
      {this.activeSprint, required this.isLoading, required this.loadFailed})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(
        isLoading, r'PlanningHomeViewModel', 'isLoading');
    BuiltValueNullFieldError.checkNotNull(
        loadFailed, r'PlanningHomeViewModel', 'loadFailed');
  }

  @override
  PlanningHomeViewModel rebuild(
          void Function(PlanningHomeViewModelBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PlanningHomeViewModelBuilder toBuilder() =>
      new PlanningHomeViewModelBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PlanningHomeViewModel &&
        activeSprint == other.activeSprint &&
        isLoading == other.isLoading &&
        loadFailed == other.loadFailed;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, activeSprint.hashCode);
    _$hash = $jc(_$hash, isLoading.hashCode);
    _$hash = $jc(_$hash, loadFailed.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PlanningHomeViewModel')
          ..add('activeSprint', activeSprint)
          ..add('isLoading', isLoading)
          ..add('loadFailed', loadFailed))
        .toString();
  }
}

class PlanningHomeViewModelBuilder
    implements Builder<PlanningHomeViewModel, PlanningHomeViewModelBuilder> {
  _$PlanningHomeViewModel? _$v;

  SprintBuilder? _activeSprint;
  SprintBuilder get activeSprint =>
      _$this._activeSprint ??= new SprintBuilder();
  set activeSprint(SprintBuilder? activeSprint) =>
      _$this._activeSprint = activeSprint;

  bool? _isLoading;
  bool? get isLoading => _$this._isLoading;
  set isLoading(bool? isLoading) => _$this._isLoading = isLoading;

  bool? _loadFailed;
  bool? get loadFailed => _$this._loadFailed;
  set loadFailed(bool? loadFailed) => _$this._loadFailed = loadFailed;

  PlanningHomeViewModelBuilder();

  PlanningHomeViewModelBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _activeSprint = $v.activeSprint?.toBuilder();
      _isLoading = $v.isLoading;
      _loadFailed = $v.loadFailed;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PlanningHomeViewModel other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$PlanningHomeViewModel;
  }

  @override
  void update(void Function(PlanningHomeViewModelBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PlanningHomeViewModel build() => _build();

  _$PlanningHomeViewModel _build() {
    _$PlanningHomeViewModel _$result;
    try {
      _$result = _$v ??
          new _$PlanningHomeViewModel._(
              activeSprint: _activeSprint?.build(),
              isLoading: BuiltValueNullFieldError.checkNotNull(
                  isLoading, r'PlanningHomeViewModel', 'isLoading'),
              loadFailed: BuiltValueNullFieldError.checkNotNull(
                  loadFailed, r'PlanningHomeViewModel', 'loadFailed'));
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'activeSprint';
        _activeSprint?.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            r'PlanningHomeViewModel', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
