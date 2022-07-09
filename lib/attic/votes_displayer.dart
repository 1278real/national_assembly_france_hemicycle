import 'package:flutter/material.dart';
import 'package:hemicycle/attic/colors.dart';
import 'package:hemicycle/attic/helpers.dart';
import 'package:hemicycle/hemicycle.dart';

import '../national_assembly_france_hemicycle.dart';

class OpenAssembleeVoteDisplayer {
  List<IndividualVotes> votesAssemblyTest = [];
  ScrutinFromJson? scrutin;

  /// used by [drawVoteHemicycle] FutureBuilder
  Future<bool> getVotes(String localPath) async {
    scrutin = await OpenAssembleeJsonTranscoder().getJsonScrutin(localPath);
    if (scrutin != null) {
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
  Widget drawVoteHemicycle(String localPath, {bool useGroupSector = false}) {
    return FutureBuilder(
      future: getVotes(localPath),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return circularWait(randomColor());
        }
        if (snapshot.hasData) {
          List<GroupSectors> _localGroups = [];
          int nbOfMembersInvolved = 0;
          if (scrutin != null && scrutin!.groupVotesDetails != null) {
            List<GroupVotesFromJson> _reorder = scrutin!.groupVotesDetails!;
            _reorder.sort();
            for (GroupVotesFromJson group in _reorder) {
              nbOfMembersInvolved += group.nbMembers ?? 0;
              _localGroups.add(GroupSectors(
                  group.nbMembers ?? 0, group.groupColor,
                  description: group.groupName));
            }
          }
          return Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.width * 1.15,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: DrawHemicycle(
                    nbOfMembersInvolved,
                    assemblyAngle: 190,
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
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
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
                        (scrutin?.majoriteVote ?? "-").firstInCaps,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 12),
                      ),
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
