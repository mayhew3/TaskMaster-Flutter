import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import '../../keys.dart';
import '../../models/task_colors.dart';
import '../actions/auth_actions.dart';
import '../app_state.dart';

class SplashScreen extends StatelessWidget {

  const SplashScreen({
    Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('TaskMaster 3000'),
        ),
        body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                CircularProgressIndicator(
                  key: TaskMasterKeys.signingIn,
                  color: TaskColors.highlight,
                ),
                const Text("Signing in..."),
              ],
            )
        )
    );
  }

}
