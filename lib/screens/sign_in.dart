import 'package:taskmaster/models.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter/cupertino.dart';

class SignInScreen extends StatefulWidget {
  final AppState appState;

  SignInScreen({
    @required this.appState,
    Key key,
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
    widget.appState.auth.addGoogleListener();
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
            RaisedButton(
              child: const Text('SIGN IN'),
              onPressed: widget.appState.auth.handleSignIn,
            ),
          ],
        ),
      ),
    );
  }

}