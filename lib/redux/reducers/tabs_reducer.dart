import 'package:built_collection/built_collection.dart';
import 'package:redux/redux.dart';

import '../actions/actions.dart';
import '../app_state.dart';

final tabsReducer = <AppState Function(AppState, dynamic)>[
  TypedReducer<AppState, UpdateTabAction>(_activeTabReducer),
];

AppState _activeTabReducer(AppState state, UpdateTabAction action) {
  return state.rebuild((s) {
    if (action.newTab.label != s.activeTab.label) {
      s.recentlyCompleted = ListBuilder();
    }
    s.activeTab = action.newTab.toBuilder();
    return s;
  });
}
