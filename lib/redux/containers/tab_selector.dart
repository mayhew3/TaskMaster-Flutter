// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:taskmaster/redux/containers/tab_selector_viewmodel.dart';

import '../../keys.dart';
import '../app_state.dart';

class TabSelector extends StatelessWidget {
  TabSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, TabSelectorViewModel>(
      distinct: true,
      converter: TabSelectorViewModel.fromStore,
      builder: (context, vm) {
        return BottomNavigationBar(
          key: TaskMasterKeys.tabs,
          currentIndex: vm.allTabs.indexOf(vm.activeTab),
          onTap: vm.onTabSelected,
          items: vm.allTabs.map((tab) {
            return BottomNavigationBarItem(
              icon: Icon(tab.icon),
              label: tab.label,
            );
          }).toList(),
        );
      },
    );
  }
}
