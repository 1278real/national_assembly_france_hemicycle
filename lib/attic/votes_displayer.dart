import 'package:flutter/material.dart';
import 'package:hemicycle/attic/colors.dart';
import 'package:hemicycle/attic/helpers.dart';
import 'package:hemicycle/hemicycle.dart';

import '../national_assembly_france_hemicycle.dart';

class OpenAssembleeVoteDisplayer {
  List<IndividualVotes> votesAssemblyTest = [];
  ScrutinFromJson? scrutin;
  List<GroupSectors> _localGroups = [];
  List<GroupSectors> _localInterGroups = [];
  int nbOfMembersInvolved = 0;
  AmendementFromJson? amendement;

  /// used by [drawVoteHemicycleFromPath] FutureBuilder
  Future<bool> getVotes(
      {String? localPath,
      String? remotePath,
      ScrutinFromJson? downloaded,
      bool? hiliteFronde,
      String? amendementString}) async {
    if (localPath != null || remotePath != null) {
      ReturnFromJson? _return = await OpenAssembleeJsonTranscoder()
          .getJsonScrutin(
              localPath: localPath,
              remotePath: remotePath,
              amendementPath: amendementString);
      if (_return != null) {
        scrutin = _return.scrutin;
        if (_return.amendement != null) {
          amendement = _return.amendement;
        }
      }
    } else if (downloaded != null) {
      scrutin = downloaded;
    }

    if (scrutin != null) {
      if (scrutin!.groupVotesDetails != null) {
        List<GroupVotesFromJson> _reorder = scrutin!.groupVotesDetails!;
        _reorder.sort();
        for (GroupVotesFromJson group in _reorder) {
          nbOfMembersInvolved += group.nbMembers ?? 0;
          _localGroups.add(GroupSectors(group.nbMembers ?? 0, group.groupColor,
              description: group.groupName));
          _localInterGroups.add(GroupSectors(
              group.nbMembers ?? 0, group.intergroupColor,
              description: group.intergroupName));
        }
      }
      votesAssemblyTest = await OpenAssembleeJsonTranscoder()
          .getJsonIndividualVotes(scrutin!, hiliteFronde);

      return true;
    }

    return false;
  }

  /// ### Creates a widget with French National Assembly view defined by these parameters :
  ///
  /// • [localPath] is the path to the JSON file that needs to be displayed.
  ///
  /// • [useGroupSector] is an optional boolean to display the surrounding arc of group colors.
  @Deprecated('Use drawVoteHemicycleFromPath instead')
  Widget drawVoteHemicycle(String localPath, {bool useGroupSector = false}) {
    return drawVoteHemicycleFromPath(
        localPath: localPath, useGroupSector: useGroupSector);
  }

  /// ### Creates a widget with French National Assembly view defined by these parameters :
  ///
  /// • [initialComment] is an optional String to display the summary of the Vote displayed.
  ///
  /// • [localPath] is the path to the local JSON file that needs to be displayed.
  ///
  /// • [remotePath] is the path to a remote JSON file that needs to be displayed.
  ///
  /// • [downloaded] receives a [ScrutinFromJson] that needs to be displayed.
  ///
  /// • [amendementString] is an optional String to display the text of the Law Amendment instead of the Lax title : it needs the JSON file name.
  ///
  /// • [useGroupSector] is an optional boolean to display the surrounding arc of group colors.
  ///
  /// • [hiliteFronde] is a boolean that display or not the No Vote and Abstention in Group that have a majority of Voters in Individual Votes view.
  ///
  /// • [withDividerBefore] is an optional boolean to display an Horizontal Divider before the Column of Widgets.
  /// • [withDividerAfter] is an optional boolean to display an Horizontal Divider after the Column of Widgets.
  ///
  /// • [backgroundColor] is used to fill the Drawing area with a plain background color
  Widget drawVoteHemicycleFromPath(
      {String? initialComment,
      String? localPath,
      String? remotePath,
      ScrutinFromJson? downloaded,
      String? amendementString,
      bool useGroupSector = false,
      bool withDividerBefore = false,
      bool withDividerAfter = false,
      bool? hiliteFronde,
      Color? backgroundColor}) {
    return FutureBuilder(
      future: getVotes(
          localPath: localPath,
          remotePath: remotePath,
          downloaded: downloaded,
          hiliteFronde: hiliteFronde,
          amendementString: amendementString),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasError) {
          return Container(
            child: Text(
              snapshot.error.toString(),
            ),
          );
        } else if (snapshot.hasData) {
          String titleString = cleanRawHtmlString(amendement != null
              ? amendement?.exposeSommaire ?? ""
              : (scrutin?.titre ?? ("")));
          return Container(
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  if (withDividerBefore)
                    for (Widget widget in theDivider(big: true)) widget,
                  if (initialComment != null)
                    Text(initialComment,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 14)),
                  Text(
                      (amendement != null
                              ? "Amendement " + (amendement!.numeroLong ?? "")
                              : "Scrutin " + (scrutin?.numero ?? "")) +
                          " du " +
                          dateStringFormatter(scrutin?.dateScrutin),
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                  Padding(padding: EdgeInsets.all(5)),
                  Text(
                    "par " + (scrutin?.demandeur ?? "-").firstInCaps,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w300, fontSize: 10),
                  ),
                  Padding(padding: EdgeInsets.all(5)),
                  Text(titleString.firstInCaps.trim().deleteEndingPoint,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.italic,
                          fontSize: (titleString.length > 150 ? 12 : 14))),
                  Stack(
                      alignment: AlignmentDirectional.bottomCenter,
                      children: [
                        DrawHemicycle(
                          nbOfMembersInvolved,
                          assemblyAngle: 195,
                          assemblyWidth: downloaded != null ? 0.6 : 1,
                          nbRows: (nbOfMembersInvolved / 48).round(),
                          individualVotes: votesAssemblyTest,
                          groupSectors: _localGroups,
                          superGroupSectors: _localInterGroups,
                          useGroupSector: useGroupSector,
                          backgroundColor: backgroundColor ??
                              Theme.of(context).scaffoldBackgroundColor,
                          backgroundOpacity: 0.05,
                          hiliteFronde: hiliteFronde,
                        ),
                        Transform.rotate(
                          angle: (-10.0).degreesToRadians,
                          child: OutlinedButton(
                            onPressed: null,
                            style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                    width: 1.5,
                                    color: (scrutin?.resultatVote
                                                .toString()
                                                .firstInCaps ==
                                            "Adopté")
                                        ? hemicyleVoteFor
                                        : (scrutin?.resultatVote
                                                    .toString()
                                                    .firstInCaps ==
                                                "Rejeté")
                                            ? hemicyleVoteAgainst
                                            : hemicyleVoteAbstention)),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Text(
                                (scrutin?.resultatVote ?? "-").firstInCaps,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: downloaded != null ? 12 : 24,
                                    color: (scrutin?.resultatVote
                                                .toString()
                                                .firstInCaps ==
                                            "Adopté")
                                        ? hemicyleVoteFor
                                        : (scrutin?.resultatVote
                                                    .toString()
                                                    .firstInCaps ==
                                                "Rejeté")
                                            ? hemicyleVoteAgainst
                                            : hemicyleVoteAbstention),
                              ),
                            ),
                          ),
                        ),
                      ]),
                  Padding(padding: EdgeInsets.all(6)),
                  Text(
                    (scrutin?.libelleVote ?? "-").firstInCaps,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
                  ),
                  Text(
                    (scrutin?.majoriteVote ?? "-").firstInCaps,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w300, fontSize: 12),
                  ),
                  Padding(padding: EdgeInsets.all(6)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        children: [
                          Container(
                              width: 10, height: 10, color: hemicyleVoteFor),
                          Padding(padding: EdgeInsets.all(1)),
                          Container(
                              width: 10,
                              height: 10,
                              color: hemicyleVoteFor.withOpacity(0.3)),
                          Padding(padding: EdgeInsets.all(3)),
                          Text(
                            (scrutin?.votedFor.toString() ?? "") +
                                " pour" +
                                ((scrutin?.votedFor ?? 0) > 1 ? "s" : ""),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 10),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                              width: 10,
                              height: 10,
                              color: hemicyleVoteAgainst),
                          Padding(padding: EdgeInsets.all(1)),
                          Container(
                              width: 10,
                              height: 10,
                              color: hemicyleVoteAgainst.withOpacity(0.3)),
                          Padding(padding: EdgeInsets.all(3)),
                          Text(
                            (scrutin?.votedAgainst.toString() ?? "") +
                                " contre" +
                                ((scrutin?.votedAgainst ?? 0) > 1 ? "s" : ""),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 10),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        children: [
                          Container(
                              width: 10,
                              height: 10,
                              color: hemicyleVoteAbstention),
                          Padding(padding: EdgeInsets.all(1)),
                          Container(
                              width: 10,
                              height: 10,
                              color: hemicyleVoteAbstention.withOpacity(0.3)),
                          Padding(padding: EdgeInsets.all(3)),
                          Text(
                            (scrutin?.votedAbstention.toString() ?? "") +
                                " abstention" +
                                ((scrutin?.votedAbstention ?? 0) > 1
                                    ? "s"
                                    : ""),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 10),
                          ),
                          if ((scrutin?.didNotVote ?? 0) > 0)
                            Padding(padding: EdgeInsets.all(3)),
                          if ((scrutin?.didNotVote ?? 0) > 0)
                            Text(
                              " + " +
                                  (scrutin?.didNotVote.toString() ?? "") +
                                  " non votant" +
                                  ((scrutin?.didNotVote ?? 0) > 0 ? "*" : "") +
                                  ((scrutin?.didNotVote ?? 0) > 1 ? "s" : ""),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 10),
                            ),
                        ],
                      ),
/*
                      if ((scrutin?.didNotVote ?? 0) > 0)
                        Row(
                          children: [
                            Container(
                                width: 10,
                                height: 10,
                                color:
                                    hemicyleVoteAbstention), // car présents, donc pas vote absent !!
                            Padding(padding: EdgeInsets.all(1)),
                            Container(
                                width: 10,
                                height: 10,
                                color: hemicyleVoteAbstention.withOpacity(
                                    0.3)), // car présents, donc pas vote absent !!
                            Padding(padding: EdgeInsets.all(3)),
                            Text(
                              (scrutin?.didNotVote.toString() ?? "") +
                                  " non votant" +
                                  ((scrutin?.didNotVote ?? 0) > 0 ? "*" : "") +
                                  ((scrutin?.didNotVote ?? 0) > 1 ? "s" : ""),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 10),
                            ),
                          ],
                        ),
*/
                    ],
                  ),
                  if ((scrutin?.didNotVote ?? 0) > 0)
                    Text(
                      "* 'non votant" +
                          ((scrutin?.didNotVote ?? 0) > 1 ? "s" : "") +
                          "' parmi les présents, les autres sont notés 'absents'",
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontWeight: FontWeight.w200, fontSize: 7),
                    ),
                  if (withDividerAfter)
                    for (Widget widget in theDivider(big: true)) widget,
                ],
              ),
            ),
          );
        } else {
          return circularWait(randomColor());
        }
      },
    );
  }

  /// ### Creates a widget with French National Assembly view defined by these parameters :
  ///
  /// • [vote] receives a [ScrutinFromJson] that needs to be displayed.
  Widget drawVoteHemicycleFromAppSupport({required ScrutinFromJson vote}) {
    return drawVoteHemicycleFromPath(
        downloaded: vote, useGroupSector: true, hiliteFronde: false);
  }

  /// used by [drawVoteHemicycleFromPath] FutureBuilder
  /// returns a List of [DeputesFromCsv] from a [scrutin.GroupVotesFromJson] and the list of All Deputies to provide.
  List<DeputesFromCsv> getListOfHighlightedDeputes(
      List<DeputesFromCsv> allDeputes, GroupVotesFromJson groupInScrutin) {
    List<DeputesFromCsv> _toReturn = [];
    if ((groupInScrutin.deputesRefToHilite ?? []).length > 0) {
      for (IndividualVoteFromJson voter in groupInScrutin.deputesRefToHilite!) {
        for (DeputesFromCsv depute in allDeputes) {
          if (depute.deputeRef == voter.acteurRef) {
            _toReturn.add(DeputesFromCsv.fromVote(depute, voter));
          }
        }
      }
    }
    return [];
  }
}
