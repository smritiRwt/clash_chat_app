import 'package:intl/intl.dart';

class Functions {
  static String convertTimestampToDateTime(String timestamp) {
    var dateTime = DateFormat("yyyy-MM-dd HH:mm:ss").parse(timestamp, true);
    var dateLocal = dateTime.toLocal();
    return dateLocal.toString();
  }
}