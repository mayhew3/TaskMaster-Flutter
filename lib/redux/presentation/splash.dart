import 'package:flutter/material.dart';

import '../../keys.dart';
import '../../models/task_colors.dart';

class SplashScreen extends StatelessWidget {
  final String message;

  const SplashScreen({
    required this.message,
    super.key});

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
                Text(message),
              ],
            )
        )
    );
  }

}
