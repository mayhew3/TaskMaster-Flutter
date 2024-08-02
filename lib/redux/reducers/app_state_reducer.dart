import 'package:redux/redux.dart';

import '../redux_app_state.dart';
import 'loading_reducer.dart';
import 'tabs_reducer.dart';
import 'task_reducer.dart';
import 'visibility_reducer.dart';

final appReducer = combineReducers<ReduxAppState>([
  ...loadingReducer,
  ...tabsReducer,
  ...taskItemsReducer,
  ...sprintVisibilityReducer,
  ...taskVisibilityReducer,
]);