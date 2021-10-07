import 'package:mockito/mockito.dart';
import 'package:taskmaster/auth.dart';

class MockTaskMasterAuth extends Fake implements TaskMasterAuth {

  Future<String> getIdToken() async {
    return Future<String>.value('asdsalds');
  }

}