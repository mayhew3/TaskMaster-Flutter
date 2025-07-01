// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stats_counter_viewmodel.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$StatsCounterViewModel extends StatsCounterViewModel {
  @override
  final int numActive;
  @override
  final int numCompleted;

  factory _$StatsCounterViewModel([
    void Function(StatsCounterViewModelBuilder)? updates,
  ]) => (StatsCounterViewModelBuilder()..update(updates))._build();

  _$StatsCounterViewModel._({
    required this.numActive,
    required this.numCompleted,
  }) : super._();
  @override
  StatsCounterViewModel rebuild(
    void Function(StatsCounterViewModelBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  StatsCounterViewModelBuilder toBuilder() =>
      StatsCounterViewModelBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is StatsCounterViewModel &&
        numActive == other.numActive &&
        numCompleted == other.numCompleted;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, numActive.hashCode);
    _$hash = $jc(_$hash, numCompleted.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'StatsCounterViewModel')
          ..add('numActive', numActive)
          ..add('numCompleted', numCompleted))
        .toString();
  }
}

class StatsCounterViewModelBuilder
    implements Builder<StatsCounterViewModel, StatsCounterViewModelBuilder> {
  _$StatsCounterViewModel? _$v;

  int? _numActive;
  int? get numActive => _$this._numActive;
  set numActive(int? numActive) => _$this._numActive = numActive;

  int? _numCompleted;
  int? get numCompleted => _$this._numCompleted;
  set numCompleted(int? numCompleted) => _$this._numCompleted = numCompleted;

  StatsCounterViewModelBuilder();

  StatsCounterViewModelBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _numActive = $v.numActive;
      _numCompleted = $v.numCompleted;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(StatsCounterViewModel other) {
    _$v = other as _$StatsCounterViewModel;
  }

  @override
  void update(void Function(StatsCounterViewModelBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  StatsCounterViewModel build() => _build();

  _$StatsCounterViewModel _build() {
    final _$result =
        _$v ??
        _$StatsCounterViewModel._(
          numActive: BuiltValueNullFieldError.checkNotNull(
            numActive,
            r'StatsCounterViewModel',
            'numActive',
          ),
          numCompleted: BuiltValueNullFieldError.checkNotNull(
            numCompleted,
            r'StatsCounterViewModel',
            'numCompleted',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
