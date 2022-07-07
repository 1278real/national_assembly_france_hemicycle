import 'dart:math';

extension CapExtension on String {
  /// ### CAPS for first character
  String get firstInCaps => '${this[0].toUpperCase()}${this.substring(1)}';

  /// ### All characters in CAPS
  String get allInCaps => this.toUpperCase();

  /// ### All characters in lower case
  String get noneInCaps => this.toLowerCase();

  /// ### CAPS for first character ONLY
  String get onlyFirstInCaps => this.noneInCaps.firstInCaps;

  /// ### Help removing all accents for String comparison
  String removeAccents() {
    String _toReturn = this;

    var withDia =
        'ÀÁÂÃÄÅàáâãäåÒÓÔÕÕÖØòóôõöøÈÉÊËèéêëðÇçÐÌÍÎÏìíîïÙÚÛÜùúûüÑñŠšŸÿýŽž';
    var withoutDia =
        'AAAAAAaaaaaaOOOOOOOooooooEEEEeeeeeCcDIIIIiiiiUUUUuuuuNnSsYyyZz';

    for (int i = 0; i < withDia.length; i++) {
      _toReturn = _toReturn.replaceAll(withDia[i], withoutDia[i]);
    }

    return _toReturn;
  }

  /// Force zeros at the beginning of given String, for hour:minute or day/month/year display when using integers...
  String get forceInitialZeros {
    String _toReturn = "00" + this;
    return _toReturn.substring(_toReturn.length - 2, _toReturn.length);
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

/// Round a double input [aArrondir] to [nbDecimales] decimals (if not provided, 2 decimals)
double roundToNDecimals(double aArrondir, {int nbDecimales = 2}) {
  var tempValue = (aArrondir * pow(10, nbDecimales.toDouble())).round();
  return tempValue / pow(10, nbDecimales.toDouble());
}

/// Provide a plus or a minus sign, and round a double input [aArrondir] to [nbDecimales] decimals (if not provided, 2 decimals)
String signedRoundToNDecimals(double aArrondir, {int nbDecimales = 2}) {
  var tempValue = (aArrondir * pow(10, nbDecimales.toDouble())).round();
  double toSign = tempValue / pow(10, nbDecimales.toDouble());
  return (toSign > 0 ? "+" + toSign.toString() : toSign.toString());
}
