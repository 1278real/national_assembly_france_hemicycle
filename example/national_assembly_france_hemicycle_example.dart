// Copyright 2022 1•2•7•8 réalisation(s). All rights reserved.
// Use of this source code is governed by a GNU-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:national_assembly_france_hemicycle/national_assembly_france_hemicycle.dart';
import 'package:path_provider/path_provider.dart';

void main() => runApp(OpenAssembleeExample());

class OpenAssembleeExample extends StatefulWidget {
  @override
  _OpenAssembleeExampleState createState() => _OpenAssembleeExampleState();
}

class _OpenAssembleeExampleState extends State<OpenAssembleeExample> {
  bool datasUpdated = false;

  List<DossierLegislatifFromJson> dossiersLegisList = [];
  List<ProjetLoiFromJson> projetsLoisList = [];
  List<AmendementFromJson> amendementsList = [];
  List<ScrutinFromJson> votesList = [];

  void updateAndRefresh() async {
    Directory? _appSupportDirectory = await getApplicationSupportDirectory();

    getUpdatedDatasFromAssembly(
            pathToDossiers:
                "https://data.assemblee-nationale.fr/static/openData/repository/16/loi/dossiers_legislatifs/Dossiers_Legislatifs.json.zip",
            pathToVotes:
                "https://data.assemblee-nationale.fr/static/openData/repository/16/loi/scrutins/Scrutins.json.zip",
            pathToAmendements:
                "https://data.assemblee-nationale.fr/static/openData/repository/16/loi/amendements_div_legis/Amendements.json.zip",
            destinationDirectory: _appSupportDirectory)
        .then((boolean) async {
      print("getUpdatedDatasFromAssembly DONE");

      dossiersLegisList = await getListOfDossiersLegislatifs(
          mainDirectory: _appSupportDirectory);

      print("getListOfDossiersLegislatifs DONE");

      amendementsList =
          await getListOfAmendements(mainDirectory: _appSupportDirectory);

      print("getListOfAmendements DONE");

      projetsLoisList =
          await getListOfProjetsLois(mainDirectory: _appSupportDirectory);

      print("getListOfProjetsLois DONE");

      votesList = await getListOfVotes(mainDirectory: _appSupportDirectory);

      print("getListOfVotes DONE");

      setState(() {
        print(dossiersLegisList.length.toString() + " dossiers législatifs");
        print(amendementsList.length.toString() + " amendements");
        print(projetsLoisList.length.toString() + " projets de lois");
        print(votesList.length.toString() + " votes");
        datasUpdated = true;
      });
    });
  }

  @override
  void initState() {
    updateAndRefresh();
    super.initState();
  }

  Padding? legislativeFolderDisplay(
      DossierLegislatifFromJson dossier, BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 15),
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(
              width: 2,
            ),
            // Make rounded corners
            borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                (dossier.uuid ?? "-"),
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: ((dossier.votesRef ?? []).length > 0)
                        ? FontWeight.w900
                        : FontWeight.w600,
                    decoration: TextDecoration.underline,
                    fontSize: ((dossier.votesRef ?? []).length > 0) ? 9 : 7),
              ),
              Padding(padding: EdgeInsets.all(5)),
              Text(
                (dossier.titre ?? "-"),
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: ((dossier.votesRef ?? []).length > 0)
                        ? FontWeight.w900
                        : FontWeight.w600,
                    fontSize: ((dossier.votesRef ?? []).length > 0) ? 12 : 10),
              ),
              Text(
                dossier.lastLibelleActeLegislatif ?? "-",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.w300,
                    fontSize: ((dossier.votesRef ?? []).length > 0) ? 10 : 9),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: <Widget>[
        OpenAssembleeVoteDisplayer().drawVoteHemicycleFromPath(
            localPath: "assets/example_json/VTANR5L15V4417.json",
            useGroupSector: true),
        Padding(padding: EdgeInsets.all(20)),
        OpenAssembleeVoteDisplayer().drawVoteHemicycleFromPath(
            localPath: "assets/example_json/VTANR5L15V4418.json",
            useGroupSector: true),
        Padding(padding: EdgeInsets.all(20)),
        OpenAssembleeVoteDisplayer().drawVoteHemicycleFromPath(
            localPath: "assets/example_json/VTANR5L15V4419.json",
            useGroupSector: true),
        if (!datasUpdated) circularWait(Colors.lightGreen),
        for (DossierLegislatifFromJson dossier in dossiersLegisList)
          legislativeFolderDisplay(dossier, context) ??
              Padding(padding: EdgeInsets.all(0)),
      ]),
    );
  }
}
