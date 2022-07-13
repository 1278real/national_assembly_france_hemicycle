import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hemicycle/attic/helpers.dart';

import 'colors.dart';

extension OtherExtension on String {
  /// Delete ending point of a String if any
  String get deleteEndinPoint {
    if (this.substring(this.length - 1) == ".") {
      return this.substring(0, this.length - 1);
    } else {
      return this;
    }
  }

  String get cleanRawHtmlString {
    return this
        .replaceAll("&#224;", "à")
        .replaceAll("&#225;", "á")
        .replaceAll("&#226;", "â")
        .replaceAll("&#227;", "ã")
        .replaceAll("&#228;", "ä")
        .replaceAll("&#229;", "å")
        .replaceAll("&#230;", "æ")
        .replaceAll("&#231;", "ç")
        .replaceAll("&#232;", "è")
        .replaceAll("&#233;", "é")
        .replaceAll("&#234;", "ê")
        .replaceAll("&#235;", "ë")
        .replaceAll("&#236;", "ì")
        .replaceAll("&#237;", "í")
        .replaceAll("&#238;", "î")
        .replaceAll("&#239;", "ï")
        .replaceAll("&#241;", "ñ")
        .replaceAll("&#242;", "ò")
        .replaceAll("&#243;", "ó")
        .replaceAll("&#244;", "ô")
        .replaceAll("&#245;", "õ")
        .replaceAll("&#246;", "ö")
        .replaceAll("&#249;", "ù")
        .replaceAll("&#250;", "ú")
        .replaceAll("&#251;", "û")
        .replaceAll("&#252;", "ü")
        .replaceAll("&#192;", "À")
        .replaceAll("&#193;", "Á")
        .replaceAll("&#194;", "Â")
        .replaceAll("&#195;", "Ã")
        .replaceAll("&#196;", "Ä")
        .replaceAll("&#197;", "Å")
        .replaceAll("&#198;", "Æ")
        .replaceAll("&#199;", "Ç")
        .replaceAll("&#200;", "È")
        .replaceAll("&#201;", "É")
        .replaceAll("&#202;", "Ê")
        .replaceAll("&#203;", "Ë")
        .replaceAll("&#204;", "Ì")
        .replaceAll("&#205;", "Í")
        .replaceAll("&#206;", "Î")
        .replaceAll("&#207;", "Ï")
        .replaceAll("&#209;", "Ñ")
        .replaceAll("&#210;", "Ò")
        .replaceAll("&#211;", "Ó")
        .replaceAll("&#212;", "Ô")
        .replaceAll("&#213;", "Õ")
        .replaceAll("&#214;", "Ö")
        .replaceAll("&#217;", "Ù")
        .replaceAll("&#218;", "Ú")
        .replaceAll("&#219;", "Û")
        .replaceAll("&#220;", "Ü")
        .replaceAll("<p style=\"text-align: justify;\">", "");
  }
}

/// ### Convert a String [dateString] to DateTime
///
/// • You can specify the [dateSeparator], by default = "/"...
///
/// • You can specify the [hourSeparator], by default = ":"...
///
/// • You can tell if the String contains only the date by putting "true" to [noHour], by default = "false"...
///
/// • You can tell the String pattern in [format], by default = "DMY"...
///
DateTime dateFormatter(String dateString,
    {String dateSeparator = "/",
    String hourSeparator = ":",
    bool noHour = false,
    String format = "DMY"}) {
  // print("dateString = " + dateString);
  DateTime _toReturn = DateTime.now();

  int dayIndex = 0;
  int monthIndex = 1;
  int yearIndex = 2;

  for (var $i = 0; $i < format.length; $i++) {
    if (format[$i] == "D") {
      dayIndex = $i;
    } else if (format[$i] == "M") {
      monthIndex = $i;
    } else if (format[$i] == "Y") {
      yearIndex = $i;
    }
  }

  String _theDate = dateString.split(" ")[0];
  int _theDay = int.parse(_theDate.split(dateSeparator)[dayIndex]);
  int _theMonth = int.parse(_theDate.split(dateSeparator)[monthIndex]);
  int _theYear = int.parse(_theDate.split(dateSeparator)[yearIndex]);
  /*print("&&_" +
      _theDay.toString() +
      "_&&_" +
      _theMonth.toString() +
      "_&&_" +
      _theYear.toString() +
      "_&&");*/

  int _theHour = 0;
  int _theMinute = 0;

  if ((dateString.split(" ").length > 1) && (noHour == false)) {
    String _theTime = dateString.split(" ")[1];
    if (_theTime == "@") {
      _theTime = dateString.split(" ")[2];
      // print("_theTime => CHANGED <= ");
    }
    // print("_theTime => " + _theTime + " <= " + hourSeparator);
    if (_theTime != "@") {
      _theHour = int.parse(_theTime.split(hourSeparator)[0]);
      _theMinute = int.parse(_theTime.split(hourSeparator)[1]);
    }
  }
  // print("##_" + _theHour.toString() + "_##_" + _theMinute.toString() + "_##");

  _toReturn = DateTime(_theYear, _theMonth, _theDay, _theHour, _theMinute);

  // print("%%_" + _toReturn.toString() + "_%%");
  return _toReturn;
}

/// ### Convert a DateTime [date] to String (in French)
///
/// • You can specify the [dateSeparator], by default = "/"...
///
/// • You can specify the [hourSeparator], by default = ":"...
///
/// • You can tell if the String needs to contain [dateOnly] or [hourOnly], by default = "false"...
///
/// • You can tell if the String needs to be [longVersion] or [monthVersion] or [dayVersion], by default = "false"...
///
String dateStringFormatter(DateTime? date,
    {String dateSeparator = "/",
    String hourSeparator = ":",
    bool dateOnly = false,
    bool hourOnly = false,
    bool longVersion = false,
    bool monthVersion = false,
    bool dayVersion = false}) {
  // print(date);
  String _toReturn = "";

  final _receivedDate = date;

  if (_receivedDate != null) {
    String _theDay = _receivedDate.day.toString().forceInitialZeros;
    String _theMonth = _receivedDate.month.toString().forceInitialZeros;
    String _theYear = _receivedDate.year.toString();
    String _theHour = _receivedDate.hour.toString().forceInitialZeros;
    String _theMinute = _receivedDate.minute.toString().forceInitialZeros;

    String _localDateSeparator = dateSeparator;

    if (monthVersion) {
      longVersion = true;
    }

    if (longVersion || dayVersion) {
      _theDay = _receivedDate.day.toString();
      if (_receivedDate.day == 1) {
        _theDay = _theDay + "er";
      }
      _theMonth = moisLongs[_receivedDate.month - 1];
      _localDateSeparator = " ";
    }

    if (monthVersion) {
      _toReturn = "$_theMonth$_localDateSeparator$_theYear";
    } else if (dayVersion) {
      _toReturn = joursLongs[_receivedDate.weekday - 1] + " $_theDay";
    } else if (dateOnly) {
      _toReturn =
          "$_theDay$_localDateSeparator$_theMonth$_localDateSeparator$_theYear";
    } else if (hourOnly) {
      _toReturn = "$_theHour$hourSeparator$_theMinute";
    } else if ((_theHour == "00") && (_theMinute == "00")) {
      _toReturn =
          "$_theDay$_localDateSeparator$_theMonth$_localDateSeparator$_theYear";
    } else {
      _toReturn =
          "$_theDay$_localDateSeparator$_theMonth$_localDateSeparator$_theYear @ $_theHour$hourSeparator$_theMinute";
    }
  } else {
    _toReturn = "—";
  }

  // print(_toReturn);
  return _toReturn;
}

/// Used by dateStringFormatter : short months French
List<String> moisCourts = [
  "Jan",
  "Fév",
  "Mar",
  "Avr",
  "Mai",
  "Jun",
  "Jul",
  "Aoû",
  "Sep",
  "Oct",
  "Nov",
  "Déc"
];

/// Used by dateStringFormatter : long months French
List<String> moisLongs = [
  "Janvier",
  "Février",
  "Mars",
  "Avril",
  "Mai",
  "Juin",
  "Juillet",
  "Août",
  "Septembre",
  "Octobre",
  "Novembre",
  "Décembre"
];

/// Used by dateStringFormatter : short days French
List<String> joursCourts = ["L", "Ma", "Me", "J", "V", "S", "D"];

/// Used by dateStringFormatter : long days French
List<String> joursLongs = [
  "Lundi",
  "Mardi",
  "Mercredi",
  "Jeudi",
  "Vendredi",
  "Samedi",
  "Dimanche"
];

/// ### Generate a Random color among the different custom colors defined...
Color randomColor() {
  List<Color> allCustomColors = [
    nupesVert,
    nupesJaune,
    nupesRouge,
    nupesRose,
    nupesViolet,
    renaissanceOrange,
    republicainsBleu,
    territoiresRose,
    liotRose,
    modemJaune,
    nonInscritGris,
    agirBleu,
    horizonsBleu,
    udiBleu,
    rnBleu
  ];

  int randomInteger = Random().nextInt(allCustomColors.length);

  return allCustomColors[randomInteger];
}

/// ### Generate a CircularProgressIndicator with a received Random color...
Padding circularWait(Color waitColor) {
  return Padding(
    padding: const EdgeInsets.all(15.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
            width: 150,
            height: 150,
            child: CircularProgressIndicator(
              strokeWidth: 10,
              color: waitColor,
            )),
      ],
    ),
  );
}

List<Widget> theDivider() {
  double padding = 15;
  return [
    Padding(padding: EdgeInsets.all(padding)),
    Divider(
      height: 8,
      thickness: 4,
      indent: padding,
      endIndent: padding,
    ),
    Padding(padding: EdgeInsets.all(padding))
  ];
}
