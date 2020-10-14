import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:taskmaster/app_state.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MockIdTokenResult extends Mock implements IdTokenResult {
  String get token => 'asdbhjsfd';
}