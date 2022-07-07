import 'dart:convert';
import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:hemicycle/attic/individual_votes.dart';

import 'json_vote_objecter.dart';

class OpenAssembleeJsonTranscoder {
  Future<List<IndividualVotes>> _getJsonScrutinAsync(String path) async {
    List<IndividualVotes> votesList = [];

    final dynamic response = await rootBundle.loadString(path);
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

      print("—————national_assembly_france_hemicycle————— ••••• _newObjects");
      inspect(_newObjects);
      print("—————national_assembly_france_hemicycle————— ••••• STEP 3");

      if (_newObjects.groupVotesDetails != null) {
        print("—————national_assembly_france_hemicycle————— ••••• STEP 4");
        if (_newObjects.groupVotesDetails!.length > 0) {
          print("—————national_assembly_france_hemicycle————— ••••• STEP 5");
          int indexIncrement = 0;
          for (var i = 0; i < _newObjects.groupVotesDetails!.length; i++) {
            if (_newObjects.groupVotesDetails![i].individualVotesDetails !=
                null) {
              print(
                  "—————national_assembly_france_hemicycle————— ••••• STEP 6 @ " +
                      i.toString());
              if (_newObjects
                      .groupVotesDetails![i].individualVotesDetails!.length >
                  0) {
                print(
                    "—————national_assembly_france_hemicycle————— ••••• STEP 7");
                for (var j = 0;
                    j <
                        _newObjects.groupVotesDetails![i]
                            .individualVotesDetails!.length;
                    j++) {
                  IndividualVoteFromJson element = _newObjects
                      .groupVotesDetails![i].individualVotesDetails![j];
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
                      groupPairing:
                          _newObjects.groupVotesDetails![i].organeRef));
                  indexIncrement += 1;
                }
              }
            }
          }
        }
      }

      print(
          "—————national_assembly_france_hemicycle————— ••••• getJsonScrutin OVER");
    }
    return votesList;
  }
}
