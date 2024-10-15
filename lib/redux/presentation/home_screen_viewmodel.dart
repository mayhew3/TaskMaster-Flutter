

import 'package:built_value/built_value.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:redux/redux.dart';
import 'package:taskmaster/models/top_nav_item.dart';
import 'package:taskmaster/timezone_helper.dart';

import '../app_state.dart';

part 'home_screen_viewmodel.g.dart';

abstract class HomeScreenViewModel implements Built<HomeScreenViewModel, HomeScreenViewModelBuilder> {

  TopNavItem get activeTab;

  bool get tasksLoading;
  bool get sprintsLoading;
  bool get taskRecurrencesLoading;

  GoogleSignInAccount? get currentUser;
  UserCredential? get firebaseUser;
  String? get personDocId;
  TimezoneHelper get timezoneHelper;

  HomeScreenViewModel._();

  bool appIsReady() {
    return currentUser != null && firebaseUser?.user != null && personDocId != null && timezoneHelper.timezoneInitialized;
  }

  bool isLoading() {
    return tasksLoading || sprintsLoading || taskRecurrencesLoading;
  }

  factory HomeScreenViewModel([void Function(HomeScreenViewModelBuilder) updates]) = _$HomeScreenViewModel;

  static HomeScreenViewModel fromStore(Store<AppState> store) {
    return HomeScreenViewModel((c) => c
      ..activeTab = store.state.activeTab.toBuilder()
      ..tasksLoading = store.state.tasksLoading
      ..sprintsLoading = store.state.sprintsLoading
      ..taskRecurrencesLoading = store.state.taskRecurrencesLoading
      ..currentUser = store.state.currentUser
      ..personDocId = store.state.personDocId
      ..timezoneHelper = store.state.timezoneHelper
      ..firebaseUser = store.state.firebaseUser
    );
  }
}
