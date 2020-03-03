import 'package:taskmaster/models/app_state.dart';
import 'package:test/test.dart';

import '../mocks/mock_nav_helper.dart';

void main() {

  test('Should be constructed', () {
    var appState = AppState(
        userUpdater: (signInAccount) => {},
      idTokenUpdater: (idTokenResult) => {},
      navHelper: MockNavHelper(

      )
    );
  });

}