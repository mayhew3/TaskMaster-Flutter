import 'package:taskmaster/models/app_state.dart';
import 'package:test/test.dart';

import '../mocks/mock_nav_helper.dart';
import '../mocks/mock_task_master_auth.dart';
import '../mocks/mock_task_repository.dart';

void main() {

  test('Should be constructed', () {
    var appState = AppState(
      auth: MockTaskMasterAuth(),
    );
    var navHelper = MockNavHelper(
      taskRepository: MockTaskRepository(),
    );
    appState.updateNavHelper(navHelper);
    expect(appState.title, 'TaskMaster 3000');
  });

}