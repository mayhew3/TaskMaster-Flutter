

import 'package:built_value/built_value.dart';
import 'package:redux/redux.dart';
import '../app_state.dart';

part 'loading_screen_viewmodel.g.dart';

abstract class LoadingScreenViewModel implements Built<LoadingScreenViewModel, LoadingScreenViewModelBuilder> {

  LoadingScreenViewModel._();

  factory LoadingScreenViewModel([void Function(LoadingScreenViewModelBuilder) updates]) = _$LoadingScreenViewModel;

  static LoadingScreenViewModel fromStore(Store<AppState> store) {
    return LoadingScreenViewModel((c) => c

    );
  }
}
