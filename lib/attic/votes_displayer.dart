import 'package:flutter/material.dart';
import 'package:hemicycle/attic/drawHemicycle.dart';
import 'package:hemicycle/hemicycle.dart';
import 'package:national_assembly_france_hemicycle/attic/json_vote_objecter.dart';

import 'json_transcoder.dart';

class OpenAssembleeVoteDisplayer {
  List<IndividualVotes> votesAssemblyTest = [];
  ScrutinFromJson? scrutin;

  Future<bool> getVotes(String path) async {
    scrutin = await OpenAssembleeJsonTranscoder().getJsonScrutin(path);
    if (scrutin != null) {
      votesAssemblyTest =
          await OpenAssembleeJsonTranscoder().getJsonIndividualVotes(scrutin!);
      return true;
    }
    return false;
  }

  Widget DrawVoteHemicycle(String path) {
    return FutureBuilder(
      future: getVotes(path),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return CircularProgressIndicator();
        }
        if (snapshot.hasData) {
          return Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: DrawHemicycle(
                    votesAssemblyTest.length,
                    nbRows: (votesAssemblyTest.length / 48).round(),
                    individualVotes: votesAssemblyTest,
                    withLegend: true,
                  ),
                ),
                Center(
                  child: Text(scrutin?.codeVote ?? "---"),
                )
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
