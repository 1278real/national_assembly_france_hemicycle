import 'package:flutter/material.dart';
import 'package:hemicycle/attic/drawHemicycle.dart';
import 'package:hemicycle/hemicycle.dart';

import 'json_transcoder.dart';

class OpenAssembleeVoteDisplayer {
  List<IndividualVotes> votesAssemblyTest = [];

  Future<bool> getVotes(String path) async {
    votesAssemblyTest =
        await OpenAssembleeJsonTranscoder().getJsonIndividualVotes(path);
    return true;
  }

  Widget DrawVoteHemicycle(String path) {
    return FutureBuilder(
      future: getVotes(path),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return CircularProgressIndicator();
        }
        if (snapshot.hasData) {
          return Center(
            child: DrawHemicycle(votesAssemblyTest.length,
                assemblyWidth: 0.75,
                nbRows: (votesAssemblyTest.length / 25).ceil(),
                individualVotes: votesAssemblyTest),
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
