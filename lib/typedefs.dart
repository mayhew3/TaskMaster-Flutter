import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:taskmaster/models/task_item.dart';

typedef UserUpdater(GoogleSignInAccount account);
typedef IdTokenUpdater(IdTokenResult idToken);

typedef EndLoadingCallback(BuildContext context);

typedef TaskItemRefresher(TaskItem taskItem);

typedef void StateCallback();
typedef void StateSetter(StateCallback stateCallback);
