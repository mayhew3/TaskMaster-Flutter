
class TaskDateHolder {
  DateTime startDate;
  DateTime targetDate;
  DateTime dueDate;
  DateTime completionDate;
  DateTime urgentDate;

  int recurNumber;
  String recurUnit;
  bool recurWait;

  String anchorDateFieldName;

  TaskDateHolder({
    this.anchorDateFieldName
  });

  void setAnchorDate(DateTime dateTime) {
    switch (anchorDateFieldName) {
      case "Due": {
        dueDate = dateTime;
        return;
      }
      case "Urgent": {
        urgentDate = dateTime;
        return;
      }
      case "Target": {
        targetDate = dateTime;
        return;
      }
      case "Start": {
        startDate = dateTime;
        return;
      }
    }
  }

  DateTime getDateFromName(String fieldName) {
    switch (fieldName) {
      case "Due": return dueDate;
      case "Urgent": return urgentDate;
      case "Target": return targetDate;
      case "Start": return startDate;
      default: return null;
    }
  }

  void setDateFromName(String fieldName, DateTime dateTime) {
    switch (fieldName) {
      case "Due": {
        dueDate = dateTime;
        return;
      }
      case "Urgent": {
        urgentDate = dateTime;
        return;
      }
      case "Target": {
        targetDate = dateTime;
        return;
      }
      case "Start": {
        startDate = dateTime;
        return;
      }
    }
  }

}