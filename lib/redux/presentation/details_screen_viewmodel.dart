import 'package:built_value/built_value.dart';
import 'package:redux/redux.dart';
import 'package:taskmaster/models/models.dart';
import 'package:taskmaster/redux/selectors/selectors.dart';

import '../../timezone_helper.dart';
import '../app_state.dart';

part 'details_screen_viewmodel.g.dart';

abstract class DetailsScreenViewModel implements Built<DetailsScreenViewModel, DetailsScreenViewModelBuilder> {
  TaskItem get taskItem;
  TimezoneHelper get timezoneHelper;

  DetailsScreenViewModel._();

  factory DetailsScreenViewModel([void Function(DetailsScreenViewModelBuilder) updates]) = _$DetailsScreenViewModel;

  static DetailsScreenViewModel fromStore(Store<AppState> store, String taskItemId) {
    return DetailsScreenViewModel((c) => c
      ..taskItem = taskItemSelector(store.state.taskItems, taskItemId)!.toBuilder()
      ..timezoneHelper = store.state.timezoneHelper
    );
  }
}