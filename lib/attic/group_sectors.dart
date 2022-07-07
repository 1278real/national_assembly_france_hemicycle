import 'dart:collection';

import 'package:flutter/material.dart';

class GroupSectors with IterableMixin<GroupSectors> {
  int nbElements;
  Color sectorColor;
  String? description;

  /// ### Creates a group of dots a.k.a sector that has the same color :
  ///
  /// • [nbElements] is the number of elements that should be colored that way.
  ///
  /// • [sectorColor] is the color of the group.
  ///
  /// • [description] is a nullable String used in the Legend if displayed. If not provided, replaced by the [sectorColor] description #RRGGBB.
  GroupSectors(this.nbElements, this.sectorColor, {this.description});

  /// [sectorColorString] is the default String if no description is provided for Legend :
  String get sectorColorString {
    return "#" +
        sectorColor.red.toRadixString(16) +
        sectorColor.green.toRadixString(16) +
        sectorColor.blue.toRadixString(16);
  }

  @override
  Iterator<GroupSectors> get iterator => throw UnimplementedError();
}
