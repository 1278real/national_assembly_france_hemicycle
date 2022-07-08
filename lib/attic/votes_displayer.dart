import 'package:flutter/material.dart';
import 'package:hemicycle/attic/colors.dart';
import 'package:hemicycle/attic/drawHemicycle.dart';
import 'package:hemicycle/attic/helpers.dart';
import 'package:hemicycle/hemicycle.dart';
import 'package:national_assembly_france_hemicycle/attic/helpers.dart';
import 'package:national_assembly_france_hemicycle/attic/json_vote_objecter.dart';

import 'json_transcoder.dart';

class OpenAssembleeVoteDisplayer {
  List<IndividualVotes> votesAssemblyTest = [];
  ScrutinFromJson? scrutin;

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
  /// • [onlyVoters] is an optional boolean to display only the members that attended (even if didn't vote or used abstention).
  Widget DrawVoteHemicycle(String localPath, {bool onlyVoters = false}) {
    return FutureBuilder(
      future: getVotes(localPath),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return CircularProgressIndicator();
        }
        if (snapshot.hasData) {
          int nbOfMembersInvolved = 0;
          if (scrutin != null && scrutin!.groupVotesDetails != null) {
            for (GroupVotesFromJson group in scrutin!.groupVotesDetails!) {
              nbOfMembersInvolved += group.nbMembers ?? 0;
            }
          }
          return Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: DrawHemicycle(
                    onlyVoters ? votesAssemblyTest.length : nbOfMembersInvolved,
                    assemblyWidth: 0.8,
                    nbRows: ((onlyVoters
                                ? votesAssemblyTest.length
                                : nbOfMembersInvolved) /
                            48)
                        .round(),
                    individualVotes: votesAssemblyTest,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        (scrutin?.titre ??
                                ("Vote " + (scrutin?.codeVote ?? "-")))
                            .firstInCaps,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                      Text(
                        (scrutin?.demandeur ?? "-").firstInCaps,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Padding(padding: EdgeInsets.all(2)),
                      Text(
                        (scrutin?.resultatVote ?? "-").firstInCaps,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.w900),
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
                              Padding(padding: EdgeInsets.all(2)),
                              Text(
                                (scrutin?.votedFor.toString() ?? "") +
                                    " POUR" +
                                    ((scrutin?.votedFor ?? 0) > 1 ? "S" : ""),
                                textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.w900),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                  width: 10,
                                  height: 10,
                                  color: hemicyleVoteAgainst),
                              Padding(padding: EdgeInsets.all(2)),
                              Text(
                                (scrutin?.votedAgainst.toString() ?? "") +
                                    " CONTRE" +
                                    ((scrutin?.votedAgainst ?? 0) > 1
                                        ? "S"
                                        : ""),
                                textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.w900),
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
                              Padding(padding: EdgeInsets.all(2)),
                              Text(
                                (scrutin?.votedAbstention.toString() ?? "") +
                                    " ABSTENTION" +
                                    ((scrutin?.votedAbstention ?? 0) > 1
                                        ? "S"
                                        : ""),
                                textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.w900),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                  width: 10, height: 10, color: hemicyleNoVote),
                              Padding(padding: EdgeInsets.all(2)),
                              Text(
                                (scrutin?.didNotVote.toString() ?? "") +
                                    " NON VOTANT" +
                                    ((scrutin?.didNotVote ?? 0) > 1 ? "S" : ""),
                                textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.w900),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Padding(padding: EdgeInsets.all(2)),
                      Text(
                        (dateStringFormatter(scrutin?.dateScrutin)),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.w600),
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
          return CircularProgressIndicator();
        }
      },
    );
  }
}
