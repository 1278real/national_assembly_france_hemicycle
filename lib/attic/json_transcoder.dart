import 'dart:convert';
import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:hemicycle/attic/individual_votes.dart';

import 'json_vote_objecter.dart';

class OpenAssembleeJsonTranscoder {
  List<IndividualVotes> votesList = [];

  List<IndividualVotes> getJsonIndividualVotes({String? path}) {
    _getJsonScrutinAsync(path: path);
    return votesList;
  }

  void _getJsonScrutinAsync({String? path}) async {
    final dynamic response = await rootBundle.loadString(path ??
        "package:national_assembly_france_hemicycle/assets/example_json/VTANR5L15V4417.json");
    if (response != null) {
      print(
          "—————national_assembly_france_hemicycle————— getJsonScrutin SUCCESS : " +
              response.length.toString());

      print("—————national_assembly_france_hemicycle————— ••••• STEP 1");

      Iterable _theJsonList = jsonDecode(response) as List;

      print(" —————national_assembly_france_hemicycle————— ••••• _theJson");
      print(_theJsonList);
      print(" —————national_assembly_france_hemicycle————— ••••• STEP 2");

      List<ScrutinFromJson> _newObjectsList = List<ScrutinFromJson>.from(
          _theJsonList.map((model) =>
              ScrutinFromJson.fromFrenchNationalAssemblyJson(model)));

      ScrutinFromJson _newObjects = _newObjectsList[0];
/*
      List<scrutinFromJson> _newObjects = _theJsonList
          .map((theJsonMap) =>
              scrutinFromJson.fromFrenchNationalAssemblyJson(theJsonMap))
          .toList();
*/

      print("—————national_assembly_france_hemicycle————— ••••• _newObjects");
      inspect(_newObjects);
      print("—————national_assembly_france_hemicycle————— ••••• STEP 3");

      if (_newObjects.groupVotesDetails != null) {
        if (_newObjects.groupVotesDetails!.length > 0) {
          int indexIncrement = 0;
          for (var i = 0; i < _newObjects.groupVotesDetails!.length; i++) {
            if (_newObjects.groupVotesDetails![i].individualVotesDetails !=
                null) {
              if (_newObjects
                      .groupVotesDetails![i].individualVotesDetails!.length >
                  0) {
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
    } else {
      votesList = [];
    }
  }
}
