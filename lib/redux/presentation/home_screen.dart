// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:taskmaster/redux/presentation/home_screen_viewmodel.dart';
import 'package:taskmaster/redux/presentation/loading_indicator.dart';
import 'package:taskmaster/redux/presentation/splash.dart';

import '../../keys.dart';
import '../app_state.dart';

class HomeScreen extends StatefulWidget {

  HomeScreen() : super(key: TaskMasterKeys.homeScreen);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, HomeScreenViewModel>(
        builder: (context, viewModel) {
          if (!viewModel.appIsReady()) {
            return SplashScreen(message: 'Signing in...');
          } else if (viewModel.isLoading()) {
            return LoadingIndicator();
          } else {
            return viewModel.activeTab.widgetGetter();
          }
        },
        converter: HomeScreenViewModel.fromStore
    );
  }
}
