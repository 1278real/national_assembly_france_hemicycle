import 'package:flutter/material.dart';

extension ColorExtension on String {
  toColor() {
    var hexColor = this.replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    if (hexColor.length == 8) {
      return Color(int.parse("0x$hexColor"));
    }
  }
}

Map<int, Color> color = {
  50: Color.fromRGBO(0, 0, 0, .1),
  100: Color.fromRGBO(0, 0, 0, .2),
  200: Color.fromRGBO(0, 0, 0, .3),
  300: Color.fromRGBO(0, 0, 0, .4),
  400: Color.fromRGBO(0, 0, 0, .5),
  500: Color.fromRGBO(0, 0, 0, .6),
  600: Color.fromRGBO(0, 0, 0, .7),
  700: Color.fromRGBO(0, 0, 0, .8),
  800: Color.fromRGBO(0, 0, 0, .9),
  900: Color.fromRGBO(0, 0, 0, 1),
};

/// RED color for standard warning
MaterialColor customRouge = MaterialColor(0xFF990000, color);

/// GREEN color for vote FOR
MaterialColor customVoteFor = MaterialColor(0xFF099509, color);

/// RED color for vote AGAINST
MaterialColor customVoteAgainst = MaterialColor(0xFFA00D0B, color);

/// MIDDLE GREY color for vote ABSTENTION
MaterialColor customVoteAbstention = MaterialColor(0xFF616161, color);

/// LIGHT GREY color for NO vote
MaterialColor customNoVote = MaterialColor(0xFFD2D2D2, color);
