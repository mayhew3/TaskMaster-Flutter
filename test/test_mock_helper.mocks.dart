// Mocks generated by Mockito 5.0.16 from annotations
// in taskmaster/test/test_mock_helper.dart.
// Do not manually edit this file.

import 'dart:async' as _i6;
import 'dart:convert' as _i7;
import 'dart:typed_data' as _i8;

import 'package:google_sign_in/google_sign_in.dart' as _i4;
import 'package:http/src/base_request.dart' as _i9;
import 'package:http/src/client.dart' as _i5;
import 'package:http/src/response.dart' as _i2;
import 'package:http/src/streamed_response.dart' as _i3;
import 'package:mockito/mockito.dart' as _i1;

// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types

class _FakeResponse_0 extends _i1.Fake implements _i2.Response {}

class _FakeStreamedResponse_1 extends _i1.Fake implements _i3.StreamedResponse {
}

class _FakeGoogleSignInAuthentication_2 extends _i1.Fake
    implements _i4.GoogleSignInAuthentication {}

/// A class which mocks [Client].
///
/// See the documentation for Mockito's code generation for more information.
class MockClient extends _i1.Mock implements _i5.Client {
  MockClient() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i6.Future<_i2.Response> head(Uri? url, {Map<String, String>? headers}) =>
      (super.noSuchMethod(Invocation.method(#head, [url], {#headers: headers}),
              returnValue: Future<_i2.Response>.value(_FakeResponse_0()))
          as _i6.Future<_i2.Response>);
  @override
  _i6.Future<_i2.Response> get(Uri? url, {Map<String, String>? headers}) =>
      (super.noSuchMethod(Invocation.method(#get, [url], {#headers: headers}),
              returnValue: Future<_i2.Response>.value(_FakeResponse_0()))
          as _i6.Future<_i2.Response>);
  @override
  _i6.Future<_i2.Response> post(Uri? url,
          {Map<String, String>? headers,
          Object? body,
          _i7.Encoding? encoding}) =>
      (super.noSuchMethod(
              Invocation.method(#post, [url],
                  {#headers: headers, #body: body, #encoding: encoding}),
              returnValue: Future<_i2.Response>.value(_FakeResponse_0()))
          as _i6.Future<_i2.Response>);
  @override
  _i6.Future<_i2.Response> put(Uri? url,
          {Map<String, String>? headers,
          Object? body,
          _i7.Encoding? encoding}) =>
      (super.noSuchMethod(
              Invocation.method(#put, [url],
                  {#headers: headers, #body: body, #encoding: encoding}),
              returnValue: Future<_i2.Response>.value(_FakeResponse_0()))
          as _i6.Future<_i2.Response>);
  @override
  _i6.Future<_i2.Response> patch(Uri? url,
          {Map<String, String>? headers,
          Object? body,
          _i7.Encoding? encoding}) =>
      (super.noSuchMethod(
              Invocation.method(#patch, [url],
                  {#headers: headers, #body: body, #encoding: encoding}),
              returnValue: Future<_i2.Response>.value(_FakeResponse_0()))
          as _i6.Future<_i2.Response>);
  @override
  _i6.Future<_i2.Response> delete(Uri? url,
          {Map<String, String>? headers,
          Object? body,
          _i7.Encoding? encoding}) =>
      (super.noSuchMethod(
              Invocation.method(#delete, [url],
                  {#headers: headers, #body: body, #encoding: encoding}),
              returnValue: Future<_i2.Response>.value(_FakeResponse_0()))
          as _i6.Future<_i2.Response>);
  @override
  _i6.Future<String> read(Uri? url, {Map<String, String>? headers}) =>
      (super.noSuchMethod(Invocation.method(#read, [url], {#headers: headers}),
          returnValue: Future<String>.value('')) as _i6.Future<String>);
  @override
  _i6.Future<_i8.Uint8List> readBytes(Uri? url,
          {Map<String, String>? headers}) =>
      (super.noSuchMethod(
              Invocation.method(#readBytes, [url], {#headers: headers}),
              returnValue: Future<_i8.Uint8List>.value(_i8.Uint8List(0)))
          as _i6.Future<_i8.Uint8List>);
  @override
  _i6.Future<_i3.StreamedResponse> send(_i9.BaseRequest? request) =>
      (super.noSuchMethod(Invocation.method(#send, [request]),
              returnValue:
                  Future<_i3.StreamedResponse>.value(_FakeStreamedResponse_1()))
          as _i6.Future<_i3.StreamedResponse>);
  @override
  void close() => super.noSuchMethod(Invocation.method(#close, []),
      returnValueForMissingStub: null);
  @override
  String toString() => super.toString();
}

/// A class which mocks [GoogleSignInAccount].
///
/// See the documentation for Mockito's code generation for more information.
class MockGoogleSignInAccount extends _i1.Mock
    implements _i4.GoogleSignInAccount {
  MockGoogleSignInAccount() {
    _i1.throwOnMissingStub(this);
  }

  @override
  String get email =>
      (super.noSuchMethod(Invocation.getter(#email), returnValue: '')
          as String);
  @override
  String get id =>
      (super.noSuchMethod(Invocation.getter(#id), returnValue: '') as String);
  @override
  _i6.Future<_i4.GoogleSignInAuthentication> get authentication =>
      (super.noSuchMethod(Invocation.getter(#authentication),
              returnValue: Future<_i4.GoogleSignInAuthentication>.value(
                  _FakeGoogleSignInAuthentication_2()))
          as _i6.Future<_i4.GoogleSignInAuthentication>);
  @override
  _i6.Future<Map<String, String>> get authHeaders => (super.noSuchMethod(
          Invocation.getter(#authHeaders),
          returnValue: Future<Map<String, String>>.value(<String, String>{}))
      as _i6.Future<Map<String, String>>);
  @override
  _i6.Future<void> clearAuthCache() =>
      (super.noSuchMethod(Invocation.method(#clearAuthCache, []),
          returnValue: Future<void>.value(),
          returnValueForMissingStub: Future<void>.value()) as _i6.Future<void>);
  @override
  String toString() => super.toString();
}
