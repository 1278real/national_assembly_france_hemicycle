import 'package:flutter/material.dart';
import 'colors.dart';

class GroupTranscode {
  int index;
  String organeRef;
  String name;
  Color groupeColor;

  GroupTranscode(this.index, this.organeRef, this.name, this.groupeColor);
}

List<GroupTranscode> groupsLegis15 = [
  GroupTranscode(5, "PO730964", "LaREM", renaissanceOrange),
  GroupTranscode(8, "PO730934", "LR", republicainsBleu),
  GroupTranscode(6, "PO774834", "MoDem", modemJaune),
  GroupTranscode(3, "PO758835", "SOC", nupesRose),
  GroupTranscode(0, "PO723569", "NI", nonInscritGris),
  GroupTranscode(7, "PO771923", "AGIR", agirBleu),
  GroupTranscode(9, "PO771889", "UDI", udiBleu),
  GroupTranscode(4, "PO759900", "L&T", territoiresRose),
  GroupTranscode(1, "PO730958", "LFI", nupesViolet),
  GroupTranscode(2, "PO730940", "GDR", nupesRouge),
];

List<GroupTranscode> groupsLegis16 = [
  GroupTranscode(6, "...", "REN", renaissanceOrange),
  GroupTranscode(10, "...", "RN", rnBleu),
  GroupTranscode(1, "...", "LFI", nupesViolet),
  GroupTranscode(9, "...", "LR-UDI", republicainsBleu),
  GroupTranscode(4, "...", "SOC", nupesRose),
  GroupTranscode(3, "...", "EELV", nupesVert),
  GroupTranscode(2, "...", "GDR", nupesRouge),
  GroupTranscode(5, "...", "LIOMT", liomtRose),
  GroupTranscode(7, "...", "MDM", modemJaune),
  GroupTranscode(8, "...", "HRZ", horizonsBleu),
  GroupTranscode(0, "...", "NI", nonInscritGris),
];
