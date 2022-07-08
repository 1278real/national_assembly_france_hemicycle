// Copyright 2022 1•2•7•8 réalisation(s). All rights reserved.
// Use of this source code is governed by a GNU-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hemicycle/attic/colors.dart';

import 'package:hemicycle/hemicycle.dart';
import '../lib/attic/votes_displayer.dart';

import '../lib/national_assembly_france_hemicycle.dart';
import '../lib/attic/colors.dart';

void main() => runApp(OpenAssembleeExample());

class OpenAssembleeExample extends StatefulWidget {
  @override
  _OpenAssembleeExampleState createState() => _OpenAssembleeExampleState();
}

class _OpenAssembleeExampleState extends State<OpenAssembleeExample> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: <Widget>[
        OpenAssembleeVoteDisplayer().DrawVoteHemicycle(
            "assets/example_json/VTANR5L15V4417.json",
            useGroupSector: true),
        Padding(padding: EdgeInsets.all(20)),
        OpenAssembleeVoteDisplayer().DrawVoteHemicycle(
            "assets/example_json/VTANR5L15V4418.json",
            useGroupSector: true),
        Padding(padding: EdgeInsets.all(20)),
        OpenAssembleeVoteDisplayer().DrawVoteHemicycle(
            "assets/example_json/VTANR5L15V4419.json",
            useGroupSector: true),
      ]),
    );
  }
}
