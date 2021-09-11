
class ParseHelper {

  static String? cleanString(String? str) {
    if (str == null) {
      return null;
    } else {
      var trimmed = str.trim();
      if (trimmed.isEmpty) {
        return null;
      } else {
        return trimmed;
      }
    }
  }

  static int? parseInt(String? str) {
    if (str == null) {
      return null;
    }
    var cleanString = ParseHelper.cleanString(str);
    return cleanString == null ? null : int.parse(str);
  }

}