
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:redux/redux.dart';

import '../../models/top_nav_item.dart';
import '../actions/actions.dart';
import '../app_state.dart';

part 'tab_selector_viewmodel.g.dart';

abstract class TabSelectorViewModel implements Built<TabSelectorViewModel, TabSelectorViewModelBuilder> {
  TopNavItem get activeTab;
  BuiltList<TopNavItem> get allTabs;
  Function(int) get onTabSelected;

  TabSelectorViewModel._();

  factory TabSelectorViewModel([void Function(TabSelectorViewModelBuilder) updates]) = _$TabSelectorViewModel;

  static TabSelectorViewModel fromStore(Store<AppState> store) {
    return TabSelectorViewModel((c) => c
      ..activeTab = store.state.activeTab.toBuilder()
        ..allTabs = store.state.allNavItems.toBuilder()
        ..onTabSelected = (index) {
          store.dispatch(UpdateTabAction(store.state.allNavItems.toList()[index]));
        }
    );
  }

}
