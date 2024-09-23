
import 'package:redux/redux.dart';
import 'package:taskmaster/redux/actions/auth_actions.dart';

import '../app_state.dart';

class TaskMainMenuViewModel {
  final Function onPressedCallback;

  TaskMainMenuViewModel(this.onPressedCallback);

  static TaskMainMenuViewModel fromStore(Store<AppState> store) {
    return TaskMainMenuViewModel(() {
      store.dispatch(LogOutAction());
    });
  }
}