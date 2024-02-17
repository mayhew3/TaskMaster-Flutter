// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import '../redux_app_state.dart';
import '../selectors/selectors.dart';

class AppLoading extends StatelessWidget {
  final Widget Function(BuildContext context, bool isLoading) builder;

  AppLoading({Key? key, required this.builder}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<ReduxAppState, bool>(
      distinct: true,
      converter: (Store<ReduxAppState> store) => isLoadingSelector(store.state),
      builder: builder,
    );
  }
}
