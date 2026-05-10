// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_context.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<TaskContext> _$taskContextSerializer = _$TaskContextSerializer();

class _$TaskContextSerializer implements StructuredSerializer<TaskContext> {
  @override
  final Iterable<Type> types = const [TaskContext, _$TaskContext];
  @override
  final String wireName = 'TaskContext';

  @override
  Iterable<Object?> serialize(
    Serializers serializers,
    TaskContext object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = <Object?>[
      'name',
      serializers.serialize(object.name, specifiedType: const FullType(String)),
    ];
    Object? value;
    value = object.value;

    result
      ..add('value')
      ..add(serializers.serialize(value, specifiedType: const FullType(int)));

    return result;
  }

  @override
  TaskContext deserialize(
    Serializers serializers,
    Iterable<Object?> serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TaskContextBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'name':
          result.name =
              serializers.deserialize(
                    value,
                    specifiedType: const FullType(String),
                  )!
                  as String;
          break;
        case 'value':
          result.value =
              serializers.deserialize(value, specifiedType: const FullType(int))
                  as int?;
          break;
      }
    }

    return result.build();
  }
}

class _$TaskContext extends TaskContext {
  @override
  final String name;
  @override
  final int? value;

  factory _$TaskContext([void Function(TaskContextBuilder)? updates]) =>
      (TaskContextBuilder()..update(updates))._build();

  _$TaskContext._({required this.name, this.value}) : super._();
  @override
  TaskContext rebuild(void Function(TaskContextBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TaskContextBuilder toBuilder() => TaskContextBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TaskContext && name == other.name && value == other.value;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, value.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TaskContext')
          ..add('name', name)
          ..add('value', value))
        .toString();
  }
}

class TaskContextBuilder implements Builder<TaskContext, TaskContextBuilder> {
  _$TaskContext? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  int? _value;
  int? get value => _$this._value;
  set value(int? value) => _$this._value = value;

  TaskContextBuilder();

  TaskContextBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _value = $v.value;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TaskContext other) {
    _$v = other as _$TaskContext;
  }

  @override
  void update(void Function(TaskContextBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TaskContext build() => _build();

  _$TaskContext _build() {
    final _$result =
        _$v ??
        _$TaskContext._(
          name: BuiltValueNullFieldError.checkNotNull(
            name,
            r'TaskContext',
            'name',
          ),
          value: value,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
