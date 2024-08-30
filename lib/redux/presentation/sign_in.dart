import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import '../actions/auth_actions.dart';
import '../app_state.dart';

class SignInScreen extends StatelessWidget {

  const SignInScreen({
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
            const Text("You are not currently signed in."),
            ElevatedButton(
              child: const Text('SIGN IN'),
              onPressed: () {
                StoreProvider.of<AppState>(context).dispatch(LogIn());
              },
            ),
          ],
        ),
      ),
    );
  }

}
