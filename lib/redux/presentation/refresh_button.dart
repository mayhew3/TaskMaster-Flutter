import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import '../actions/task_item_actions.dart';
import '../app_state.dart';

class RefreshButton extends StatelessWidget {
  RefreshButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
        icon: Icon(Icons.refresh),
        onPressed: () => StoreProvider.of<AppState>(context).dispatch(DataNotLoadedAction())
    );
  }
}