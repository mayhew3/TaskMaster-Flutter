import 'package:flutter/cupertino.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import '../../models/app_tab.dart';
import '../redux_app_state.dart';

class ActiveTab extends StatelessWidget {
  final ViewModelBuilder<AppTab> builder;

  ActiveTab({Key? key, required this.builder}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<ReduxAppState, AppTab>(
      distinct: true,
      converter: (Store<ReduxAppState> store) => store.state.activeTab,
      builder: builder,
    );
  }
}
