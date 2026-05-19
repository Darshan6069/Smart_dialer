// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dialer_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$DialerState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(bool isSystemDialer) empty,
    required TResult Function(String number, List<ContactEntity> searchResults,
            bool isSystemDialer)
        typing,
    required TResult Function() calling,
    required TResult Function(String message) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(bool isSystemDialer)? empty,
    TResult? Function(String number, List<ContactEntity> searchResults,
            bool isSystemDialer)?
        typing,
    TResult? Function()? calling,
    TResult? Function(String message)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(bool isSystemDialer)? empty,
    TResult Function(String number, List<ContactEntity> searchResults,
            bool isSystemDialer)?
        typing,
    TResult Function()? calling,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Empty value) empty,
    required TResult Function(_Typing value) typing,
    required TResult Function(_Calling value) calling,
    required TResult Function(_Error value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Empty value)? empty,
    TResult? Function(_Typing value)? typing,
    TResult? Function(_Calling value)? calling,
    TResult? Function(_Error value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Empty value)? empty,
    TResult Function(_Typing value)? typing,
    TResult Function(_Calling value)? calling,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DialerStateCopyWith<$Res> {
  factory $DialerStateCopyWith(
          DialerState value, $Res Function(DialerState) then) =
      _$DialerStateCopyWithImpl<$Res, DialerState>;
}

/// @nodoc
class _$DialerStateCopyWithImpl<$Res, $Val extends DialerState>
    implements $DialerStateCopyWith<$Res> {
  _$DialerStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$EmptyImplCopyWith<$Res> {
  factory _$$EmptyImplCopyWith(
          _$EmptyImpl value, $Res Function(_$EmptyImpl) then) =
      __$$EmptyImplCopyWithImpl<$Res>;
  @useResult
  $Res call({bool isSystemDialer});
}

/// @nodoc
class __$$EmptyImplCopyWithImpl<$Res>
    extends _$DialerStateCopyWithImpl<$Res, _$EmptyImpl>
    implements _$$EmptyImplCopyWith<$Res> {
  __$$EmptyImplCopyWithImpl(
      _$EmptyImpl _value, $Res Function(_$EmptyImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isSystemDialer = null,
  }) {
    return _then(_$EmptyImpl(
      isSystemDialer: null == isSystemDialer
          ? _value.isSystemDialer
          : isSystemDialer // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$EmptyImpl implements _Empty {
  const _$EmptyImpl({this.isSystemDialer = false});

  @override
  @JsonKey()
  final bool isSystemDialer;

  @override
  String toString() {
    return 'DialerState.empty(isSystemDialer: $isSystemDialer)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EmptyImpl &&
            (identical(other.isSystemDialer, isSystemDialer) ||
                other.isSystemDialer == isSystemDialer));
  }

  @override
  int get hashCode => Object.hash(runtimeType, isSystemDialer);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$EmptyImplCopyWith<_$EmptyImpl> get copyWith =>
      __$$EmptyImplCopyWithImpl<_$EmptyImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(bool isSystemDialer) empty,
    required TResult Function(String number, List<ContactEntity> searchResults,
            bool isSystemDialer)
        typing,
    required TResult Function() calling,
    required TResult Function(String message) error,
  }) {
    return empty(isSystemDialer);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(bool isSystemDialer)? empty,
    TResult? Function(String number, List<ContactEntity> searchResults,
            bool isSystemDialer)?
        typing,
    TResult? Function()? calling,
    TResult? Function(String message)? error,
  }) {
    return empty?.call(isSystemDialer);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(bool isSystemDialer)? empty,
    TResult Function(String number, List<ContactEntity> searchResults,
            bool isSystemDialer)?
        typing,
    TResult Function()? calling,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (empty != null) {
      return empty(isSystemDialer);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Empty value) empty,
    required TResult Function(_Typing value) typing,
    required TResult Function(_Calling value) calling,
    required TResult Function(_Error value) error,
  }) {
    return empty(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Empty value)? empty,
    TResult? Function(_Typing value)? typing,
    TResult? Function(_Calling value)? calling,
    TResult? Function(_Error value)? error,
  }) {
    return empty?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Empty value)? empty,
    TResult Function(_Typing value)? typing,
    TResult Function(_Calling value)? calling,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (empty != null) {
      return empty(this);
    }
    return orElse();
  }
}

abstract class _Empty implements DialerState {
  const factory _Empty({final bool isSystemDialer}) = _$EmptyImpl;

  bool get isSystemDialer;
  @JsonKey(ignore: true)
  _$$EmptyImplCopyWith<_$EmptyImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$TypingImplCopyWith<$Res> {
  factory _$$TypingImplCopyWith(
          _$TypingImpl value, $Res Function(_$TypingImpl) then) =
      __$$TypingImplCopyWithImpl<$Res>;
  @useResult
  $Res call(
      {String number, List<ContactEntity> searchResults, bool isSystemDialer});
}

/// @nodoc
class __$$TypingImplCopyWithImpl<$Res>
    extends _$DialerStateCopyWithImpl<$Res, _$TypingImpl>
    implements _$$TypingImplCopyWith<$Res> {
  __$$TypingImplCopyWithImpl(
      _$TypingImpl _value, $Res Function(_$TypingImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? number = null,
    Object? searchResults = null,
    Object? isSystemDialer = null,
  }) {
    return _then(_$TypingImpl(
      number: null == number
          ? _value.number
          : number // ignore: cast_nullable_to_non_nullable
              as String,
      searchResults: null == searchResults
          ? _value._searchResults
          : searchResults // ignore: cast_nullable_to_non_nullable
              as List<ContactEntity>,
      isSystemDialer: null == isSystemDialer
          ? _value.isSystemDialer
          : isSystemDialer // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$TypingImpl implements _Typing {
  const _$TypingImpl(
      {required this.number,
      final List<ContactEntity> searchResults = const [],
      this.isSystemDialer = false})
      : _searchResults = searchResults;

  @override
  final String number;
  final List<ContactEntity> _searchResults;
  @override
  @JsonKey()
  List<ContactEntity> get searchResults {
    if (_searchResults is EqualUnmodifiableListView) return _searchResults;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_searchResults);
  }

  @override
  @JsonKey()
  final bool isSystemDialer;

  @override
  String toString() {
    return 'DialerState.typing(number: $number, searchResults: $searchResults, isSystemDialer: $isSystemDialer)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TypingImpl &&
            (identical(other.number, number) || other.number == number) &&
            const DeepCollectionEquality()
                .equals(other._searchResults, _searchResults) &&
            (identical(other.isSystemDialer, isSystemDialer) ||
                other.isSystemDialer == isSystemDialer));
  }

  @override
  int get hashCode => Object.hash(runtimeType, number,
      const DeepCollectionEquality().hash(_searchResults), isSystemDialer);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TypingImplCopyWith<_$TypingImpl> get copyWith =>
      __$$TypingImplCopyWithImpl<_$TypingImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(bool isSystemDialer) empty,
    required TResult Function(String number, List<ContactEntity> searchResults,
            bool isSystemDialer)
        typing,
    required TResult Function() calling,
    required TResult Function(String message) error,
  }) {
    return typing(number, searchResults, isSystemDialer);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(bool isSystemDialer)? empty,
    TResult? Function(String number, List<ContactEntity> searchResults,
            bool isSystemDialer)?
        typing,
    TResult? Function()? calling,
    TResult? Function(String message)? error,
  }) {
    return typing?.call(number, searchResults, isSystemDialer);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(bool isSystemDialer)? empty,
    TResult Function(String number, List<ContactEntity> searchResults,
            bool isSystemDialer)?
        typing,
    TResult Function()? calling,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (typing != null) {
      return typing(number, searchResults, isSystemDialer);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Empty value) empty,
    required TResult Function(_Typing value) typing,
    required TResult Function(_Calling value) calling,
    required TResult Function(_Error value) error,
  }) {
    return typing(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Empty value)? empty,
    TResult? Function(_Typing value)? typing,
    TResult? Function(_Calling value)? calling,
    TResult? Function(_Error value)? error,
  }) {
    return typing?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Empty value)? empty,
    TResult Function(_Typing value)? typing,
    TResult Function(_Calling value)? calling,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (typing != null) {
      return typing(this);
    }
    return orElse();
  }
}

abstract class _Typing implements DialerState {
  const factory _Typing(
      {required final String number,
      final List<ContactEntity> searchResults,
      final bool isSystemDialer}) = _$TypingImpl;

  String get number;
  List<ContactEntity> get searchResults;
  bool get isSystemDialer;
  @JsonKey(ignore: true)
  _$$TypingImplCopyWith<_$TypingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$CallingImplCopyWith<$Res> {
  factory _$$CallingImplCopyWith(
          _$CallingImpl value, $Res Function(_$CallingImpl) then) =
      __$$CallingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$CallingImplCopyWithImpl<$Res>
    extends _$DialerStateCopyWithImpl<$Res, _$CallingImpl>
    implements _$$CallingImplCopyWith<$Res> {
  __$$CallingImplCopyWithImpl(
      _$CallingImpl _value, $Res Function(_$CallingImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$CallingImpl implements _Calling {
  const _$CallingImpl();

  @override
  String toString() {
    return 'DialerState.calling()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$CallingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(bool isSystemDialer) empty,
    required TResult Function(String number, List<ContactEntity> searchResults,
            bool isSystemDialer)
        typing,
    required TResult Function() calling,
    required TResult Function(String message) error,
  }) {
    return calling();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(bool isSystemDialer)? empty,
    TResult? Function(String number, List<ContactEntity> searchResults,
            bool isSystemDialer)?
        typing,
    TResult? Function()? calling,
    TResult? Function(String message)? error,
  }) {
    return calling?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(bool isSystemDialer)? empty,
    TResult Function(String number, List<ContactEntity> searchResults,
            bool isSystemDialer)?
        typing,
    TResult Function()? calling,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (calling != null) {
      return calling();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Empty value) empty,
    required TResult Function(_Typing value) typing,
    required TResult Function(_Calling value) calling,
    required TResult Function(_Error value) error,
  }) {
    return calling(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Empty value)? empty,
    TResult? Function(_Typing value)? typing,
    TResult? Function(_Calling value)? calling,
    TResult? Function(_Error value)? error,
  }) {
    return calling?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Empty value)? empty,
    TResult Function(_Typing value)? typing,
    TResult Function(_Calling value)? calling,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (calling != null) {
      return calling(this);
    }
    return orElse();
  }
}

abstract class _Calling implements DialerState {
  const factory _Calling() = _$CallingImpl;
}

/// @nodoc
abstract class _$$ErrorImplCopyWith<$Res> {
  factory _$$ErrorImplCopyWith(
          _$ErrorImpl value, $Res Function(_$ErrorImpl) then) =
      __$$ErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$ErrorImplCopyWithImpl<$Res>
    extends _$DialerStateCopyWithImpl<$Res, _$ErrorImpl>
    implements _$$ErrorImplCopyWith<$Res> {
  __$$ErrorImplCopyWithImpl(
      _$ErrorImpl _value, $Res Function(_$ErrorImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_$ErrorImpl(
      null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$ErrorImpl implements _Error {
  const _$ErrorImpl(this.message);

  @override
  final String message;

  @override
  String toString() {
    return 'DialerState.error(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ErrorImplCopyWith<_$ErrorImpl> get copyWith =>
      __$$ErrorImplCopyWithImpl<_$ErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(bool isSystemDialer) empty,
    required TResult Function(String number, List<ContactEntity> searchResults,
            bool isSystemDialer)
        typing,
    required TResult Function() calling,
    required TResult Function(String message) error,
  }) {
    return error(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(bool isSystemDialer)? empty,
    TResult? Function(String number, List<ContactEntity> searchResults,
            bool isSystemDialer)?
        typing,
    TResult? Function()? calling,
    TResult? Function(String message)? error,
  }) {
    return error?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(bool isSystemDialer)? empty,
    TResult Function(String number, List<ContactEntity> searchResults,
            bool isSystemDialer)?
        typing,
    TResult Function()? calling,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Empty value) empty,
    required TResult Function(_Typing value) typing,
    required TResult Function(_Calling value) calling,
    required TResult Function(_Error value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Empty value)? empty,
    TResult? Function(_Typing value)? typing,
    TResult? Function(_Calling value)? calling,
    TResult? Function(_Error value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Empty value)? empty,
    TResult Function(_Typing value)? typing,
    TResult Function(_Calling value)? calling,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class _Error implements DialerState {
  const factory _Error(final String message) = _$ErrorImpl;

  String get message;
  @JsonKey(ignore: true)
  _$$ErrorImplCopyWith<_$ErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
