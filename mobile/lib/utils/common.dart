import 'package:intl/intl.dart';

String getTime(int value, {String formatStr = "hh:mm a"}) {
  var format = DateFormat(formatStr);
  return format.format(
      DateTime.fromMillisecondsSinceEpoch(value * 60 * 1000, isUtc: true));
}

String getStringDateToOtherFormate(String dateStr,
    {String inputFormatStr = "dd/MM/yyyy hh:mm aa",
      String outFormatStr = "hh:mm a"}) {
  var format = DateFormat(outFormatStr);
  return format.format(stringToDate(dateStr, formatStr: inputFormatStr));
}

DateTime stringToDate(String dateStr, {String formatStr = "hh:mm a"}) {
  var format = DateFormat(formatStr);
  return format.parse(dateStr);
}

DateTime dateToStartDate(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

String dateToString(DateTime date, {String formatStr = "dd/MM/yyyy hh:mm a"}) {
  var format = DateFormat(formatStr);
  return format.format(date);
}

String getDayTitle(String dateStr, {String formatStr = "dd/MM/yyyy hh:mm a"} ) {
  var date = stringToDate(dateStr, formatStr: formatStr);

  if (date.isToday) {
    return "Today";
  } else if (date.isTomorrow) {
    return "Tomorrow";
  } else if (date.isYesterday) {
    return "Yesterday";
  } else {
    var outFormat = DateFormat("E");
    return outFormat.format(date) ;
  }
}


List<String> getCurrentWeekDaysDate() {
  var today = DateTime.now();
  List<String> weekDays = [];

  for (int i = -6; i <= 0; i++) {
    var date = today.add(Duration(days: i));
    weekDays.add(DateFormat('d').format(date));
  }

  return weekDays;
}

List<String> getCurrentWeekDays() {
  var today = DateTime.now();
  List<String> weekDays = [];

  for (int i = -6; i <= 0; i++) {
    var date = today.add(Duration(days: i));
    weekDays.add(DateFormat('EEE').format(date));
  }

  return weekDays;
}


extension DateHelpers on DateTime {
  bool get isToday {
    return DateTime(year, month, day).difference(DateTime.now()).inDays == 0;
  }

  bool get isYesterday {
    return DateTime(year, month, day).difference(DateTime.now()).inDays == -1;
  }

  bool get isTomorrow {
    return DateTime(year, month, day).difference(DateTime.now()).inDays == 1;
  }
}
