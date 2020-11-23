
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:taskmaster/app_state.dart';
import 'package:taskmaster/typedefs.dart';

class StatsCounter extends StatelessWidget {
  final AppState appState;
  final int numActive;
  final int numCompleted;
  final BottomNavigationBarGetter bottomNavigationBarGetter;

  StatsCounter({
    Key key,
    @required this.appState,
    @required this.numActive,
    @required this.numCompleted,
    @required this.bottomNavigationBarGetter, })
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return
      Scaffold(
        appBar: AppBar(
          title: Text('Stats'),
        ),
        body:  Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: Text(
                  'Completed Tasks',
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 24.0),
                child: Text(
                  '$numCompleted',
                  style: Theme.of(context).textTheme.subtitle1,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: Text(
                  'Active Tasks',
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 24.0),
                child: Text(
                  "$numActive",
                  style: Theme.of(context).textTheme.subtitle1,
                ),
              )
            ],
          ),
        ),
        bottomNavigationBar: bottomNavigationBarGetter(),
      );

  }
}
