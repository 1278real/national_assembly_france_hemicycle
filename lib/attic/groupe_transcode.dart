import 'package:flutter/material.dart';
import 'colors.dart';

class GroupTranscode {
  int index;
  String organeRef;
  String name;
  Color groupeColor;

  GroupTranscode(this.index, this.organeRef, this.name, this.groupeColor);
}

/// Legislature XV : 2017-2022
List<GroupTranscode> groupsLegis15 = [
  GroupTranscode(1, "PO730958", "LFI", nupesViolet),
  GroupTranscode(2, "PO730940", "GDR", nupesRouge),
  GroupTranscode(3, "PO758835", "SOC", nupesRose),
  GroupTranscode(4, "PO759900", "L&T", territoiresRose),
  GroupTranscode(5, "PO730964", "LaREM", renaissanceOrange),
  GroupTranscode(6, "PO774834", "MoDem", modemJaune),
  GroupTranscode(7, "PO771923", "AGIR", agirBleu),
  GroupTranscode(8, "PO730934", "LR", republicainsBleu),
  GroupTranscode(9, "PO771889", "UDI", udiBleu),
  GroupTranscode(99, "PO723569", "NI", nonInscritGris),
];

/// Legislature XVI : 2022-...
List<GroupTranscode> groupsLegis16 = [
  GroupTranscode(1, "PO800490", "LFI", nupesViolet),
  GroupTranscode(2, "PO800502", "GDR", nupesRouge),
  GroupTranscode(3, "PO800526", "ECOLO", nupesVert),
  GroupTranscode(4, "PO800496", "SOC", nupesRose),
  GroupTranscode(5, "PO800532", "LIOT", liotRose),
  GroupTranscode(6, "PO800538", "RE", renaissanceOrange),
  GroupTranscode(7, "PO800484", "DEM", modemJaune),
  GroupTranscode(8, "PO800514", "HOR", horizonsBleu),
  GroupTranscode(9, "PO800508", "LR", republicainsBleu),
  GroupTranscode(10, "PO800520", "RN", rnBleu),
  GroupTranscode(99, "PO793087", "NI", nonInscritGris),
];
