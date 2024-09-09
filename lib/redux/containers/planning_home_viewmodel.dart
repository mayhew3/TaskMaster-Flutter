import 'package:built_value/built_value.dart';
import 'package:redux/redux.dart';
import 'package:taskmaster/models/models.dart';
import 'package:taskmaster/redux/selectors/selectors.dart';

import '../app_state.dart';

part 'planning_home_viewmodel.g.dart';

abstract class PlanningHomeViewModel implements Built<PlanningHomeViewModel, PlanningHomeViewModelBuilder> {
  Sprint? get activeSprint;

  PlanningHomeViewModel._();

  factory PlanningHomeViewModel([void Function(PlanningHomeViewModelBuilder) updates]) = _$PlanningHomeViewModel;

  static PlanningHomeViewModel fromStore(Store<AppState> store) {
    return PlanningHomeViewModel((c) {
      var activeSprint = activeSprintSelector(store.state.sprints);
      if (activeSprint != null) {
        c..activeSprint = activeSprint.toBuilder();
      }
    }
    );
  }
}