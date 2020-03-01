import 'package:google_sign_in/google_sign_in.dart';
import 'package:mockito/mockito.dart';

class MockGoogleSignInAccount extends Mock implements GoogleSignInAccount {
  String get email => 'scorpy@gmail.com';
}