import 'package:built_value/built_value.dart';
import 'package:redux/redux.dart';

import '../../timezone_helper.dart';
import '../app_state.dart';

part 'details_screen_viewmodel.g.dart';

abstract class DetailsScreenViewModel implements Built<DetailsScreenViewModel, DetailsScreenViewModelBuilder> {
  TimezoneHelper get timezoneHelper;

  DetailsScreenViewModel._();

  factory DetailsScreenViewModel([void Function(DetailsScreenViewModelBuilder) updates]) = _$DetailsScreenViewModel;

  static DetailsScreenViewModel fromStore(Store<AppState> store) {
    return DetailsScreenViewModel((c) => c
        ..timezoneHelper = store.state.timezoneHelper
    );
  }
}