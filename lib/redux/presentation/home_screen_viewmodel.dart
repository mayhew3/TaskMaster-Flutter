

import 'package:built_value/built_value.dart';
import 'package:redux/redux.dart';
import 'package:taskmaster/models/top_nav_item.dart';

import '../app_state.dart';

part 'home_screen_viewmodel.g.dart';

abstract class HomeScreenViewModel implements Built<HomeScreenViewModel, HomeScreenViewModelBuilder> {

  TopNavItem get activeTab;

  HomeScreenViewModel._();

  factory HomeScreenViewModel([void Function(HomeScreenViewModelBuilder) updates]) = _$HomeScreenViewModel;

  static HomeScreenViewModel fromStore(Store<AppState> store) {
    return HomeScreenViewModel((c) => c
      ..activeTab = store.state.activeTab.toBuilder()
    );
  }
}
