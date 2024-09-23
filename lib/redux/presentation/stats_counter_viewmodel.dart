import 'package:built_value/built_value.dart';
import 'package:redux/redux.dart';
import 'package:taskmaster/redux/selectors/selectors.dart';

import '../app_state.dart';

part 'stats_counter_viewmodel.g.dart';

abstract class StatsCounterViewModel implements Built<StatsCounterViewModel, StatsCounterViewModelBuilder> {
  int get numActive;
  int get numCompleted;

  StatsCounterViewModel._();

  factory StatsCounterViewModel([void Function(StatsCounterViewModelBuilder) updates]) = _$StatsCounterViewModel;

  static StatsCounterViewModel fromStore(Store<AppState> store) {
    return StatsCounterViewModel((c) => c
        ..numActive = numActiveSelector(store.state.taskItems)
        ..numCompleted = numCompletedSelector(store.state.taskItems)
    );
  }
}