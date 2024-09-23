import 'package:built_value/built_value.dart';
import 'package:redux/redux.dart';
import 'package:taskmaster/redux/selectors/selectors.dart';
import 'package:taskmaster/timezone_helper.dart';

import '../../models/sprint.dart';
import '../app_state.dart';

part 'new_sprint_viewmodel.g.dart';

abstract class NewSprintViewModel implements Built<NewSprintViewModel, NewSprintViewModelBuilder> {
  TimezoneHelper get timezoneHelper;
  Sprint? get activeSprint;
  Sprint? get lastCompleted;

  NewSprintViewModel._();

  factory NewSprintViewModel([void Function(NewSprintViewModelBuilder) updates]) = _$NewSprintViewModel;

  static NewSprintViewModel fromStore(Store<AppState> store) {
    return NewSprintViewModel((c) => c
      ..timezoneHelper = store.state.timezoneHelper
      ..activeSprint = activeSprintSelector(store.state.sprints)?.toBuilder()
      ..lastCompleted = lastCompletedSprintSelector(store.state.sprints)?.toBuilder()
    );
  }
}