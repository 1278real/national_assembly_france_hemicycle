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
    final dynamic response = await rootBundle
        .loadString(path ?? "assets/example_legislature15.json");
    if (response != null) {
      print(
          "—————national_assembly_france_hemicycle————— getJsonScrutin SUCCESS : " +
              response.length.toString());

      print("—————national_assembly_france_hemicycle————— ••••• STEP 1");

      Map<String, dynamic> _theJson = jsonDecode(response);
      // final List _theJsonList = jsonDecode(response.toString());
      print(" —————national_assembly_france_hemicycle————— ••••• _theJson");
      print(_theJson);
      print(" —————national_assembly_france_hemicycle————— ••••• STEP 2");

      ScrutinFromJson _newObjects =
          ScrutinFromJson.fromFrenchNationalAssemblyJson(_theJson);

/*
      List<scrutinFromJson> _newObjects = _theJsonList
          .map((theJsonMap) =>
              scrutinFromJson.fromFrenchNationalAssemblyJson(theJsonMap))
          .toList();
*/

      print("—————national_assembly_france_hemicycle————— ••••• _newObjects");
      inspect(_newObjects);
      print("—————national_assembly_france_hemicycle————— ••••• STEP 3");

      if (_newObjects.votesDetails != null) {
        if (_newObjects.votesDetails!.length > 0) {
          int indexIncrement = 0;
          for (var i = 0; i < _newObjects.votesDetails!.length; i++) {
            if (_newObjects.votesDetails![i].votesDetails != null) {
              if (_newObjects.votesDetails![i].votesDetails!.length > 0) {
                for (var j = 0;
                    j < _newObjects.votesDetails![i].votesDetails!.length;
                    j++) {
                  IndividualVoteFromJson element =
                      _newObjects.votesDetails![i].votesDetails![j];
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
                      groupPairing: _newObjects.votesDetails![i].organeRef));
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
