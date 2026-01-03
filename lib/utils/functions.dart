
class Functions {
  static String convertTimestampToDateTime(String timestamp) {
    var dateTime = DateTime.parse(timestamp).toLocal();
    return dateTime.toString();
  }
}