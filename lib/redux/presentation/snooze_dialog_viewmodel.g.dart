// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'snooze_dialog_viewmodel.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SnoozeDialogViewModel extends SnoozeDialogViewModel {
  @override
  final TimezoneHelper timezoneHelper;

  factory _$SnoozeDialogViewModel([
    void Function(SnoozeDialogViewModelBuilder)? updates,
  ]) => (SnoozeDialogViewModelBuilder()..update(updates))._build();

  _$SnoozeDialogViewModel._({required this.timezoneHelper}) : super._();
  @override
  SnoozeDialogViewModel rebuild(
    void Function(SnoozeDialogViewModelBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  SnoozeDialogViewModelBuilder toBuilder() =>
      SnoozeDialogViewModelBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SnoozeDialogViewModel &&
        timezoneHelper == other.timezoneHelper;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, timezoneHelper.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
      r'SnoozeDialogViewModel',
    )..add('timezoneHelper', timezoneHelper)).toString();
  }
}

class SnoozeDialogViewModelBuilder
    implements Builder<SnoozeDialogViewModel, SnoozeDialogViewModelBuilder> {
  _$SnoozeDialogViewModel? _$v;

  TimezoneHelper? _timezoneHelper;
  TimezoneHelper? get timezoneHelper => _$this._timezoneHelper;
  set timezoneHelper(TimezoneHelper? timezoneHelper) =>
      _$this._timezoneHelper = timezoneHelper;

  SnoozeDialogViewModelBuilder();

  SnoozeDialogViewModelBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _timezoneHelper = $v.timezoneHelper;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SnoozeDialogViewModel other) {
    _$v = other as _$SnoozeDialogViewModel;
  }

  @override
  void update(void Function(SnoozeDialogViewModelBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SnoozeDialogViewModel build() => _build();

  _$SnoozeDialogViewModel _build() {
    final _$result =
        _$v ??
        _$SnoozeDialogViewModel._(
          timezoneHelper: BuiltValueNullFieldError.checkNotNull(
            timezoneHelper,
            r'SnoozeDialogViewModel',
            'timezoneHelper',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
