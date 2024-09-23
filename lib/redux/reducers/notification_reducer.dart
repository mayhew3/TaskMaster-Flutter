import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:redux/redux.dart';
import 'package:taskmaster/redux/actions/notification_actions.dart';
import 'package:taskmaster/redux/app_state.dart';

final notificationsReducer = <AppState Function(AppState, dynamic)>[
  TypedReducer<AppState, UpdateNotificationBadge>(_updateNotificationBadge)
];

AppState _updateNotificationBadge(AppState state, UpdateNotificationBadge action) {
  var urgentCount = state.taskItems.where((taskItem) => (taskItem.isUrgent() || taskItem.isPastDue()) && taskItem.completionDate == null).length;
  FlutterAppBadger.updateBadgeCount(urgentCount);
  return state;
}