import 'package:built_value/built_value.dart';
import 'package:redux/redux.dart';

import '../app_state.dart';

part 'add_edit_screen_viewmodel.g.dart';

abstract class AddEditScreenViewModel implements Built<AddEditScreenViewModel, AddEditScreenViewModelBuilder> {
  bool get updating;

  AddEditScreenViewModel._();

  factory AddEditScreenViewModel([void Function(AddEditScreenViewModelBuilder) updates]) = _$AddEditScreenViewModel;

  static AddEditScreenViewModel fromStore(Store<AppState> store) {
    return AddEditScreenViewModel((c) => c
      ..updating = store.state.updating
    );
  }
}