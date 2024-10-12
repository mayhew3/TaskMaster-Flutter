// Mocks generated by Mockito 5.4.4 from annotations
// in taskmaster/test/test_mock_helper.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i7;
import 'dart:convert' as _i8;
import 'dart:typed_data' as _i10;

import 'package:cloud_firestore/cloud_firestore.dart' as _i6;
import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart'
    as _i5;
import 'package:firebase_core/firebase_core.dart' as _i4;
import 'package:google_sign_in/google_sign_in.dart' as _i3;
import 'package:http/http.dart' as _i2;
import 'package:mockito/mockito.dart' as _i1;
import 'package:mockito/src/dummies.dart' as _i9;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeResponse_0 extends _i1.SmartFake implements _i2.Response {
  _FakeResponse_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeStreamedResponse_1 extends _i1.SmartFake
    implements _i2.StreamedResponse {
  _FakeStreamedResponse_1(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeGoogleSignInAuthentication_2 extends _i1.SmartFake
    implements _i3.GoogleSignInAuthentication {
  _FakeGoogleSignInAuthentication_2(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeFirebaseApp_3 extends _i1.SmartFake implements _i4.FirebaseApp {
  _FakeFirebaseApp_3(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeSettings_4 extends _i1.SmartFake implements _i5.Settings {
  _FakeSettings_4(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeCollectionReference_5<T extends Object?> extends _i1.SmartFake
    implements _i6.CollectionReference<T> {
  _FakeCollectionReference_5(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeWriteBatch_6 extends _i1.SmartFake implements _i6.WriteBatch {
  _FakeWriteBatch_6(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeLoadBundleTask_7 extends _i1.SmartFake
    implements _i6.LoadBundleTask {
  _FakeLoadBundleTask_7(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeQuerySnapshot_8<T1 extends Object?> extends _i1.SmartFake
    implements _i6.QuerySnapshot<T1> {
  _FakeQuerySnapshot_8(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeQuery_9<T extends Object?> extends _i1.SmartFake
    implements _i6.Query<T> {
  _FakeQuery_9(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeDocumentReference_10<T extends Object?> extends _i1.SmartFake
    implements _i6.DocumentReference<T> {
  _FakeDocumentReference_10(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeFuture_11<T1> extends _i1.SmartFake implements _i7.Future<T1> {
  _FakeFuture_11(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [Client].
///
/// See the documentation for Mockito's code generation for more information.
class MockClient extends _i1.Mock implements _i2.Client {
  @override
  _i7.Future<_i2.Response> head(
    Uri? url, {
    Map<String, String>? headers,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #head,
          [url],
          {#headers: headers},
        ),
        returnValue: _i7.Future<_i2.Response>.value(_FakeResponse_0(
          this,
          Invocation.method(
            #head,
            [url],
            {#headers: headers},
          ),
        )),
        returnValueForMissingStub:
            _i7.Future<_i2.Response>.value(_FakeResponse_0(
          this,
          Invocation.method(
            #head,
            [url],
            {#headers: headers},
          ),
        )),
      ) as _i7.Future<_i2.Response>);

  @override
  _i7.Future<_i2.Response> get(
    Uri? url, {
    Map<String, String>? headers,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #get,
          [url],
          {#headers: headers},
        ),
        returnValue: _i7.Future<_i2.Response>.value(_FakeResponse_0(
          this,
          Invocation.method(
            #get,
            [url],
            {#headers: headers},
          ),
        )),
        returnValueForMissingStub:
            _i7.Future<_i2.Response>.value(_FakeResponse_0(
          this,
          Invocation.method(
            #get,
            [url],
            {#headers: headers},
          ),
        )),
      ) as _i7.Future<_i2.Response>);

  @override
  _i7.Future<_i2.Response> post(
    Uri? url, {
    Map<String, String>? headers,
    Object? body,
    _i8.Encoding? encoding,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #post,
          [url],
          {
            #headers: headers,
            #body: body,
            #encoding: encoding,
          },
        ),
        returnValue: _i7.Future<_i2.Response>.value(_FakeResponse_0(
          this,
          Invocation.method(
            #post,
            [url],
            {
              #headers: headers,
              #body: body,
              #encoding: encoding,
            },
          ),
        )),
        returnValueForMissingStub:
            _i7.Future<_i2.Response>.value(_FakeResponse_0(
          this,
          Invocation.method(
            #post,
            [url],
            {
              #headers: headers,
              #body: body,
              #encoding: encoding,
            },
          ),
        )),
      ) as _i7.Future<_i2.Response>);

  @override
  _i7.Future<_i2.Response> put(
    Uri? url, {
    Map<String, String>? headers,
    Object? body,
    _i8.Encoding? encoding,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #put,
          [url],
          {
            #headers: headers,
            #body: body,
            #encoding: encoding,
          },
        ),
        returnValue: _i7.Future<_i2.Response>.value(_FakeResponse_0(
          this,
          Invocation.method(
            #put,
            [url],
            {
              #headers: headers,
              #body: body,
              #encoding: encoding,
            },
          ),
        )),
        returnValueForMissingStub:
            _i7.Future<_i2.Response>.value(_FakeResponse_0(
          this,
          Invocation.method(
            #put,
            [url],
            {
              #headers: headers,
              #body: body,
              #encoding: encoding,
            },
          ),
        )),
      ) as _i7.Future<_i2.Response>);

  @override
  _i7.Future<_i2.Response> patch(
    Uri? url, {
    Map<String, String>? headers,
    Object? body,
    _i8.Encoding? encoding,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #patch,
          [url],
          {
            #headers: headers,
            #body: body,
            #encoding: encoding,
          },
        ),
        returnValue: _i7.Future<_i2.Response>.value(_FakeResponse_0(
          this,
          Invocation.method(
            #patch,
            [url],
            {
              #headers: headers,
              #body: body,
              #encoding: encoding,
            },
          ),
        )),
        returnValueForMissingStub:
            _i7.Future<_i2.Response>.value(_FakeResponse_0(
          this,
          Invocation.method(
            #patch,
            [url],
            {
              #headers: headers,
              #body: body,
              #encoding: encoding,
            },
          ),
        )),
      ) as _i7.Future<_i2.Response>);

  @override
  _i7.Future<_i2.Response> delete(
    Uri? url, {
    Map<String, String>? headers,
    Object? body,
    _i8.Encoding? encoding,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #delete,
          [url],
          {
            #headers: headers,
            #body: body,
            #encoding: encoding,
          },
        ),
        returnValue: _i7.Future<_i2.Response>.value(_FakeResponse_0(
          this,
          Invocation.method(
            #delete,
            [url],
            {
              #headers: headers,
              #body: body,
              #encoding: encoding,
            },
          ),
        )),
        returnValueForMissingStub:
            _i7.Future<_i2.Response>.value(_FakeResponse_0(
          this,
          Invocation.method(
            #delete,
            [url],
            {
              #headers: headers,
              #body: body,
              #encoding: encoding,
            },
          ),
        )),
      ) as _i7.Future<_i2.Response>);

  @override
  _i7.Future<String> read(
    Uri? url, {
    Map<String, String>? headers,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #read,
          [url],
          {#headers: headers},
        ),
        returnValue: _i7.Future<String>.value(_i9.dummyValue<String>(
          this,
          Invocation.method(
            #read,
            [url],
            {#headers: headers},
          ),
        )),
        returnValueForMissingStub:
            _i7.Future<String>.value(_i9.dummyValue<String>(
          this,
          Invocation.method(
            #read,
            [url],
            {#headers: headers},
          ),
        )),
      ) as _i7.Future<String>);

  @override
  _i7.Future<_i10.Uint8List> readBytes(
    Uri? url, {
    Map<String, String>? headers,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #readBytes,
          [url],
          {#headers: headers},
        ),
        returnValue: _i7.Future<_i10.Uint8List>.value(_i10.Uint8List(0)),
        returnValueForMissingStub:
            _i7.Future<_i10.Uint8List>.value(_i10.Uint8List(0)),
      ) as _i7.Future<_i10.Uint8List>);

  @override
  _i7.Future<_i2.StreamedResponse> send(_i2.BaseRequest? request) =>
      (super.noSuchMethod(
        Invocation.method(
          #send,
          [request],
        ),
        returnValue:
            _i7.Future<_i2.StreamedResponse>.value(_FakeStreamedResponse_1(
          this,
          Invocation.method(
            #send,
            [request],
          ),
        )),
        returnValueForMissingStub:
            _i7.Future<_i2.StreamedResponse>.value(_FakeStreamedResponse_1(
          this,
          Invocation.method(
            #send,
            [request],
          ),
        )),
      ) as _i7.Future<_i2.StreamedResponse>);

  @override
  void close() => super.noSuchMethod(
        Invocation.method(
          #close,
          [],
        ),
        returnValueForMissingStub: null,
      );
}

/// A class which mocks [GoogleSignInAccount].
///
/// See the documentation for Mockito's code generation for more information.
// ignore: must_be_immutable
class MockGoogleSignInAccount extends _i1.Mock
    implements _i3.GoogleSignInAccount {
  @override
  String get email => (super.noSuchMethod(
        Invocation.getter(#email),
        returnValue: _i9.dummyValue<String>(
          this,
          Invocation.getter(#email),
        ),
        returnValueForMissingStub: _i9.dummyValue<String>(
          this,
          Invocation.getter(#email),
        ),
      ) as String);

  @override
  String get id => (super.noSuchMethod(
        Invocation.getter(#id),
        returnValue: _i9.dummyValue<String>(
          this,
          Invocation.getter(#id),
        ),
        returnValueForMissingStub: _i9.dummyValue<String>(
          this,
          Invocation.getter(#id),
        ),
      ) as String);

  @override
  _i7.Future<_i3.GoogleSignInAuthentication> get authentication =>
      (super.noSuchMethod(
        Invocation.getter(#authentication),
        returnValue: _i7.Future<_i3.GoogleSignInAuthentication>.value(
            _FakeGoogleSignInAuthentication_2(
          this,
          Invocation.getter(#authentication),
        )),
        returnValueForMissingStub:
            _i7.Future<_i3.GoogleSignInAuthentication>.value(
                _FakeGoogleSignInAuthentication_2(
          this,
          Invocation.getter(#authentication),
        )),
      ) as _i7.Future<_i3.GoogleSignInAuthentication>);

  @override
  _i7.Future<Map<String, String>> get authHeaders => (super.noSuchMethod(
        Invocation.getter(#authHeaders),
        returnValue: _i7.Future<Map<String, String>>.value(<String, String>{}),
        returnValueForMissingStub:
            _i7.Future<Map<String, String>>.value(<String, String>{}),
      ) as _i7.Future<Map<String, String>>);

  @override
  _i7.Future<void> clearAuthCache() => (super.noSuchMethod(
        Invocation.method(
          #clearAuthCache,
          [],
        ),
        returnValue: _i7.Future<void>.value(),
        returnValueForMissingStub: _i7.Future<void>.value(),
      ) as _i7.Future<void>);
}

/// A class which mocks [FirebaseFirestore].
///
/// See the documentation for Mockito's code generation for more information.
class MockFirebaseFirestore extends _i1.Mock implements _i6.FirebaseFirestore {
  @override
  _i4.FirebaseApp get app => (super.noSuchMethod(
        Invocation.getter(#app),
        returnValue: _FakeFirebaseApp_3(
          this,
          Invocation.getter(#app),
        ),
        returnValueForMissingStub: _FakeFirebaseApp_3(
          this,
          Invocation.getter(#app),
        ),
      ) as _i4.FirebaseApp);

  @override
  set app(_i4.FirebaseApp? _app) => super.noSuchMethod(
        Invocation.setter(
          #app,
          _app,
        ),
        returnValueForMissingStub: null,
      );

  @override
  String get databaseURL => (super.noSuchMethod(
        Invocation.getter(#databaseURL),
        returnValue: _i9.dummyValue<String>(
          this,
          Invocation.getter(#databaseURL),
        ),
        returnValueForMissingStub: _i9.dummyValue<String>(
          this,
          Invocation.getter(#databaseURL),
        ),
      ) as String);

  @override
  set databaseURL(String? _databaseURL) => super.noSuchMethod(
        Invocation.setter(
          #databaseURL,
          _databaseURL,
        ),
        returnValueForMissingStub: null,
      );

  @override
  String get databaseId => (super.noSuchMethod(
        Invocation.getter(#databaseId),
        returnValue: _i9.dummyValue<String>(
          this,
          Invocation.getter(#databaseId),
        ),
        returnValueForMissingStub: _i9.dummyValue<String>(
          this,
          Invocation.getter(#databaseId),
        ),
      ) as String);

  @override
  set databaseId(String? _databaseId) => super.noSuchMethod(
        Invocation.setter(
          #databaseId,
          _databaseId,
        ),
        returnValueForMissingStub: null,
      );

  @override
  set settings(_i5.Settings? settings) => super.noSuchMethod(
        Invocation.setter(
          #settings,
          settings,
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i5.Settings get settings => (super.noSuchMethod(
        Invocation.getter(#settings),
        returnValue: _FakeSettings_4(
          this,
          Invocation.getter(#settings),
        ),
        returnValueForMissingStub: _FakeSettings_4(
          this,
          Invocation.getter(#settings),
        ),
      ) as _i5.Settings);

  @override
  Map<dynamic, dynamic> get pluginConstants => (super.noSuchMethod(
        Invocation.getter(#pluginConstants),
        returnValue: <dynamic, dynamic>{},
        returnValueForMissingStub: <dynamic, dynamic>{},
      ) as Map<dynamic, dynamic>);

  @override
  _i6.CollectionReference<Map<String, dynamic>> collection(
          String? collectionPath) =>
      (super.noSuchMethod(
        Invocation.method(
          #collection,
          [collectionPath],
        ),
        returnValue: _FakeCollectionReference_5<Map<String, dynamic>>(
          this,
          Invocation.method(
            #collection,
            [collectionPath],
          ),
        ),
        returnValueForMissingStub:
            _FakeCollectionReference_5<Map<String, dynamic>>(
          this,
          Invocation.method(
            #collection,
            [collectionPath],
          ),
        ),
      ) as _i6.CollectionReference<Map<String, dynamic>>);

  @override
  _i6.WriteBatch batch() => (super.noSuchMethod(
        Invocation.method(
          #batch,
          [],
        ),
        returnValue: _FakeWriteBatch_6(
          this,
          Invocation.method(
            #batch,
            [],
          ),
        ),
        returnValueForMissingStub: _FakeWriteBatch_6(
          this,
          Invocation.method(
            #batch,
            [],
          ),
        ),
      ) as _i6.WriteBatch);

  @override
  _i7.Future<void> clearPersistence() => (super.noSuchMethod(
        Invocation.method(
          #clearPersistence,
          [],
        ),
        returnValue: _i7.Future<void>.value(),
        returnValueForMissingStub: _i7.Future<void>.value(),
      ) as _i7.Future<void>);

  @override
  _i7.Future<void> enablePersistence(
          [_i5.PersistenceSettings? persistenceSettings]) =>
      (super.noSuchMethod(
        Invocation.method(
          #enablePersistence,
          [persistenceSettings],
        ),
        returnValue: _i7.Future<void>.value(),
        returnValueForMissingStub: _i7.Future<void>.value(),
      ) as _i7.Future<void>);

  @override
  _i6.LoadBundleTask loadBundle(_i10.Uint8List? bundle) => (super.noSuchMethod(
        Invocation.method(
          #loadBundle,
          [bundle],
        ),
        returnValue: _FakeLoadBundleTask_7(
          this,
          Invocation.method(
            #loadBundle,
            [bundle],
          ),
        ),
        returnValueForMissingStub: _FakeLoadBundleTask_7(
          this,
          Invocation.method(
            #loadBundle,
            [bundle],
          ),
        ),
      ) as _i6.LoadBundleTask);

  @override
  void useFirestoreEmulator(
    String? host,
    int? port, {
    bool? sslEnabled = false,
    bool? automaticHostMapping = true,
  }) =>
      super.noSuchMethod(
        Invocation.method(
          #useFirestoreEmulator,
          [
            host,
            port,
          ],
          {
            #sslEnabled: sslEnabled,
            #automaticHostMapping: automaticHostMapping,
          },
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i7.Future<_i6.QuerySnapshot<T>> namedQueryWithConverterGet<T>(
    String? name, {
    _i5.GetOptions? options = const _i5.GetOptions(),
    required _i6.FromFirestore<T>? fromFirestore,
    required _i6.ToFirestore<T>? toFirestore,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #namedQueryWithConverterGet,
          [name],
          {
            #options: options,
            #fromFirestore: fromFirestore,
            #toFirestore: toFirestore,
          },
        ),
        returnValue:
            _i7.Future<_i6.QuerySnapshot<T>>.value(_FakeQuerySnapshot_8<T>(
          this,
          Invocation.method(
            #namedQueryWithConverterGet,
            [name],
            {
              #options: options,
              #fromFirestore: fromFirestore,
              #toFirestore: toFirestore,
            },
          ),
        )),
        returnValueForMissingStub:
            _i7.Future<_i6.QuerySnapshot<T>>.value(_FakeQuerySnapshot_8<T>(
          this,
          Invocation.method(
            #namedQueryWithConverterGet,
            [name],
            {
              #options: options,
              #fromFirestore: fromFirestore,
              #toFirestore: toFirestore,
            },
          ),
        )),
      ) as _i7.Future<_i6.QuerySnapshot<T>>);

  @override
  _i7.Future<_i6.QuerySnapshot<Map<String, dynamic>>> namedQueryGet(
    String? name, {
    _i5.GetOptions? options = const _i5.GetOptions(),
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #namedQueryGet,
          [name],
          {#options: options},
        ),
        returnValue: _i7.Future<_i6.QuerySnapshot<Map<String, dynamic>>>.value(
            _FakeQuerySnapshot_8<Map<String, dynamic>>(
          this,
          Invocation.method(
            #namedQueryGet,
            [name],
            {#options: options},
          ),
        )),
        returnValueForMissingStub:
            _i7.Future<_i6.QuerySnapshot<Map<String, dynamic>>>.value(
                _FakeQuerySnapshot_8<Map<String, dynamic>>(
          this,
          Invocation.method(
            #namedQueryGet,
            [name],
            {#options: options},
          ),
        )),
      ) as _i7.Future<_i6.QuerySnapshot<Map<String, dynamic>>>);

  @override
  _i6.Query<Map<String, dynamic>> collectionGroup(String? collectionPath) =>
      (super.noSuchMethod(
        Invocation.method(
          #collectionGroup,
          [collectionPath],
        ),
        returnValue: _FakeQuery_9<Map<String, dynamic>>(
          this,
          Invocation.method(
            #collectionGroup,
            [collectionPath],
          ),
        ),
        returnValueForMissingStub: _FakeQuery_9<Map<String, dynamic>>(
          this,
          Invocation.method(
            #collectionGroup,
            [collectionPath],
          ),
        ),
      ) as _i6.Query<Map<String, dynamic>>);

  @override
  _i7.Future<void> disableNetwork() => (super.noSuchMethod(
        Invocation.method(
          #disableNetwork,
          [],
        ),
        returnValue: _i7.Future<void>.value(),
        returnValueForMissingStub: _i7.Future<void>.value(),
      ) as _i7.Future<void>);

  @override
  _i6.DocumentReference<Map<String, dynamic>> doc(String? documentPath) =>
      (super.noSuchMethod(
        Invocation.method(
          #doc,
          [documentPath],
        ),
        returnValue: _FakeDocumentReference_10<Map<String, dynamic>>(
          this,
          Invocation.method(
            #doc,
            [documentPath],
          ),
        ),
        returnValueForMissingStub:
            _FakeDocumentReference_10<Map<String, dynamic>>(
          this,
          Invocation.method(
            #doc,
            [documentPath],
          ),
        ),
      ) as _i6.DocumentReference<Map<String, dynamic>>);

  @override
  _i7.Future<void> enableNetwork() => (super.noSuchMethod(
        Invocation.method(
          #enableNetwork,
          [],
        ),
        returnValue: _i7.Future<void>.value(),
        returnValueForMissingStub: _i7.Future<void>.value(),
      ) as _i7.Future<void>);

  @override
  _i7.Stream<void> snapshotsInSync() => (super.noSuchMethod(
        Invocation.method(
          #snapshotsInSync,
          [],
        ),
        returnValue: _i7.Stream<void>.empty(),
        returnValueForMissingStub: _i7.Stream<void>.empty(),
      ) as _i7.Stream<void>);

  @override
  _i7.Future<T> runTransaction<T>(
    _i6.TransactionHandler<T>? transactionHandler, {
    Duration? timeout = const Duration(seconds: 30),
    int? maxAttempts = 5,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #runTransaction,
          [transactionHandler],
          {
            #timeout: timeout,
            #maxAttempts: maxAttempts,
          },
        ),
        returnValue: _i9.ifNotNull(
              _i9.dummyValueOrNull<T>(
                this,
                Invocation.method(
                  #runTransaction,
                  [transactionHandler],
                  {
                    #timeout: timeout,
                    #maxAttempts: maxAttempts,
                  },
                ),
              ),
              (T v) => _i7.Future<T>.value(v),
            ) ??
            _FakeFuture_11<T>(
              this,
              Invocation.method(
                #runTransaction,
                [transactionHandler],
                {
                  #timeout: timeout,
                  #maxAttempts: maxAttempts,
                },
              ),
            ),
        returnValueForMissingStub: _i9.ifNotNull(
              _i9.dummyValueOrNull<T>(
                this,
                Invocation.method(
                  #runTransaction,
                  [transactionHandler],
                  {
                    #timeout: timeout,
                    #maxAttempts: maxAttempts,
                  },
                ),
              ),
              (T v) => _i7.Future<T>.value(v),
            ) ??
            _FakeFuture_11<T>(
              this,
              Invocation.method(
                #runTransaction,
                [transactionHandler],
                {
                  #timeout: timeout,
                  #maxAttempts: maxAttempts,
                },
              ),
            ),
      ) as _i7.Future<T>);

  @override
  _i7.Future<void> terminate() => (super.noSuchMethod(
        Invocation.method(
          #terminate,
          [],
        ),
        returnValue: _i7.Future<void>.value(),
        returnValueForMissingStub: _i7.Future<void>.value(),
      ) as _i7.Future<void>);

  @override
  _i7.Future<void> waitForPendingWrites() => (super.noSuchMethod(
        Invocation.method(
          #waitForPendingWrites,
          [],
        ),
        returnValue: _i7.Future<void>.value(),
        returnValueForMissingStub: _i7.Future<void>.value(),
      ) as _i7.Future<void>);

  @override
  _i7.Future<void> setIndexConfiguration({
    required List<_i5.Index>? indexes,
    List<_i5.FieldOverrides>? fieldOverrides,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #setIndexConfiguration,
          [],
          {
            #indexes: indexes,
            #fieldOverrides: fieldOverrides,
          },
        ),
        returnValue: _i7.Future<void>.value(),
        returnValueForMissingStub: _i7.Future<void>.value(),
      ) as _i7.Future<void>);

  @override
  _i7.Future<void> setIndexConfigurationFromJSON(String? json) =>
      (super.noSuchMethod(
        Invocation.method(
          #setIndexConfigurationFromJSON,
          [json],
        ),
        returnValue: _i7.Future<void>.value(),
        returnValueForMissingStub: _i7.Future<void>.value(),
      ) as _i7.Future<void>);
}
