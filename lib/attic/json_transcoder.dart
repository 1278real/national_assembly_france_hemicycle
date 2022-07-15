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
  Future<ReturnFromJson?> getJsonScrutin(
      {String? localPath, String? remotePath, String? amendementPath}) async {
    dynamic responseToProcess = "";
    dynamic amendementToProcess = "";

    // print("amendementPath = " + (amendementPath ?? "NOPE"));

    if (remotePath != null) {
      // print("sending to remote");
      responseToProcess = await _checkAvailabilityOfRemoteFile(remotePath);
      if (amendementPath != null) {
        amendementToProcess =
            await _checkAvailabilityOfRemoteFile(amendementPath);
        // print("&\n" + amendementToProcess + "\n&");
      }
      // print("&\n" + responseToProcess + "\n&");
    } else if (localPath != null) {
      responseToProcess = await _checkAvailabilityOfLocalFile(localPath);
      if (amendementPath != null) {
        amendementToProcess =
            await _checkAvailabilityOfLocalFile(amendementPath);
      }
    }

    if (responseToProcess != "") {
      Map<String, dynamic> _mapScrutin = json.decode(responseToProcess);

      ScrutinFromJson _scrutinToReturn =
          ScrutinFromJson.fromFrenchNationalAssemblyJson(_mapScrutin);

      ReturnFromJson _toReturn = ReturnFromJson(_scrutinToReturn);

      if (amendementToProcess != "") {
        // print("••• STEP 1 •••");
        Map<String, dynamic> _mapAmendement = json.decode(amendementToProcess);
        // print("••• STEP 2 •••");

        AmendementFromJson? _amendementToReturn =
            AmendementFromJson.fromFrenchNationalAssemblyJson(_mapAmendement);

        // print("••• STEP 4 •••");

        _toReturn.amendement = _amendementToReturn;
      }

      return _toReturn;
    } else {
      return null;
    }
  }

  /// Inside the [ScrutinFromJson], reorder the Groups and INdividual Votes for Assembly display
  Future<List<IndividualVotes>> getJsonIndividualVotes(
      ScrutinFromJson scrutin, bool? hiliteFronde) async {
    List<IndividualVotes> votesList = [];

    if (scrutin.groupVotesDetails != null) {
      // print("—————national_assembly_france_hemicycle————— ••••• STEP 4");
      if (scrutin.groupVotesDetails!.length > 0) {
        // print("—————national_assembly_france_hemicycle————— ••••• STEP 5");
        List<GroupVotesFromJson> _reorder = scrutin.groupVotesDetails!;
        _reorder.sort();

        int indexIncrement = 0;
        for (var i = 0; i < _reorder.length; i++) {
          if (_reorder[i].individualVotesDetails != null) {
            // print("—————national_assembly_france_hemicycle————— ••••• STEP 6 @ " + i.toString());
            if (_reorder[i].individualVotesDetails!.length > 0) {
              // print("—————national_assembly_france_hemicycle————— ••••• STEP 7");
              int groupIncrement = 0;
              int groupNumber = _reorder[i].nbMembers ?? 0;

              for (var j = 0;
                  j < _reorder[i].individualVotesDetails!.length;
                  j++) {
                indexIncrement += 1;
                groupIncrement += 1;
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
              }

              if (groupNumber > groupIncrement) {
                for (var z = 0; z < groupNumber - groupIncrement; z++) {
                  indexIncrement += 1;
                  if (hiliteFronde ?? false) {
                    votesList.add(IndividualVotes(indexIncrement,
                        voteResult: null, groupPairing: _reorder[i].organeRef));
                  }
                }
              }
/*
              print("groupNumber = " +
                  groupNumber.toString() +
                  " / groupIncrement = " +
                  groupIncrement.toString() +
                  " /// indexIncrement = " +
                  indexIncrement.toString());
*/
            }
          }
        }
      }
    }
    return votesList;
    // print("—————national_assembly_france_hemicycle————— ••••• getJsonScrutin OVER");
  }
}
