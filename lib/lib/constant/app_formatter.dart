import 'dart:developer';

import 'package:intl/intl.dart';

class AppFormatter {
  static String dateFormater({required String date}) {
    if (date == 'N/A') {
      return 'N/A';
    } else {
      DateTime parsedDate = DateTime.parse(date);
      String formattedDate = DateFormat('dd-MM-yyyy').format(parsedDate);
      return formattedDate;
    }
  }

  static String timeFormater({required String date}) {
    if (date == 'N/A') {
      return 'N/A';
    } else {
      DateTime dateTime = DateFormat('yyyy-MM-dd HH:mm:ss').parse(date);
      String formattedTime = DateFormat('hh:mm a').format(dateTime);
      return formattedTime;
    }
  }

  static String onlyTimeFormatter(String timeString) {

    try {
      DateTime time = DateFormat("hh:mm a").parse(timeString);

      String formattedTime = DateFormat("HH:mm:ss").format(time);

      return formattedTime;
    } catch (e) {
      log("❌ Error parsing time: $e");
      return '';
    }
  }
}
