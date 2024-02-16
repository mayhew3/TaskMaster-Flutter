import 'package:redux/redux.dart';
import '../actions/actions.dart';

final loadingReducer = combineReducers<bool>([
  TypedReducer<bool, TaskItemsLoadedAction>(_setLoaded),
  TypedReducer<bool, TaskItemsNotLoadedAction>(_setLoaded),
]);

bool _setLoaded(bool state, action) {
  return false;
}
