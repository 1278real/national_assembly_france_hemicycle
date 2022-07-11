import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:flutter/services.dart';
import 'package:hemicycle/attic/individual_votes.dart';

import 'json_vote_objecter.dart';

class OpenAssembleeJsonTranscoder {
  /// Checks if remote file is available and returns its body
  Future<dynamic> _checkAvailabilityOfRemoteFile(String remotePath) async {
    dynamic _toReturn = "";

    try {
      var url = Uri.parse(remotePath);

      final response = await http.get(url).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        // print("&&&&& ok");
        _toReturn = response.body;
      } else {
        // print("&&&&& nope");
        _toReturn = "";
      }
    } on TimeoutException catch (_) {
      // A timeout occurred.

      _toReturn = "";
    } on SocketException catch (_) {
      // Other exception

      _toReturn = "";
    }
    return _toReturn;
  }

  /// Checks if local file is available and returns its content
  Future<dynamic> _checkAvailabilityOfLocalFile(String localPath) async {
    final dynamic response = await rootBundle.loadString(localPath);
    if (response != null) {
      return response;
    }
    return "";
  }

  /// Get JSON file (local or remote) and map to [ScrutinFromJson]
  Future<ScrutinFromJson?> getJsonScrutin(
      {String? localPath, String? remotePath}) async {
    dynamic responseToProcess = "";

    if (remotePath != null) {
      // print("sending to remote");
      responseToProcess = await _checkAvailabilityOfRemoteFile(remotePath);
      // print("&\n" + responseToProcess + "\n&");
    } else if (localPath != null) {
      responseToProcess = await _checkAvailabilityOfLocalFile(localPath);
    }

    if (responseToProcess != "") {
      // print("—————national_assembly_france_hemicycle————— ••••• STEP 1");

      Map<String, dynamic> _map = json.decode(responseToProcess);
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
    } else {
      return null;
    }
  }

  /// Inside the [ScrutinFromJson], reorder the Groups and INdividual Votes for Assembly display
  Future<List<IndividualVotes>> getJsonIndividualVotes(
      ScrutinFromJson scrutin) async {
    List<IndividualVotes> votesList = [];

    if (scrutin.groupVotesDetails != null) {
      // print("—————national_assembly_france_hemicycle————— ••••• STEP 4");
      if (scrutin.groupVotesDetails!.length > 0) {
        // print("—————national_assembly_france_hemicycle————— ••••• STEP 5");
        List<GroupVotesFromJson> _reorder = scrutin.groupVotesDetails!;
        _reorder.sort();

        int indexIncrement = 1;
        for (var i = 0; i < _reorder.length; i++) {
          if (_reorder[i].individualVotesDetails != null) {
            // print("—————national_assembly_france_hemicycle————— ••••• STEP 6 @ " + i.toString());
            if (_reorder[i].individualVotesDetails!.length > 0) {
              // print("—————national_assembly_france_hemicycle————— ••••• STEP 7");
              int groupIncrement = 1;
              int groupNumber = _reorder[i].nbMembers ?? 0;
              for (var j = 0;
                  j < _reorder[i].individualVotesDetails!.length;
                  j++) {
                IndividualVoteFromJson element =
                    _reorder[i].individualVotesDetails![j];
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
                    groupPairing: _reorder[i].organeRef));
                indexIncrement += 1;
                groupIncrement += 1;
              }
              indexIncrement += (groupNumber - groupIncrement);
              print("groupNumber = " +
                  groupNumber.toString() +
                  " / groupIncrement = " +
                  groupIncrement.toString() +
                  " /// indexIncrement = " +
                  indexIncrement.toString());
            }
          }
        }
      }
    }
    return votesList;
    // print("—————national_assembly_france_hemicycle————— ••••• getJsonScrutin OVER");
  }
}
