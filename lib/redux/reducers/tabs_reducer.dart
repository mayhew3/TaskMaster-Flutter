import 'package:redux/redux.dart';

import '../actions/actions.dart';
import '../redux_app_state.dart';

final tabsReducer = <ReduxAppState Function(ReduxAppState, dynamic)>[
  TypedReducer<ReduxAppState, UpdateTabAction>(_activeTabReducer),
];

ReduxAppState _activeTabReducer(ReduxAppState state, UpdateTabAction action) {
  return state.rebuild((s) => s..activeTab = action.newTab);
}
