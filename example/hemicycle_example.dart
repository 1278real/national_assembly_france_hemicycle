// Copyright 2022 1•2•7•8 réalisation(s). All rights reserved.
// Use of this source code is governed by a GNU-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../lib/hemicycle.dart';
import '../lib/attic/colors.dart';

void main() => runApp(HemicycleExample());

class HemicycleExample extends StatefulWidget {
  @override
  _HemicycleExampleState createState() => _HemicycleExampleState();
}

class _HemicycleExampleState extends State<HemicycleExample> {
  int numberTest = 0;
  int resteTest = 0;

  bool datasUpdated = false;

  List<GroupSectors> hemicycleTest = [];

  List<IndividualVotes> votesTest = [];

  @override
  void initState() {
    numberTest = 1;
    resteTest = 577 - numberTest - 1;

    List<GroupSectors> hemicycleTest = [
      GroupSectors(numberTest, customVoteFor, description: "BEFORE"),
      GroupSectors(1, customVoteAgainst, description: "NEW"),
      GroupSectors(resteTest, customVoteAbstention, description: "AFTER")
    ];

    List<IndividualVotes> votesTest = [
      IndividualVotes(33, voteResult: true, groupPairing: "AAA"),
      IndividualVotes(34, voteResult: true, groupPairing: "AAA"),
      IndividualVotes(35, voteResult: false, groupPairing: "AAA"),
      IndividualVotes(36, voteResult: true, groupPairing: "AAA"),
      IndividualVotes(37, voteResult: false, groupPairing: "AAA"),
      IndividualVotes(88, voteResult: true, groupPairing: "MMM"),
      IndividualVotes(89, voteResult: false, groupPairing: "MMM"),
      IndividualVotes(90, voteResult: false, groupPairing: "MMM"),
      IndividualVotes(122, voteResult: false, groupPairing: "ZZZ"),
      IndividualVotes(123, voteResult: false, groupPairing: "ZZZ"),
      IndividualVotes(124, voteResult: true, groupPairing: "ZZZ"),
      IndividualVotes(126, voteResult: true, groupPairing: "ZZZ"),
    ];

    updateAndRefresh();
    super.initState();
  }

  void updateAndRefresh() async {
    Future.delayed(Duration(milliseconds: 100), (() {
      setState(() {
        datasUpdated = true;
      });
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: <Widget>[
        if (datasUpdated)
          DrawHemicycle(200,
              nbRows: 8, individualVotes: votesTest, withLegend: true),
        if (datasUpdated)
          DrawHemicycle(
            resteTest + numberTest + 1,
            nbRows: ((resteTest + numberTest + 1) / 50).ceil(),
            groupSectors: hemicycleTest,
            withLegend: true,
            withTitle: true,
            title: "TEST",
          ),
        TextButton(
            onPressed: () {
              setState(() {
                numberTest += 1;
                datasUpdated = false;
              });
              updateAndRefresh();
            },
            child: Text(("PLUS UN... (" + numberTest.toString() + ")"))),
      ]),
    );
  }
}
