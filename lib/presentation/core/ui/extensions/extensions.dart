import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:sales_rep_visit_tracker_feature/data/utils/toast_message.dart';

extension DateFormatter on DateTime {
  String get humanReadable {
    String dayWithSuffix = '$day${day.daySuffix}';

    // Format weekday and month
    String weekday = DateFormat('E').format(this);
    String month = DateFormat('MMMM').format(this);
    String time = DateFormat('h:mm a').format(this);
    return '$weekday, $dayWithSuffix $month at $time';
  }

  String get readableDate => DateFormat('dd/MM/yyyy').format(this);
  String get readableTime => DateFormat('h:mm a').format(this);
  String get readableDateTime2Line => "$readableDate \n $readableTime";
}

extension DateSuffix on int {
  String get daySuffix {
    if (this >= 11 && this <= 13) return 'th';
    return switch (this % 10) {
      1 => 'st',
      2 => 'nd',
      3 => 'rd',
      _ => 'th'
    };
  }
}

extension ShowFlutterToast on ToastMessage {
  show() {

    Color backgroundColor = switch(this) {
      InfoMessage() => Colors.blue,
      ErrorMessage() => Colors.red,
      SuccessMessage() => Colors.green,
    };

    Color textColor = switch(this) {
      InfoMessage() => Colors.white,
      ErrorMessage() => Colors.white,
      SuccessMessage() => Colors.black,
    };

    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: backgroundColor,
      textColor: textColor,
      fontSize: 16.0,
    );
  }
}

