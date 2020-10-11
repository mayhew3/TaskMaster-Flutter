
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../typedefs.dart';

class PlanningHome extends StatelessWidget {

  final BottomNavigationBarGetter bottomNavigationBarGetter;

  PlanningHome({
    Key key,
    @required this.bottomNavigationBarGetter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Planning'),
      ),
      body: Center(
        child: Text('Planning!'),
      ),
      bottomNavigationBar: bottomNavigationBarGetter(),
    );
  }

}