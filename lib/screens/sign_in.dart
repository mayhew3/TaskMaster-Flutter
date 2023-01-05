import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:taskmaster/app_state.dart';
import 'package:taskmaster/nav_helper.dart';

class SignInScreen extends StatefulWidget {
  final AppState appState;
  final NavHelper navHelper;

  SignInScreen({
    required this.appState,
    required this.navHelper,
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SignInScreenState();
  }
}

class SignInScreenState extends State<SignInScreen> {

  @override
  void initState() {
    super.initState();
    widget.navHelper.updateContext(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.appState.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            const Text("You are not currently signed in."),
            ElevatedButton(
              child: const Text('SIGN IN'),
              onPressed: widget.appState.auth.handleSignIn,
            ),
          ],
        ),
      ),
    );
  }

}