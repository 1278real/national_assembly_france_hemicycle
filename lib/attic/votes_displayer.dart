import 'package:flutter/material.dart';
import 'package:hemicycle/attic/drawHemicycle.dart';
import 'package:hemicycle/hemicycle.dart';

import 'json_transcoder.dart';

class OpenAssembleeVoteDisplayer {
  List<IndividualVotes> votesAssemblyTest = [];

  void getVotes() async {
    votesAssemblyTest = await OpenAssembleeJsonTranscoder()
        .getJsonIndividualVotes("assets/example_json/VTANR5L15V4417.json");
  }

  Future<Widget> DrawVoteHemicycle(String path) async {
    getVotes();
    return Center(
      child: DrawHemicycle(votesAssemblyTest.length,
          assemblyWidth: 0.75,
          nbRows: (votesAssemblyTest.length / 25).ceil(),
          individualVotes: votesAssemblyTest),
    );
  }
}
