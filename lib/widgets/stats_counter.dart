
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:taskmaster/models/app_state.dart';

class StatsCounter extends StatelessWidget {
  final AppState appState;
  final int numActive;
  final int numCompleted;
  final BottomNavigationBar bottomNavigationBar;

  StatsCounter({
    Key key,
    @required this.appState,
    @required this.numActive,
    @required this.numCompleted,
    @required this.bottomNavigationBar, })
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return
      Scaffold(
        appBar: AppBar(
          title: Text(appState.title),
        ),
        body:  Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: Text(
                  'Completed Tasks',
                  style: Theme.of(context).textTheme.title,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 24.0),
                child: Text(
                  '$numCompleted',
                  style: Theme.of(context).textTheme.subhead,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: Text(
                  'Active Tasks',
                  style: Theme.of(context).textTheme.title,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 24.0),
                child: Text(
                  "$numActive",
                  style: Theme.of(context).textTheme.subhead,
                ),
              )
            ],
          ),
        ),
        bottomNavigationBar: bottomNavigationBar,
      );

  }
}
