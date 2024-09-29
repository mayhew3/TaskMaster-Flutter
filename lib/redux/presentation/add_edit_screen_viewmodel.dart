import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:redux/redux.dart';
import 'package:taskmaster/models/models.dart';

import '../app_state.dart';

part 'add_edit_screen_viewmodel.g.dart';

abstract class AddEditScreenViewModel implements Built<AddEditScreenViewModel, AddEditScreenViewModelBuilder> {
  BuiltList<TaskItem> get allTaskItems;

  AddEditScreenViewModel._();

  factory AddEditScreenViewModel([void Function(AddEditScreenViewModelBuilder) updates]) = _$AddEditScreenViewModel;

  static AddEditScreenViewModel fromStore(Store<AppState> store) {
    return AddEditScreenViewModel((c) => c
      ..allTaskItems = store.state.taskItems.toBuilder()
    );
  }
}