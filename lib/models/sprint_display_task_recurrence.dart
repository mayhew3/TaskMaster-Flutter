import 'anchor_date.dart';

mixin SprintDisplayTaskRecurrence {
  int? get recurNumber;
  String? get recurUnit;
  bool? get recurWait;

  AnchorDate? get anchorDate;
  int? get recurIteration;
}