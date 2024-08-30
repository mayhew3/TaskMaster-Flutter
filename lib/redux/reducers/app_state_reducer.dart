import 'package:redux/redux.dart';
import 'package:taskmaster/redux/reducers/auth_reducer.dart';

import '../app_state.dart';
import 'loading_reducer.dart';
import 'tabs_reducer.dart';
import 'task_reducer.dart';
import 'visibility_reducer.dart';

final appReducer = combineReducers<AppState>([
  ...loadingReducer,
  ...tabsReducer,
  ...taskItemsReducer,
  ...sprintVisibilityReducer,
  ...taskVisibilityReducer,
  ...authReducers,
]);