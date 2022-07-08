import 'package:flutter/material.dart';
import 'package:hemicycle/attic/drawHemicycle.dart';
import 'package:hemicycle/hemicycle.dart';

import 'json_transcoder.dart';

class OpenAssembleeVoteDisplayer extends StatefulWidget {
  @override
  _OpenAssembleeVoteDisplayerState createState() =>
      _OpenAssembleeVoteDisplayerState();
}

class _OpenAssembleeVoteDisplayerState
    extends State<OpenAssembleeVoteDisplayer> {
  List<IndividualVotes> votesAssemblyTest = [];

  void getVotes() async {
    votesAssemblyTest = await OpenAssembleeJsonTranscoder()
        .getJsonIndividualVotes("assets/example_json/VTANR5L15V4417.json");
    setState(() {
      //
    });
  }

  Widget DrawVoteHemicycle(String path) {
    getVotes();
    return Center(
      child: DrawHemicycle(votesAssemblyTest.length,
          assemblyWidth: 0.75,
          nbRows: (votesAssemblyTest.length / 25).ceil(),
          individualVotes: votesAssemblyTest),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
