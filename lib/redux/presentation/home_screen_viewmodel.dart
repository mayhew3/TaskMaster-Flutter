
// ignore: prefer_double_quotes
import 'package:built_value/built_value.dart';
import 'package:redux/redux.dart';

import '../../models/app_tab.dart';
import '../app_state.dart';

part 'home_screen_viewmodel.g.dart';

abstract class HomeScreenViewModel implements Built<HomeScreenViewModel, HomeScreenViewModelBuilder> {

  bool get showCompleted;
  bool get showScheduled;
  AppTab get activeTab;

  HomeScreenViewModel._();

  factory HomeScreenViewModel([void Function(HomeScreenViewModelBuilder) updates]) = _$HomeScreenViewModel;

  static HomeScreenViewModel fromStore(Store<AppState> store) {
    return HomeScreenViewModel((c) => c
      ..showCompleted = store.state.taskListFilter.showCompleted
      ..showScheduled = store.state.taskListFilter.showScheduled
      ..activeTab = store.state.activeTab
    );
  }
}
