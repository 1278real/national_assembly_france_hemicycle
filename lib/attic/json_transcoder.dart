import 'dart:convert';
import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:hemicycle/attic/individual_votes.dart';

import 'json_vote_objecter.dart';

class OpenAssembleeJsonTranscoder {
  Future<ScrutinFromJson?> getJsonScrutin(String localPath) async {
    final dynamic response = await rootBundle.loadString(localPath);
    if (response != null) {
/*
      print(
          "—————national_assembly_france_hemicycle————— getJsonScrutin SUCCESS : " +
              response.length.toString());
*/

      // print("—————national_assembly_france_hemicycle————— ••••• STEP 1");

      Map<String, dynamic> _map = json.decode(response);
      Map<String, dynamic> _mapBis = _map["scrutin"];

      // print(" —————national_assembly_france_hemicycle————— ••••• _mapBis");

/*
      print(_mapBis);
      print('---');
      print(_mapBis["uid"]);
      print('---');
      print(_mapBis['sort']);
      print('---');
      print(_mapBis['groupe'][0]['organeRef']);
*/

      // print(" —————national_assembly_france_hemicycle————— ••••• STEP 2");

      ScrutinFromJson _newObjects =
          ScrutinFromJson.fromFrenchNationalAssemblyJson(_mapBis);

      return _newObjects;
    }
  }

  Future<List<IndividualVotes>> getJsonIndividualVotes(
      ScrutinFromJson scrutin) async {
    List<IndividualVotes> votesList = [];

    if (scrutin.groupVotesDetails != null) {
      // print("—————national_assembly_france_hemicycle————— ••••• STEP 4");
      if (scrutin.groupVotesDetails!.length > 0) {
        // print("—————national_assembly_france_hemicycle————— ••••• STEP 5");
        int indexIncrement = 1;
        for (var i = 0; i < scrutin.groupVotesDetails!.length; i++) {
          if (scrutin.groupVotesDetails![i].individualVotesDetails != null) {
            // print("—————national_assembly_france_hemicycle————— ••••• STEP 6 @ " + i.toString());
            if (scrutin.groupVotesDetails![i].individualVotesDetails!.length >
                0) {
              // print("—————national_assembly_france_hemicycle————— ••••• STEP 7");
              for (var j = 0;
                  j <
                      scrutin
                          .groupVotesDetails![i].individualVotesDetails!.length;
                  j++) {
                IndividualVoteFromJson element =
                    scrutin.groupVotesDetails![i].individualVotesDetails![j];
                votesList.add(IndividualVotes(indexIncrement,
                    voteResult: element.votedFor ?? false
                        ? true
                        : element.votedAgainst ?? false
                            ? false
                            : element.votedAbstention ?? false
                                ? null
                                : element.didNotVote ?? false
                                    ? null
                                    : null,
                    groupPairing: scrutin.groupVotesDetails![i].organeRef));
                indexIncrement += 1;
              }
            }
          }
        }
      }
    }
    return votesList;
    // print("—————national_assembly_france_hemicycle————— ••••• getJsonScrutin OVER");
  }
}
