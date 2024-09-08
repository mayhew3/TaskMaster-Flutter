// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:taskmaster/redux/presentation/home_screen_viewmodel.dart';

import '../../keys.dart';
import '../app_state.dart';
import '../containers/tab_selector.dart';

class HomeScreen extends StatefulWidget {
  final void Function() onInit;

  HomeScreen({required this.onInit}) : super(key: TaskMasterKeys.homeScreen);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    widget.onInit();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, HomeScreenViewModel>(
        builder: (context, viewModel) {
          return viewModel.activeTab.widgetGetter(() => TabSelector());
        },
        converter: HomeScreenViewModel.fromStore
    );

  }
}
