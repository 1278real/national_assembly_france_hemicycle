import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'colors.dart';
import 'element_attributes.dart';
import 'group_sectors.dart';
import 'helpers.dart';
import 'individual_votes.dart';

class DrawHemicycle extends StatefulWidget {
  final int assemblyElements;
  final double? assemblyAngle;
  final double? assemblyWidth;
  final List<IndividualVotes>? individualVotes;
  final List<GroupSectors>? groupSectors;
  final MaterialColor? backgroundColor;
  final bool? withLegend;
  final int? minLegendRows;
  final bool? withTitle;
  final String? title;
  final int? nbRows;

  /// ### Creates a widget with Assembly view defined by these parameters :
  ///
  /// • [assemblyElements] is the number of elements to draw. It is required.
  ///
  /// • [assemblyAngle] is the value of the arc of the Assembly expressed in degrees. By default, if not provided, it is 170°.
  ///
  /// • [assemblyWidth] is the ratio of the Assembly inside the container. Will be discontinued, should not be used. Don't provide or set to 1.
  ///
  /// • [individualVotes] is a nullable List<IndividualVotes> : if not provided, then [groupSectors] should not be null. It will display individual color for each dot.
  ///
  /// • [groupSectors] is a nullable List<GroupSectors> : if not provided, then [individualVotes] should not be null. It will display color per sector for contiguous dot.
  ///
  /// • [withLegend] is a boolean that display or not the Legend. To force a minimal number of rows, provide [minLegendRows].
  ///
  /// • [withTitle] is a boolean that display or not the Title. It needs [title] String to be provided to display.
  ///
  /// • [nbRows] is the number of rows in the Assembly representation. By default, if not provided, it is 12.
  DrawHemicycle(this.assemblyElements,
      {this.assemblyAngle,
      this.assemblyWidth,
      this.individualVotes,
      this.groupSectors,
      this.backgroundColor,
      this.withLegend,
      this.minLegendRows,
      this.withTitle,
      this.title,
      this.nbRows})
      : super();

  @override
  _DrawHemicycleState createState() => _DrawHemicycleState(
      assemblyElements: assemblyElements,
      assemblyAngle: assemblyAngle ?? 170,
      assemblyWidth: assemblyWidth ?? 1,
      individualVotes: individualVotes,
      groupSectors: groupSectors,
      backgroundColor: backgroundColor,
      withLegend: withLegend ?? false,
      minLegendRows: minLegendRows,
      withTitle: withTitle ?? false,
      title: title,
      nbRows: nbRows);
}

class _DrawHemicycleState extends State<DrawHemicycle> {
  int assemblyElements;
  double assemblyAngle;
  double assemblyWidth;
  late List<IndividualVotes>? individualVotes;
  late List<GroupSectors>? groupSectors;
  late MaterialColor? backgroundColor;
  bool withLegend;
  late int? minLegendRows;
  bool withTitle;
  late String? title;
  late int? nbRows;

  _DrawHemicycleState(
      {required this.assemblyElements,
      required this.assemblyAngle,
      required this.assemblyWidth,
      this.individualVotes,
      this.groupSectors,
      this.backgroundColor,
      required this.withLegend,
      this.minLegendRows,
      required this.withTitle,
      this.title,
      this.nbRows})
      : super();

  @override
  Widget build(BuildContext context) {
    // print("backgroundColor = " + backgroundColor.toString());

    int maxCharactersInRow =
        (35 * roundToNDecimals(assemblyWidth, nbDecimales: 1)).floor();

    int legendItems = 0;
    int legendMaxSize = 1;
    int legendRows = 0;
    int legendCols = 0;
    if (withLegend && groupSectors != null) {
      for (GroupSectors sector in groupSectors!) {
        legendItems += 1;
        if (sector.description != null) {
          if (sector.description!.length > legendMaxSize) {
            legendMaxSize = sector.description!.length;
          }
        }
      }

      // print("legendItems = " + legendItems.toString() + " / legendMaxSize = " + legendMaxSize.toString());

      int _legendCols =
          math.min(legendItems, ((maxCharactersInRow / legendMaxSize).floor()));
      legendRows = (legendItems / _legendCols).ceil();
      legendCols = (legendItems / legendRows).ceil();

      if (minLegendRows != null) {
        legendRows = math.max(minLegendRows!, legendRows);
      }

      // print("legendCols = " + legendCols.toString() + " / legendRows = " + legendRows.toString());
    } else if (withLegend && individualVotes != null) {
      legendItems = 7;
      legendRows = 3;
      legendCols = 3;
    }

    return Container(
        width: MediaQuery.of(context).size.width * assemblyWidth,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Stack(children: [
            if (withTitle && title != null)
              Container(
                  width: MediaQuery.of(context).size.width * assemblyWidth,
                  height: (MediaQuery.of(context).size.width *
                          (math.max(
                                  1.0,
                                  (1 -
                                      math.sin(
                                          assemblyAngle / 360 * 2 * math.pi))) /
                              2)) *
                      0.15,
                  alignment: Alignment.bottomCenter,
                  child: Text(
                    title!,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w900),
                  )),
            if (withLegend && groupSectors != null)
              Container(
                  width: MediaQuery.of(context).size.width * assemblyWidth,
                  height: (MediaQuery.of(context).size.width *
                          (math.max(
                                  1.0,
                                  (1 -
                                      math.sin(
                                          assemblyAngle / 360 * 2 * math.pi))) /
                              2)) *
                      ((legendRows * 0.2) + (withTitle ? 0.2 : 0)),
                  child: Column(
                    children: [
                      if (withTitle && title != null)
                        Padding(
                            padding: EdgeInsets.all(
                                (MediaQuery.of(context).size.width *
                                        (math.max(
                                                1.0,
                                                (1 -
                                                    math.sin(assemblyAngle /
                                                        360 *
                                                        2 *
                                                        math.pi))) /
                                            2)) *
                                    0.1)),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (var i = 0; i < legendCols; i++)
                              Padding(
                                padding: EdgeInsets.all(6),
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      for (var j = 0; j < legendRows; j++)
                                        if ((i * legendRows + j) < legendItems)
                                          Row(
                                            children: [
                                              Container(
                                                  width: 10,
                                                  height: 10,
                                                  color: groupSectors![
                                                          i * legendRows + j]
                                                      .sectorColor),
                                              Padding(
                                                  padding: EdgeInsets.all(2)),
                                              Text(groupSectors![
                                                          i * legendRows + j]
                                                      .description ??
                                                  groupSectors![
                                                          i * legendRows + j]
                                                      .sectorColorString),
                                            ],
                                          ),
                                    ]),
                              ),
                          ]),
                    ],
                  )),
            if (withLegend && individualVotes != null)
              Container(
                  width: MediaQuery.of(context).size.width * assemblyWidth,
                  height: (MediaQuery.of(context).size.width *
                          (math.max(
                                  1.0,
                                  (1 -
                                      math.sin(
                                          assemblyAngle / 360 * 2 * math.pi))) /
                              2)) *
                      ((legendRows * 0.2) + (withTitle ? 0.2 : 0)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (withTitle && title != null)
                        Padding(
                            padding: EdgeInsets.all(
                                (MediaQuery.of(context).size.width *
                                        (math.max(
                                                1.0,
                                                (1 -
                                                    math.sin(assemblyAngle /
                                                        360 *
                                                        2 *
                                                        math.pi))) /
                                            2)) *
                                    0.1)),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.all(6),
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "POUR",
                                      style: TextStyle(
                                          color: customVoteFor,
                                          fontWeight: FontWeight.w900),
                                    ),
                                    Row(
                                      children: [
                                        Container(
                                            width: 10,
                                            height: 10,
                                            color: customVoteFor),
                                        Padding(padding: EdgeInsets.all(2)),
                                        Text(
                                          "≠ groupe",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Container(
                                            width: 10,
                                            height: 10,
                                            color:
                                                customVoteFor.withOpacity(0.3)),
                                        Padding(padding: EdgeInsets.all(2)),
                                        Text(
                                          "= groupe",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ],
                                    ),
                                  ]),
                            ),
                            Padding(
                              padding: EdgeInsets.all(6),
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "CONTRE",
                                      style: TextStyle(
                                          color: customVoteAgainst,
                                          fontWeight: FontWeight.w900),
                                    ),
                                    Row(
                                      children: [
                                        Container(
                                            width: 10,
                                            height: 10,
                                            color: customVoteAgainst),
                                        Padding(padding: EdgeInsets.all(2)),
                                        Text(
                                          "≠ groupe",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Container(
                                            width: 10,
                                            height: 10,
                                            color: customVoteAgainst
                                                .withOpacity(0.3)),
                                        Padding(padding: EdgeInsets.all(2)),
                                        Text(
                                          "= groupe",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ],
                                    ),
                                  ]),
                            ),
                            Padding(
                              padding: EdgeInsets.all(6),
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "ABST°",
                                      style: TextStyle(
                                          color: customVoteAbstention,
                                          fontWeight: FontWeight.w900),
                                    ),
                                    Row(
                                      children: [
                                        Container(
                                            width: 10,
                                            height: 10,
                                            color: customVoteAbstention),
                                        Padding(padding: EdgeInsets.all(2)),
                                        Text(
                                          "≠ groupe",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Container(
                                            width: 10,
                                            height: 10,
                                            color: customVoteAbstention
                                                .withOpacity(0.3)),
                                        Padding(padding: EdgeInsets.all(2)),
                                        Text(
                                          "= groupe",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ],
                                    ),
                                  ]),
                            ),
                          ]),
                    ],
                  )),
            Container(
              width: MediaQuery.of(context).size.width * assemblyWidth,
              height: (MediaQuery.of(context).size.width *
                      assemblyWidth *
                      (math.max(
                              1.0,
                              (1 -
                                  math.sin(
                                      assemblyAngle / 360 * 2 * math.pi))) /
                          2)) *
                  (((legendRows *
                              (groupSectors != null ? 0.1 : 0.1) /
                              assemblyWidth) +
                          (withTitle ? (0.15 / assemblyWidth) : 0)) +
                      1.15),
              color: backgroundColor ?? null,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: CustomPaint(
                  painter: AssemblyPainter(
                      assemblyAngle: assemblyAngle,
                      assemblyElements: assemblyElements,
                      assemblyWidth: assemblyWidth,
                      viewWidth:
                          MediaQuery.of(context).size.width * assemblyWidth,
                      individualVotes: individualVotes,
                      groupSectors: groupSectors,
                      nbRows: nbRows ?? 12),
                ),
              ),
            ),
          ]),
        ));
  }
}

class AssemblyPainter extends CustomPainter {
  final double assemblyAngle;
  final int assemblyElements;

  double assemblyWidth;
  double viewWidth;
  final List<IndividualVotes>? individualVotes;
  final List<GroupSectors>? groupSectors;
  final int nbRows;

  AssemblyPainter(
      {required this.assemblyAngle,
      required this.assemblyElements,
      required this.assemblyWidth,
      required this.viewWidth,
      this.individualVotes,
      this.groupSectors,
      required this.nbRows})
      : super();

  @override
  void paint(Canvas canvas, Size size) {
    List<Color> paletteColors =
        List.generate(assemblyElements, (index) => customNoVote);
    List<Color> paletteParentColors =
        List.generate(assemblyElements, (index) => customNoVote);

    if (individualVotes != null) {
      List<GroupPairing> groupPairingVotes = [];
      for (IndividualVotes element in individualVotes!) {
        bool needsCreate = true;
        for (GroupPairing group in groupPairingVotes) {
          if (group.groupPairing == element.groupPairing) {
            needsCreate = false;
            if (element.voteResult == null) {
              group.valueAbstention = (group.valueAbstention ?? 0) + 1;
            } else if (element.voteResult == true) {
              group.valueFor = (group.valueFor ?? 0) + 1;
            } else {
              group.valueAgainst = (group.valueAgainst ?? 0) + 1;
            }
          }
        }
        if (needsCreate && element.groupPairing != null) {
          groupPairingVotes.add(GroupPairing(element.groupPairing!,
              valueAbstention: element.voteResult == null ? 1 : null,
              valueFor: element.voteResult == true ? 1 : null,
              valueAgainst: element.voteResult == false ? 1 : null));
        }
      }
      for (IndividualVotes element in individualVotes!) {
        paletteColors[element.index - 1] = element.voteColor;
        for (GroupPairing group in groupPairingVotes) {
          if (group.groupPairing == element.groupPairing) {
            if (group.groupChoice == element.voteResult) {
              // print("##### group.groupChoice == element.voteResult");
            } else {
              // print("##### group.groupChoice ≠ element.voteResult @ " + element.index.toString());
            }
            paletteParentColors[element.index - 1] = group.groupChoiceColor;
          }
        }
      }
    } else if (groupSectors != null) {
      int offset = 0;
      for (GroupSectors element in groupSectors!) {
        for (var i = offset; i < offset + element.nbElements; i++) {
          paletteColors[i] = element.sectorColor;
        }
        offset += element.nbElements;
      }
    }

    double rectSize = 5 * assemblyWidth;
    double radiusCenter = size.width / nbRows;
    double gapRows = size.width / 2 / nbRows;
    double angleOffset = 0;

    Offset verticalOffset = Offset(
        0,
        size.height *
            ((math.min(1.0, (1 + math.sin(assemblyAngle / 360 * 2 * math.pi))) /
                2)));

    double totalLength = 0;
    for (var i = 0; i < nbRows; i++) {
      totalLength +=
          perimeterFromDegrees(radiusCenter + i * gapRows, assemblyAngle);
    }
    // print(totalLength.toString());

    double gapPoints = totalLength / assemblyElements;

    List<int> nbElementsPerRow = [];
    int nbElementsOrdered = 0;

    for (var i = 0; i < nbRows; i++) {
      int elementsToDraw =
          (perimeterFromDegrees(radiusCenter + i * gapRows, assemblyAngle) /
                  gapPoints)
              .round();
      if (nbElementsOrdered + elementsToDraw > assemblyElements) {
        elementsToDraw = assemblyElements - nbElementsOrdered;
      }
      nbElementsOrdered += elementsToDraw;
      nbElementsPerRow.add(elementsToDraw);
    }
    // print(nbElementsOrdered.toString());

    List<ElementAttributes> theElementsAttributes = [];

    // print("nbElementsPerRow = " + nbElementsPerRow.toString());

    List<int> rowFilled = List.filled(nbRows, 0);

    for (var i = 0; i < assemblyElements; i++) {
      int? localRow;
      int? localPosition;

      double progress = i / assemblyElements;

      double minimum = assemblyElements.toDouble();
      for (var z = 0; z < rowFilled.length; z++) {
        if (paletteColors[i] == customRouge) {
          // print(rowFilled[z].toString() + " @ z=" + z.toString());
        }
        if ((rowFilled[z] <= (nbElementsPerRow[z] * progress)) &&
            (rowFilled[z] / nbElementsPerRow[z] <= minimum)) {
          minimum = rowFilled[z] / nbElementsPerRow[z];
          localRow = z;
        } else {
          if (paletteColors[i] == customRouge) {
            /*
            print("-----" +
                (nbElementsPerRow[z] * progress).toString() +
                " @ progress");
            print("-----" + (minimum).toString() + " @ minimum");
            */
          }
        }
      }

      if (localRow != null) {
        localPosition = rowFilled[localRow];
        rowFilled[localRow] += 1;
        theElementsAttributes.add(ElementAttributes(
            i, localRow, localPosition, paletteColors[i],
            parentColor: paletteParentColors[i]));
        if (paletteColors[i] == customRouge) {
          // print(localRow.toString() + "/" + localPosition.toString());
          // print(rowFilled.toString());
        }
      }
    }

    // print("0 / test = " + rowFilled.toString());

/*
    for (ElementAttributes element in theElementsAttributes) {
      print(element.row.toString() + " / " + element.position.toString());
    }
*/
    for (var i = 0; i < nbRows; i++) {
      drawArc(canvas, size,
          elementAttributeRow: i,
          allElementAttributes: theElementsAttributes,
          rectSize: rectSize,
          centerOffset: verticalOffset,
          nbElements: nbElementsPerRow[i],
          angleArcDegres: assemblyAngle,
          angleOffset: angleOffset,
          rayonArc: radiusCenter + i * gapRows,
          rectRadius: 10);
    }
  }

  double perimeterFromDegrees(double radiusArc, double angleDegrees) {
    return (angleDegrees / 360 * 2 * math.pi) * radiusArc;
  }

  void drawArc(Canvas canvas, Size canvasSize,
      {Color color = const Color.fromRGBO(128, 128, 128, 1),
      int? elementAttributeRow,
      List<ElementAttributes>? allElementAttributes,
      Offset centerOffset = const Offset(0, 0),
      double rectSize = 20,
      int nbElements = 10,
      double angleArcDegres = 90,
      double angleOffset = 0,
      double rayonArc = 100,
      double rectRadius = 0}) {
    if (nbElements == 1) {
      double angle = 0 + angleOffset;
      if (elementAttributeRow != null && allElementAttributes != null) {
        for (ElementAttributes element in allElementAttributes) {
          if (element.row == elementAttributeRow && element.position == 0) {
            if (element.parentColor != null &&
                element.parentColor == element.elementColor) {
              color = element.elementColor.withOpacity(0.3);
            } else if (element.parentColor != null &&
                element.parentColor != element.elementColor) {
              color = element.elementColor;
            } else {
              color = element.elementColor;
            }
          }
        }
      }
      rectPainting(
          canvas,
          canvasSize,
          color,
          rectSize,
          (centerOffset.dx + rayonArc * math.sin(angle / 360 * 2 * math.pi))
              .toDouble(),
          (centerOffset.dy + rayonArc * -math.cos(angle / 360 * 2 * math.pi))
              .toDouble(),
          radius: rectRadius);
    } else {
      double angleDebut = (-angleArcDegres / 2) + angleOffset;
      double angleFin = (angleArcDegres / 2) + angleOffset;

      if (elementAttributeRow != null && allElementAttributes != null) {
        for (ElementAttributes element in allElementAttributes) {
          if (element.row == elementAttributeRow && element.position == 0) {
            if (element.parentColor != null &&
                element.parentColor == element.elementColor) {
              color = element.elementColor.withOpacity(0.3);
            } else if (element.parentColor != null &&
                element.parentColor != element.elementColor) {
              color = element.elementColor;
            } else {
              color = element.elementColor;
            }
          }
        }
      }
      rectPainting(
          canvas,
          canvasSize,
          color,
          rectSize,
          (centerOffset.dx +
                  rayonArc * math.sin(angleDebut / 360 * 2 * math.pi))
              .toDouble(),
          (centerOffset.dy +
                  rayonArc * -math.cos(angleDebut / 360 * 2 * math.pi))
              .toDouble(),
          radius: rectRadius);
      int maxLoop = 0;
      for (var i = 1; i < nbElements - 1; i++) {
        double angle = ((angleArcDegres / (nbElements - 1) * i) + angleDebut);
        if (elementAttributeRow != null && allElementAttributes != null) {
          for (ElementAttributes element in allElementAttributes) {
            if (element.row == elementAttributeRow && element.position == i) {
              if (element.parentColor != null &&
                  element.parentColor == element.elementColor) {
                color = element.elementColor.withOpacity(0.3);
              } else if (element.parentColor != null &&
                  element.parentColor != element.elementColor) {
                color = element.elementColor;
              } else {
                color = element.elementColor;
              }
            }
          }
        }
        rectPainting(
            canvas,
            canvasSize,
            color,
            rectSize,
            (centerOffset.dx + rayonArc * math.sin(angle / 360 * 2 * math.pi))
                .toDouble(),
            (centerOffset.dy + rayonArc * -math.cos(angle / 360 * 2 * math.pi))
                .toDouble(),
            radius: rectRadius);
        maxLoop = i;
      }
      if (elementAttributeRow != null && allElementAttributes != null) {
        for (ElementAttributes element in allElementAttributes) {
          if (element.row == elementAttributeRow &&
              element.position == maxLoop + 1) {
            if (element.parentColor != null &&
                element.parentColor == element.elementColor) {
              color = element.elementColor.withOpacity(0.3);
            } else if (element.parentColor != null &&
                element.parentColor != element.elementColor) {
              color = element.elementColor;
            } else {
              color = element.elementColor;
            }
          }
        }
      }
      rectPainting(
          canvas,
          canvasSize,
          color,
          rectSize,
          (centerOffset.dx + rayonArc * math.sin(angleFin / 360 * 2 * math.pi))
              .toDouble(),
          (centerOffset.dy + rayonArc * -math.cos(angleFin / 360 * 2 * math.pi))
              .toDouble(),
          radius: rectRadius);
    }
  }

  void drawLine(Canvas canvas, Size canvasSize,
      {Color color = const Color.fromRGBO(255, 255, 255, 1),
      Offset centerOffset = const Offset(0, 0),
      double rectSize = 20,
      int nbElements = 10,
      double angleDegres = 90,
      double distance = 20,
      double rectRadius = 0}) {
    for (var i = 0; i < nbElements; i++) {
      rectPainting(
          canvas,
          canvasSize,
          color,
          rectSize,
          (centerOffset.dx +
                  distance *
                      (i - (nbElements - 1) / 2) *
                      -math.sin(angleDegres / 360 * 2 * math.pi))
              .toDouble(),
          (centerOffset.dy +
                  distance *
                      (i - (nbElements - 1) / 2) *
                      math.cos(angleDegres / 360 * 2 * math.pi))
              .toDouble(),
          radius: rectRadius);
    }
  }

  void rectPainting(Canvas canvas, Size canvasSize, Color color,
      double rectSize, double xOffset, double yOffset,
      {double? radius}) {
    final paint = new Paint();
    paint.color = color;

    var center = Offset(canvasSize.width / 2, canvasSize.height / 2);
    canvas.drawRRect(
        RRect.fromLTRBR(
            center.dx.roundToDouble() - (rectSize / 2) + xOffset,
            center.dy.roundToDouble() - (rectSize / 2) + yOffset,
            center.dx.roundToDouble() + (rectSize / 2) + xOffset,
            center.dy.roundToDouble() + (rectSize / 2) + yOffset,
            Radius.circular(radius ?? 0)),
        paint);
  }

  @override
  bool shouldRepaint(AssemblyPainter oldDelegate) {
    // print("########################################");
    // print("oldDelegate.assemblyElements = " + oldDelegate.assemblyElements.toString());
    // print("this.assemblyElements = " + this.assemblyElements.toString());
    // print("########################################");
    if (oldDelegate.assemblyElements != assemblyElements ||
        oldDelegate.assemblyAngle != assemblyAngle ||
        oldDelegate.individualVotes != individualVotes ||
        oldDelegate.groupSectors != groupSectors) {
      return true;
    } else {
      return false;
    }
  }
}
