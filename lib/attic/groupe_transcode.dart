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
  GroupTranscode(1, "...", "LFI", nupesViolet),
  GroupTranscode(2, "...", "EELV", nupesVert),
  GroupTranscode(3, "...", "GDR", nupesRouge),
  GroupTranscode(4, "...", "SOC", nupesRose),
  GroupTranscode(5, "...", "LIOMT", liomtRose),
  GroupTranscode(6, "...", "REN", renaissanceOrange),
  GroupTranscode(7, "...", "DEM", modemJaune),
  GroupTranscode(8, "...", "HRZ", horizonsBleu),
  GroupTranscode(9, "...", "LR-UDI", republicainsBleu),
  GroupTranscode(10, "...", "RN", rnBleu),
  GroupTranscode(99, "...", "NI", nonInscritGris),
];
