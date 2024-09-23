import 'package:built_value/built_value.dart';
import 'package:redux/redux.dart';
import 'package:taskmaster/timezone_helper.dart';

import '../app_state.dart';

part 'snooze_dialog_viewmodel.g.dart';

abstract class SnoozeDialogViewModel implements Built<SnoozeDialogViewModel, SnoozeDialogViewModelBuilder> {
  TimezoneHelper get timezoneHelper;

  SnoozeDialogViewModel._();
  factory SnoozeDialogViewModel([void Function(SnoozeDialogViewModelBuilder) updates]) = _$SnoozeDialogViewModel;

  static SnoozeDialogViewModel fromStore(Store<AppState> store) {
    return SnoozeDialogViewModel((c) => c
      ..timezoneHelper = store.state.timezoneHelper
    );
  }
}