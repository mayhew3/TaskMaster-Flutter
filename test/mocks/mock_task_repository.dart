import 'package:mockito/mockito.dart';
import 'package:taskmaster/task_repository.dart';
import 'package:flutter/material.dart';

class MockTaskRepository extends Fake implements TaskRepository {
  Future<void> loadTasks(StateSetter stateSetter) async {
    // do nothing;
  }
}