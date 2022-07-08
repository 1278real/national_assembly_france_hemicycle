import 'package:flutter/material.dart';
import 'package:hemicycle/attic/drawHemicycle.dart';
import 'package:hemicycle/hemicycle.dart';

import 'json_transcoder.dart';

class OpenAssembleeVoteDisplayer {
  List<IndividualVotes> votesAssemblyTest = [];

  void getVotes(String path) async {
    votesAssemblyTest =
        await OpenAssembleeJsonTranscoder().getJsonIndividualVotes(path);
  }

  Widget DrawVoteHemicycle(String path) {
    getVotes(path);
    return Center(
      child: DrawHemicycle(votesAssemblyTest.length,
          assemblyWidth: 0.75,
          nbRows: (votesAssemblyTest.length / 25).ceil(),
          individualVotes: votesAssemblyTest),
    );
  }
}
