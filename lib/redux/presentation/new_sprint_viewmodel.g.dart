// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'new_sprint_viewmodel.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$NewSprintViewModel extends NewSprintViewModel {
  @override
  final TimezoneHelper timezoneHelper;
  @override
  final Sprint? activeSprint;
  @override
  final Sprint? lastCompleted;

  factory _$NewSprintViewModel(
          [void Function(NewSprintViewModelBuilder)? updates]) =>
      (new NewSprintViewModelBuilder()..update(updates))._build();

  _$NewSprintViewModel._(
      {required this.timezoneHelper, this.activeSprint, this.lastCompleted})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(
        timezoneHelper, r'NewSprintViewModel', 'timezoneHelper');
  }

  @override
  NewSprintViewModel rebuild(
          void Function(NewSprintViewModelBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  NewSprintViewModelBuilder toBuilder() =>
      new NewSprintViewModelBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is NewSprintViewModel &&
        timezoneHelper == other.timezoneHelper &&
        activeSprint == other.activeSprint &&
        lastCompleted == other.lastCompleted;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, timezoneHelper.hashCode);
    _$hash = $jc(_$hash, activeSprint.hashCode);
    _$hash = $jc(_$hash, lastCompleted.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'NewSprintViewModel')
          ..add('timezoneHelper', timezoneHelper)
          ..add('activeSprint', activeSprint)
          ..add('lastCompleted', lastCompleted))
        .toString();
  }
}

class NewSprintViewModelBuilder
    implements Builder<NewSprintViewModel, NewSprintViewModelBuilder> {
  _$NewSprintViewModel? _$v;

  TimezoneHelper? _timezoneHelper;
  TimezoneHelper? get timezoneHelper => _$this._timezoneHelper;
  set timezoneHelper(TimezoneHelper? timezoneHelper) =>
      _$this._timezoneHelper = timezoneHelper;

  SprintBuilder? _activeSprint;
  SprintBuilder get activeSprint =>
      _$this._activeSprint ??= new SprintBuilder();
  set activeSprint(SprintBuilder? activeSprint) =>
      _$this._activeSprint = activeSprint;

  SprintBuilder? _lastCompleted;
  SprintBuilder get lastCompleted =>
      _$this._lastCompleted ??= new SprintBuilder();
  set lastCompleted(SprintBuilder? lastCompleted) =>
      _$this._lastCompleted = lastCompleted;

  NewSprintViewModelBuilder();

  NewSprintViewModelBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _timezoneHelper = $v.timezoneHelper;
      _activeSprint = $v.activeSprint?.toBuilder();
      _lastCompleted = $v.lastCompleted?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(NewSprintViewModel other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$NewSprintViewModel;
  }

  @override
  void update(void Function(NewSprintViewModelBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  NewSprintViewModel build() => _build();

  _$NewSprintViewModel _build() {
    _$NewSprintViewModel _$result;
    try {
      _$result = _$v ??
          new _$NewSprintViewModel._(
              timezoneHelper: BuiltValueNullFieldError.checkNotNull(
                  timezoneHelper, r'NewSprintViewModel', 'timezoneHelper'),
              activeSprint: _activeSprint?.build(),
              lastCompleted: _lastCompleted?.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'activeSprint';
        _activeSprint?.build();
        _$failedField = 'lastCompleted';
        _lastCompleted?.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            r'NewSprintViewModel', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
