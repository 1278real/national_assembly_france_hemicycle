import 'package:flutter/material.dart';
import 'package:hemicycle/attic/colors.dart';
import 'package:hemicycle/attic/helpers.dart';
import 'package:hemicycle/hemicycle.dart';

import '../national_assembly_france_hemicycle.dart';

class OpenAssembleeVoteDisplayer {
  List<IndividualVotes> votesAssemblyTest = [];
  ScrutinFromJson? scrutin;
  List<GroupSectors> _localGroups = [];
  int nbOfMembersInvolved = 0;

  /// used by [drawVoteHemicycleFromPath] FutureBuilder
  Future<bool> getVotes({String? localPath, String? remotePath}) async {
    if (localPath != null || remotePath != null) {
      scrutin = await OpenAssembleeJsonTranscoder()
          .getJsonScrutin(localPath: localPath, remotePath: remotePath);
    }

    if (scrutin != null) {
      if (scrutin!.groupVotesDetails != null) {
        List<GroupVotesFromJson> _reorder = scrutin!.groupVotesDetails!;
        _reorder.sort();
        int sum = 0;
        for (GroupVotesFromJson group in _reorder) {
          nbOfMembersInvolved += group.nbMembers ?? 0;
          _localGroups.add(GroupSectors(group.nbMembers ?? 0, group.groupColor,
              description: group.groupName));
/*
          print("-----" +
              group.groupName +
              " / " +
              group.nbMembers.toString() +
              " = " +
              nbOfMembersInvolved.toString());
*/
        }
      }
      votesAssemblyTest =
          await OpenAssembleeJsonTranscoder().getJsonIndividualVotes(scrutin!);

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
  /// • [localPath] is the path to the local JSON file that needs to be displayed.
  ///
  /// • [remotePath] is the path to a remote JSON file that needs to be displayed.
  ///
  /// • [useGroupSector] is an optional boolean to display the surrounding arc of group colors.
  ///
  /// • [withDivider] is an optional boolean to display an Horizontal Divider before the Column of Widgets.
  ///
  /// • [backgroundColor] is used to fill the Drawing area with a plain background color
  Widget drawVoteHemicycleFromPath(
      {String? localPath,
      String? remotePath,
      bool useGroupSector = false,
      bool withDivider = false,
      Color? backgroundColor}) {
    return FutureBuilder(
      future: getVotes(localPath: localPath, remotePath: remotePath),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
/*
        if (snapshot.connectionState != ConnectionState.done) {
          return circularWait(randomColor());
        }
*/

        //       print("nbOfMembersInvolved = " + nbOfMembersInvolved.toString());
        if (snapshot.hasData) {
          return Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.width * 1.35,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: DrawHemicycle(
                    nbOfMembersInvolved,
                    assemblyAngle: 195,
                    nbRows: (nbOfMembersInvolved / 48).round(),
                    individualVotes: votesAssemblyTest,
                    groupSectors: _localGroups,
                    withTitle: true,
                    title: ((scrutin?.titre ??
                            ("Vote " + (scrutin?.codeVote ?? "-")))
                        .firstInCaps
                        .trim()
                        .deleteEndinPoint),
                    useGroupSector: useGroupSector,
                    backgroundColor: backgroundColor ??
                        Theme.of(context).scaffoldBackgroundColor,
                    backgroundOpacity: 0.05,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (withDivider)
                        for (Widget widget in theDivider()) widget,
                      Text(
                        "par " + (scrutin?.demandeur ?? "-").firstInCaps,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 10),
                      ),
                      Padding(padding: EdgeInsets.all(10)),
                      Text(
                        (dateStringFormatter(scrutin?.dateScrutin)),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 11),
                      ),
                      Padding(padding: EdgeInsets.all(10)),
                      Text(
                        (scrutin?.libelleVote ?? "-").firstInCaps,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 12),
                      ),
                      Text(
                        (scrutin?.majoriteVote ?? "-").firstInCaps,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 12),
                      ),
                      Padding(padding: EdgeInsets.all(10)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Row(
                            children: [
                              Container(
                                  width: 10,
                                  height: 10,
                                  color: hemicyleVoteFor),
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
                                    ((scrutin?.votedAgainst ?? 0) > 1
                                        ? "s"
                                        : ""),
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
                                  color:
                                      hemicyleVoteAbstention.withOpacity(0.3)),
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
                            ],
                          ),
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
                                      ((scrutin?.didNotVote ?? 0) > 0
                                          ? "*"
                                          : "") +
                                      ((scrutin?.didNotVote ?? 0) > 1
                                          ? "s"
                                          : ""),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 10),
                                ),
                              ],
                            ),
                        ],
                      ),
                      Text(
                        (scrutin?.resultatVote ?? "-").firstInCaps,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 12),
                      ),
                      if ((scrutin?.didNotVote ?? 0) > 0)
                        Text(
                          "* 'non votant" +
                              ((scrutin?.didNotVote ?? 0) > 1 ? "s" : "") +
                              "' parmi les présents, les autres sont notés 'absents'",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.w200, fontSize: 7),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
        if (snapshot.hasError) {
          return Container(
            child: Text(
              snapshot.error.toString(),
            ),
          );
        } else {
          return circularWait(randomColor());
        }
      },
    );
  }
}
