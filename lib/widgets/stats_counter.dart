// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class StatsCounter extends StatelessWidget {
  final int numActive;
  final int numCompleted;

  StatsCounter({
    Key key,
    @required this.numActive,
    @required this.numCompleted})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
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
    );
  }
}
