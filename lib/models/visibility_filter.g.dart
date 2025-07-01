// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'visibility_filter.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$VisibilityFilter extends VisibilityFilter {
  @override
  final bool showScheduled;
  @override
  final bool showCompleted;
  @override
  final bool showActiveSprint;

  factory _$VisibilityFilter([
    void Function(VisibilityFilterBuilder)? updates,
  ]) => (VisibilityFilterBuilder()..update(updates))._build();

  _$VisibilityFilter._({
    required this.showScheduled,
    required this.showCompleted,
    required this.showActiveSprint,
  }) : super._();
  @override
  VisibilityFilter rebuild(void Function(VisibilityFilterBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  VisibilityFilterBuilder toBuilder() =>
      VisibilityFilterBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is VisibilityFilter &&
        showScheduled == other.showScheduled &&
        showCompleted == other.showCompleted &&
        showActiveSprint == other.showActiveSprint;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, showScheduled.hashCode);
    _$hash = $jc(_$hash, showCompleted.hashCode);
    _$hash = $jc(_$hash, showActiveSprint.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'VisibilityFilter')
          ..add('showScheduled', showScheduled)
          ..add('showCompleted', showCompleted)
          ..add('showActiveSprint', showActiveSprint))
        .toString();
  }
}

class VisibilityFilterBuilder
    implements Builder<VisibilityFilter, VisibilityFilterBuilder> {
  _$VisibilityFilter? _$v;

  bool? _showScheduled;
  bool? get showScheduled => _$this._showScheduled;
  set showScheduled(bool? showScheduled) =>
      _$this._showScheduled = showScheduled;

  bool? _showCompleted;
  bool? get showCompleted => _$this._showCompleted;
  set showCompleted(bool? showCompleted) =>
      _$this._showCompleted = showCompleted;

  bool? _showActiveSprint;
  bool? get showActiveSprint => _$this._showActiveSprint;
  set showActiveSprint(bool? showActiveSprint) =>
      _$this._showActiveSprint = showActiveSprint;

  VisibilityFilterBuilder();

  VisibilityFilterBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _showScheduled = $v.showScheduled;
      _showCompleted = $v.showCompleted;
      _showActiveSprint = $v.showActiveSprint;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(VisibilityFilter other) {
    _$v = other as _$VisibilityFilter;
  }

  @override
  void update(void Function(VisibilityFilterBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  VisibilityFilter build() => _build();

  _$VisibilityFilter _build() {
    final _$result =
        _$v ??
        _$VisibilityFilter._(
          showScheduled: BuiltValueNullFieldError.checkNotNull(
            showScheduled,
            r'VisibilityFilter',
            'showScheduled',
          ),
          showCompleted: BuiltValueNullFieldError.checkNotNull(
            showCompleted,
            r'VisibilityFilter',
            'showCompleted',
          ),
          showActiveSprint: BuiltValueNullFieldError.checkNotNull(
            showActiveSprint,
            r'VisibilityFilter',
            'showActiveSprint',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
