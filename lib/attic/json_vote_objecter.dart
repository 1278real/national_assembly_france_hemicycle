import 'dart:math';

import 'package:flutter/material.dart';
import 'package:national_assembly_france_hemicycle/attic/colors.dart';
import 'package:national_assembly_france_hemicycle/attic/groupe_transcode.dart';

import 'helpers.dart';

/// TRANSFORM THE JSON FILE FROM OPEN DATA ASSEMBLEE NATIONALE TO :
///
/// [ScrutinFromJson] OBJECT that includes :
///   • ref to scrutin (uuid, organe, date)
///   • type of vote (code, title, majority)
///   • result of vote as announced
///   • title of the vote and its supplier
///   • an array of [GroupVotesFromJson]
///       ↳ each [GroupVotesFromJson] OBJECT includes :
///           • ref to group
///           • number of members
///           • votes in integer (for, against, abstention, did not vote but attended, did not attend)
///           • an array of [IndividualVoteFromJson]
///               ↳ each [IndividualVoteFromJson] OBJECT includes :
///                   • ref to voter (ref as a person, ref as a mandate)
///                   • whether it is "per delegation" or not
///                   • the actual vote

class IndividualVoteFromJson {
  String? acteurRef;
  String? mandatRef;
  bool? parDelegation;
  bool? votedFor;
  bool? votedAgainst;
  bool? didNotVote;
  bool? votedAbstention;

  /// [IndividualVoteFromJson] is the person voting
  IndividualVoteFromJson(this.acteurRef, this.mandatRef, this.parDelegation,
      this.votedFor, this.votedAgainst, this.didNotVote, this.votedAbstention);

  /// In case he was not even present for vote
  bool get didNotAttend {
    return (!(votedFor ?? false) &&
        !(votedAgainst ?? false) &&
        !(votedAbstention ?? false) &&
        !(didNotVote ?? false));
  }

  /// Mapping from JSON
  IndividualVoteFromJson.fromFrenchNationalAssemblyJson(
      Map<String, dynamic> json, String voteReceived) {
    this.acteurRef = json['acteurRef'];
    this.mandatRef = json['mandatRef'];
    this.parDelegation = json['parDelegation'] == "false" ? false : true;
    if (voteReceived == "pours") {
      votedFor = true;
    } else {
      votedFor = false;
    }
    if (voteReceived == "contres") {
      votedAgainst = true;
    } else {
      votedAgainst = false;
    }
    if (voteReceived == "abstentions") {
      votedAbstention = true;
    } else {
      votedAbstention = false;
    }
    if (voteReceived == "nonVotants") {
      didNotVote = true;
    } else {
      didNotVote = false;
    }
  }
}

class GroupVotesFromJson implements Comparable<GroupVotesFromJson> {
  String? organeRef;
  int? nbMembers;
  int? votedFor;
  int? votedAgainst;
  int? votedAbstention;
  int? didNotVote;
  List<IndividualVoteFromJson>? individualVotesDetails;
  String? majoriteVote;
  String? positionMajoritaire;

  /// [GroupVotesFromJson] is the group of persons
  GroupVotesFromJson(
      this.organeRef,
      this.nbMembers,
      this.votedFor,
      this.votedAgainst,
      this.votedAbstention,
      this.didNotVote,
      this.individualVotesDetails,
      this.majoriteVote);

  /// Calculate the numebr of group members that were not even present for vote
  int get didNotAttend {
    return (nbMembers ?? 0) -
        (votedFor ?? 0) -
        (votedAgainst ?? 0) -
        (votedAbstention ?? 0) -
        (didNotVote ?? 0);
  }

  /// Transcode the Group organeRef to a Political known group
  ///
  /// uses the [GroupTranscode] class
  GroupTranscode? get _groupTranscoded {
    for (var i = 0; i < groupsLegis15.length; i++) {
      if (groupsLegis15[i].organeRef == this.organeRef) {
        return groupsLegis15[i];
      }
    }
    for (var i = 0; i < groupsLegis16.length; i++) {
      if (groupsLegis16[i].organeRef == this.organeRef) {
        return groupsLegis16[i];
      }
    }
    return null;
  }

  /// Transcode the Group organeRef to a Political known intergroup
  ///
  /// uses the [IntergroupTranscode] class
  IntergroupTranscode? get _intergroupTranscoded {
    for (var i = 0; i < intergroupsLegis16.length; i++) {
      if (intergroupsLegis16[i]
          .groupeIndexes
          .contains(_groupTranscoded?.index ?? 999)) {
        return intergroupsLegis16[i];
      }
    }
    return null;
  }

  /// Used for left-to-right display
  int get groupIndex {
    if (_groupTranscoded != null) {
      return _groupTranscoded!.index;
    }
    return 0;
  }

  /// Political Color to display for Group
  Color get groupColor {
    if (_groupTranscoded != null) {
      return _groupTranscoded!.groupeColor;
    }
    return Color.fromARGB(255, 200, 200, 200);
  }

  /// Name to display for Group
  String get groupName {
    if (_groupTranscoded != null) {
      return _groupTranscoded!.name;
    }
    return "-";
  }

  /// Political Color to display for Intergroup
  Color? get intergroupColor {
    if (_intergroupTranscoded != null) {
      return _intergroupTranscoded!.intergroupeColor;
    }
    return null;
  }

  /// Name to display for Intergroup
  String get intergroupName {
    if (_intergroupTranscoded != null) {
      return _intergroupTranscoded!.name;
    }
    return "-";
  }

  /// return the [DeputesFromCsv] to highlight when NOT voting as their Group's majority
  List<IndividualVoteFromJson>? get deputesRefToHilite {
    if (individualVotesDetails != null) {
      List<IndividualVoteFromJson> _inGroupActeurRefsList = [];
      print(positionMajoritaire);
      for (IndividualVoteFromJson voter in individualVotesDetails!) {
        if ((voter.votedFor ?? false) &&
            (positionMajoritaire ?? "") != "pour") {
          _inGroupActeurRefsList.add(voter);
        } else if ((voter.votedAgainst ?? false) &&
            (positionMajoritaire ?? "") != "contre") {
          _inGroupActeurRefsList.add(voter);
        } else if ((voter.votedAbstention ?? false) &&
            (positionMajoritaire ?? "") != "abstention") {
          _inGroupActeurRefsList.add(voter);
        }
      }
      return _inGroupActeurRefsList;
    } else {
      return null;
    }
  }

  /// Mapping from JSON
  GroupVotesFromJson.fromFrenchNationalAssemblyJson(Map<String, dynamic> json,
      {required String majoriteVoteFromScrutin}) {
    this.majoriteVote = majoriteVoteFromScrutin;

    this.organeRef = json['organeRef'];
    this.nbMembers = int.tryParse(json['nombreMembresGroupe']) ?? 0;

    Map<String, dynamic> _vote = json["vote"];
    positionMajoritaire = _vote["positionMajoritaire"];
    Map<String, dynamic> _decompteVoix = _vote["decompteVoix"];

    this.votedFor = int.tryParse(_decompteVoix['pour']) ?? 0;
    this.votedAgainst = int.tryParse(_decompteVoix['contre']) ?? 0;
    this.votedAbstention = int.tryParse(_decompteVoix['abstentions']) ?? 0;
    this.didNotVote = int.tryParse(_decompteVoix['nonVotants']) ?? 0;

    List<IndividualVoteFromJson> _toPass = [];

    Map<String, dynamic> _decompteNominatif = _vote["decompteNominatif"];
    if (_decompteNominatif['pours'] != null) {
      // print("----- POURS not null");
      Map<String, dynamic> _voteResult = _decompteNominatif['pours'];
      if (this.votedFor != null && this.votedFor! > 1) {
        List<dynamic> _votants = _voteResult['votant'];

        for (var i = 0; i < _votants.length; i++) {
          Map<String, dynamic> _votant = _votants[i];

          _toPass.add(IndividualVoteFromJson.fromFrenchNationalAssemblyJson(
              _votant, "pours"));
        }
      } else if (this.votedFor != null) {
        Map<String, dynamic> _votant = _voteResult['votant'];
        _toPass.add(IndividualVoteFromJson.fromFrenchNationalAssemblyJson(
            _votant, "pours"));
      }
    }
    if (_decompteNominatif['contres'] != null) {
      // print("----- CONTRES not null");
      Map<String, dynamic> _voteResult = _decompteNominatif['contres'];
      if (this.votedAgainst != null && this.votedAgainst! > 1) {
        List<dynamic> _votants = _voteResult['votant'];

        for (var i = 0; i < _votants.length; i++) {
          Map<String, dynamic> _votant = _votants[i];

          _toPass.add(IndividualVoteFromJson.fromFrenchNationalAssemblyJson(
              _votant, "contres"));
        }
      } else if (this.votedAgainst != null) {
        Map<String, dynamic> _votant = _voteResult['votant'];
        _toPass.add(IndividualVoteFromJson.fromFrenchNationalAssemblyJson(
            _votant, "contres"));
      }
    }
    if (_decompteNominatif['abstentions'] != null) {
      // print("----- ABSTENTION not null");
      Map<String, dynamic> _voteResult = _decompteNominatif['abstentions'];
      if (this.votedAbstention != null && this.votedAbstention! > 1) {
        List<dynamic> _votants = _voteResult['votant'];

        for (var i = 0; i < _votants.length; i++) {
          Map<String, dynamic> _votant = _votants[i];

          _toPass.add(IndividualVoteFromJson.fromFrenchNationalAssemblyJson(
              _votant, "abstentions"));
        }
      } else if (this.votedAbstention != null) {
        Map<String, dynamic> _votant = _voteResult['votant'];
        _toPass.add(IndividualVoteFromJson.fromFrenchNationalAssemblyJson(
            _votant, "abstentions"));
      }
    }
    if (_decompteNominatif['nonVotants'] != null) {
      // print("----- NV not null");
      Map<String, dynamic> _voteResult = _decompteNominatif['nonVotants'];
      if (this.didNotVote != null && this.didNotVote! > 1) {
        List<dynamic> _votants = _voteResult['votant'];

        for (var i = 0; i < _votants.length; i++) {
          Map<String, dynamic> _votant = _votants[i];

          _toPass.add(IndividualVoteFromJson.fromFrenchNationalAssemblyJson(
              _votant, "nonVotants"));
        }
      } else if (this.didNotVote != null) {
        Map<String, dynamic> _votant = _voteResult['votant'];
        _toPass.add(IndividualVoteFromJson.fromFrenchNationalAssemblyJson(
            _votant, "nonVotants"));
      }
    }

    this.individualVotesDetails = _toPass;
  }

  @override
  int compareTo(GroupVotesFromJson other) {
    return this.groupIndex.compareTo(other
        .groupIndex); // this.compareTo.other = ordre GAUCHE > CENTRE > DROITE
  }
}

class ScrutinFromJson implements Comparable<ScrutinFromJson> {
  String? uuid;
  String? organeRef;
  String? numero;
  String? seanceRef;
  DateTime? dateScrutin;
  String? codeVote;
  String? libelleVote;
  String? majoriteVote;
  String? resultatVote;
  String? titre;
  String? demandeur;
  int? votedFor;
  int? votedAgainst;
  int? votedAbstention;
  int? didNotVote;
  List<GroupVotesFromJson>? groupVotesDetails;
  List<GroupVotesFromJson>? intergroupVotesDetails;

  /// [ScrutinFromJson] is the vote in the whole assembly
  ScrutinFromJson(
      this.uuid,
      this.organeRef,
      this.numero,
      this.seanceRef,
      this.dateScrutin,
      this.codeVote,
      this.libelleVote,
      this.majoriteVote,
      this.resultatVote,
      this.titre,
      this.demandeur,
      this.votedFor,
      this.votedAgainst,
      this.votedAbstention,
      this.didNotVote,
      this.groupVotesDetails,
      this.intergroupVotesDetails);

  /// calculate the number of actual voters
  int get nbVoters {
    return (votedFor ?? 0) + (votedAgainst ?? 0) + (votedAbstention ?? 0);
  }

  /// Mapping from JSON
  ScrutinFromJson.fromFrenchNationalAssemblyJson(Map<String, dynamic> _map) {
    Map<String, dynamic> json = _map["scrutin"];

    this.uuid = json['uid'];
    this.organeRef = json['organeRef'];
    this.numero = json['numero'];
    this.seanceRef = json['seanceRef'];
    this.dateScrutin = dateFormatter(json['dateScrutin'],
        dateSeparator: "-", format: "YMD", noHour: true);

    Map<String, dynamic> _typeVote = json["typeVote"];
    this.codeVote = _typeVote['codeTypeVote'];
    this.libelleVote = _typeVote['libelleTypeVote'];
    this.majoriteVote = _typeVote['typeMajorite'];

    Map<String, dynamic> _sort = json["sort"];
    this.resultatVote = _sort['code'];

    this.titre = json['titre'];

    Map<String, dynamic> _demandeur = json["demandeur"];
    this.demandeur = _demandeur['texte'];

    Map<String, dynamic> _syntheseVote = json["syntheseVote"];
    Map<String, dynamic> _decompte = _syntheseVote["decompte"];

    this.votedFor = int.tryParse(_decompte['pour']) ?? 0;
    this.votedAgainst = int.tryParse(_decompte['contre']) ?? 0;
    this.votedAbstention = int.tryParse(_decompte['abstentions']) ?? 0;
    this.didNotVote = int.tryParse(_decompte['nonVotants']) ?? 0;

    Map<String, dynamic> _ventilationVotes = json["ventilationVotes"];
    Map<String, dynamic> _organe = _ventilationVotes["organe"];
    Map<String, dynamic> _groupes = _organe["groupes"];

    List<dynamic> _roughJson = _groupes['groupe'];
    List<GroupVotesFromJson> _toPass = [];
    for (var i = 0; i < _roughJson.length; i++) {
      Map<String, dynamic> _toConvert = _roughJson[i];
      _toPass.add(GroupVotesFromJson.fromFrenchNationalAssemblyJson(_toConvert,
          majoriteVoteFromScrutin: _typeVote['typeMajorite']));
    }
    this.groupVotesDetails = _toPass;
  }

  /// Sorting rules
  @override
  int compareTo(ScrutinFromJson other) {
    return (int.tryParse((this.numero ?? "")) ?? 0)
        .compareTo((int.tryParse((other.numero ?? ""))) ?? 0);
  }
}

class AmendementFromJson implements Comparable<AmendementFromJson> {
  String? uuid;
  String? numeroLong;
  String? numeroOrdreDepot;
  String? texteLegislatifRef;
  String? libelleSignataires;
  String? cycleDeVieSort;
  String? exposeSommaire;
  String? dispositif;
  String? cartoucheInformatif;
  String? seanceDiscussionRef;

  /// [AmendementFromJson] is the detail of the Amendment to display
  AmendementFromJson(
      this.uuid,
      this.numeroLong,
      this.numeroOrdreDepot,
      this.texteLegislatifRef,
      this.libelleSignataires,
      this.cycleDeVieSort,
      this.exposeSommaire,
      this.dispositif,
      this.cartoucheInformatif,
      this.seanceDiscussionRef);

  /// Mapping from JSON
  AmendementFromJson.fromFrenchNationalAssemblyJson(Map<String, dynamic> _map) {
    Map<String, dynamic> json = _map["amendement"];

    this.uuid = json['uid'];

    Map<String, dynamic> _identification = json["identification"];
    this.numeroLong = _identification['numeroLong'];
    this.numeroOrdreDepot = _identification['numeroOrdreDepot'];

    this.texteLegislatifRef = json['texteLegislatifRef'];

    Map<String, dynamic> _signataires = json["signataires"];
    this.libelleSignataires = _signataires['libelle'];

    Map<String, dynamic> _corps = json["corps"];
    if (_corps['cartoucheInformatif'] != null) {
      if (_corps['cartoucheInformatif'].toString().substring(0, 1) != "{") {
        this.cartoucheInformatif = _corps['cartoucheInformatif'];
      }
    }
    Map<String, dynamic> _contenuAuteur = _corps["contenuAuteur"];
    if (_contenuAuteur['exposeSommaire'] != null) {
      this.exposeSommaire = _contenuAuteur['exposeSommaire'];
    }
    if (_contenuAuteur['dispositif'] != null) {
      this.dispositif = _contenuAuteur['dispositif'];
    }

    Map<String, dynamic> _cycleDeVie = json["cycleDeVie"];
    if (_cycleDeVie['sort'].toString().substring(0, 1) == "{") {
      this.cycleDeVieSort = "";
    } else if (_cycleDeVie['sort'].toString().substring(0, 1) != "{") {
      this.cycleDeVieSort = _cycleDeVie['sort'];
    }

    if (json['seanceDiscussionRef'].toString().substring(0, 1) != "{") {
      this.seanceDiscussionRef = json['seanceDiscussionRef'];
    }
  }

  /// Get the sorting order : Commission job after Overall meeting
  int get ordreTri {
    if ((this.numeroLong ?? "").length > 2) {
      if ((this.numeroLong ?? "").substring(0, 2) == "AC") {
        // affaires culturelles
        return 10000 +
            (int.tryParse((this.numeroLong ?? "").replaceAll(" (Rect)", "")) ??
                0);
      }
      if ((this.numeroLong ?? "").substring(0, 2) == "AS") {
        // affaires sociales
        return 20000 +
            (int.tryParse((this.numeroLong ?? "").replaceAll(" (Rect)", "")) ??
                0);
      }
      if ((this.numeroLong ?? "").substring(0, 2) == "CE") {
        // affaires écos
        return 30000 +
            (int.tryParse((this.numeroLong ?? "").replaceAll(" (Rect)", "")) ??
                0);
      }
      if ((this.numeroLong ?? "").substring(0, 2) == "CF") {
        // comm finances
        return 40000 +
            (int.tryParse((this.numeroLong ?? "").replaceAll(" (Rect)", "")) ??
                0);
      }
      if ((this.numeroLong ?? "").substring(0, 2) == "CL") {
        // comm lois
        return 50000 +
            (int.tryParse((this.numeroLong ?? "").replaceAll(" (Rect)", "")) ??
                0);
      }
    }
    return (int.tryParse((this.numeroLong ?? "").replaceAll(" (Rect)", "")) ??
        0);
  }

  /// Get the 'translation' of the Long number into an understandable String
  ///
  /// From :
  ///   AC1
  ///   CL13
  /// To :
  ///   Aff. Cult. #1
  ///   Comm. Lois #13
  String? get numeroLongTranslate {
    if ((this.numeroLong ?? "").length > 2) {
      if ((this.numeroLong ?? "").substring(0, 2) == "AC") {
        // affaires culturelles
        return "Aff. Cult. #" + (this.numeroLong ?? "").substring(2);
      }
      if ((this.numeroLong ?? "").substring(0, 2) == "AS") {
        // affaires sociales
        return "Aff. Soc. #" + (this.numeroLong ?? "").substring(2);
      }
      if ((this.numeroLong ?? "").substring(0, 2) == "CE") {
        // affaires écos
        return "Aff. Éco. #" + (this.numeroLong ?? "").substring(2);
      }
      if ((this.numeroLong ?? "").substring(0, 2) == "CF") {
        // comm finances
        return "Comm. Fin. #" + (this.numeroLong ?? "").substring(2);
      }
      if ((this.numeroLong ?? "").substring(0, 2) == "CL") {
        // comm lois
        return "Comm. Lois #" + (this.numeroLong ?? "").substring(2);
      }
    }
    return "#" + (this.numeroLong ?? "");
  }

  /// Sorting rules
  @override
  int compareTo(AmendementFromJson other) {
    return this.ordreTri.compareTo(other.ordreTri);
  }
}

class DossierLegislatifFromJson
    implements Comparable<DossierLegislatifFromJson> {
  String? uuid;
  String? legislature;
  String? titre;
  String? libelleProcedureParlementaire;
  String? lastLibelleActeLegislatif;
  List<ActeLegislatifFromJson>? actesLegislatifs;

  /// [DossierLegislatifFromJson] is the detail of the Legislative File to display
  DossierLegislatifFromJson(
      this.uuid,
      this.legislature,
      this.titre,
      this.libelleProcedureParlementaire,
      this.lastLibelleActeLegislatif,
      this.actesLegislatifs);

  /// Mapping from JSON
  DossierLegislatifFromJson.fromFrenchNationalAssemblyJson(
      Map<String, dynamic> _map) {
    Map<String, dynamic> json = _map["dossierParlementaire"];

    this.uuid = json['uid'];
    this.legislature = json['legislature'];

    Map<String, dynamic> _titreDossier = json["titreDossier"];
    this.titre = _titreDossier['titre'];

    Map<String, dynamic> _procedureParlementaire =
        json["procedureParlementaire"];
    this.libelleProcedureParlementaire = _procedureParlementaire['libelle'];

    Map<String, dynamic> _actesLegislatifs = json["actesLegislatifs"];

    if (_actesLegislatifs["acteLegislatif"].toString().substring(0, 1) == "{") {
      this.actesLegislatifs = [
        ActeLegislatifFromJson.fromFrenchNationalAssemblyJson(
            _actesLegislatifs["acteLegislatif"])
      ];

      this.lastLibelleActeLegislatif =
          ActeLegislatifFromJson.fromFrenchNationalAssemblyJson(
                  _actesLegislatifs["acteLegislatif"])
              .libelleActeLegislatif;
    } else if (_actesLegislatifs["acteLegislatif"].toString().substring(0, 1) ==
        "[") {
      List<ActeLegislatifFromJson> _temp = [];
      List<dynamic> _acteLegislatifList =
          _actesLegislatifs["acteLegislatif"] as List;
      for (dynamic instance in _acteLegislatifList) {
        Map<String, dynamic> _acteLegislatif = instance;
        _temp.add(ActeLegislatifFromJson.fromFrenchNationalAssemblyJson(
            _acteLegislatif));
      }
      this.actesLegislatifs = _temp;
      Map<String, dynamic> _acteLegislatif = _acteLegislatifList.last;
      this.lastLibelleActeLegislatif =
          ActeLegislatifFromJson.fromFrenchNationalAssemblyJson(_acteLegislatif)
              .libelleActeLegislatif;
    }
  }

  // Get the list of Votes among [actesLegislatifs]
  List<String>? get votesRef {
    List<String> _tempVotes = [];
    if (this.actesLegislatifs != null) {
      for (ActeLegislatifFromJson acte in this.actesLegislatifs!) {
        if (acte.votesRef != null && acte.votesRef != []) {
          for (String vote in acte.votesRef!) {
            if (vote.contains("L16")) {
              _tempVotes.add(vote);
            }
          }
        }
        if (acte.actesIntra != null && acte.actesIntra != []) {
          for (ActeLegislatifFromJson subActe
              in acte.actesIntra as List<ActeLegislatifFromJson>) {
            if (subActe.votesRef != null && subActe.votesRef != []) {
              for (String vote in subActe.votesRef!) {
                if (vote.contains("L16")) {
                  _tempVotes.add(vote);
                }
              }
            }
            if (subActe.actesIntra != null && subActe.actesIntra != []) {
              for (ActeLegislatifFromJson subSubActe
                  in subActe.actesIntra as List<ActeLegislatifFromJson>) {
                if (subSubActe.votesRef != null && subSubActe.votesRef != []) {
                  for (String vote in subSubActe.votesRef!) {
                    if (vote.contains("L16")) {
                      _tempVotes.add(vote);
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
    return _tempVotes;
  }

  // Get the list of Reunions among [actesLegislatifs]
  List<String>? get reunionsRef {
    List<String> _tempReunions = [];
    if (this.actesLegislatifs != null) {
      for (ActeLegislatifFromJson acte in this.actesLegislatifs!) {
        if (acte.reunionRef != null && acte.reunionRef != "") {
          _tempReunions.add(acte.reunionRef!);
        }
        if (acte.actesIntra != null && acte.actesIntra != []) {
          for (ActeLegislatifFromJson subActe
              in acte.actesIntra as List<ActeLegislatifFromJson>) {
            if (subActe.reunionRef != null && subActe.reunionRef != "") {
              _tempReunions.add(subActe.reunionRef!);
            }
            if (subActe.actesIntra != null && subActe.actesIntra != []) {
              for (ActeLegislatifFromJson subSubActe
                  in subActe.actesIntra as List<ActeLegislatifFromJson>) {
                if (subSubActe.reunionRef != null &&
                    subSubActe.reunionRef != "") {
                  _tempReunions.add(subSubActe.reunionRef!);
                }
                if (subSubActe.actesIntra != null &&
                    subSubActe.actesIntra != []) {
                  for (ActeLegislatifFromJson subSubSubActe in subSubActe
                      .actesIntra as List<ActeLegislatifFromJson>) {
                    if (subSubSubActe.reunionRef != null &&
                        subSubSubActe.reunionRef != "") {
                      _tempReunions.add(subSubSubActe.reunionRef!);
                    }
                    if (subSubSubActe.actesIntra != null &&
                        subSubSubActe.actesIntra != []) {
                      for (ActeLegislatifFromJson subSubSubSubActe
                          in subSubSubActe.actesIntra
                              as List<ActeLegislatifFromJson>) {
                        if (subSubSubSubActe.reunionRef != null &&
                            subSubSubSubActe.reunionRef != "") {
                          _tempReunions.add(subSubSubSubActe.reunionRef!);
                        }
                        if (subSubSubSubActe.actesIntra != null &&
                            subSubSubSubActe.actesIntra != []) {
                          for (ActeLegislatifFromJson subSubSubSubSubActe
                              in subSubSubSubActe.actesIntra
                                  as List<ActeLegislatifFromJson>) {
                            if (subSubSubSubSubActe.reunionRef != null &&
                                subSubSubSubSubActe.reunionRef != "") {
                              _tempReunions
                                  .add(subSubSubSubSubActe.reunionRef!);
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }

    _tempReunions.sort();

    for (int i = 0; i < _tempReunions.length; i++) {
      for (int j = i + 1; j < _tempReunions.length; j++) {
        if (_tempReunions[i] == _tempReunions[j]) {
          _tempReunions.removeAt(j);
        }
      }
    }

    return _tempReunions;
  }

  /// Sorting rules
  @override
  int compareTo(DossierLegislatifFromJson other) {
    var comparisonResult =
        (other.votesRef?.length ?? 0).compareTo((this.votesRef?.length ?? 0));
    if (comparisonResult != 0) {
      return comparisonResult;
    }
    return (other.uuid ?? "emptyA").compareTo((this.uuid ?? "emptyB"));
  }
}

class ProjetLoiFromJson implements Comparable<ProjetLoiFromJson> {
  String? uuid;
  String? legislature;
  String? titre;
  String? dossierRef;
  DateTime? dateDepot;

  /// [ProjetLoiFromJson] is the detail of the Law Project to display
  ProjetLoiFromJson(
      this.uuid, this.legislature, this.titre, this.dossierRef, this.dateDepot);

  /// Mapping from JSON
  ProjetLoiFromJson.fromFrenchNationalAssemblyJson(Map<String, dynamic> _map) {
    Map<String, dynamic> json = _map["document"];

    this.uuid = json['uid'];
    this.legislature = json['legislature'];

    Map<String, dynamic> _titreDossier = json["titres"];
    this.titre = _titreDossier['titrePrincipal'];

    this.dossierRef = json['dossierRef'];

    Map<String, dynamic> _cycleDeVie = json["cycleDeVie"];
    Map<String, dynamic> _chrono = _cycleDeVie["chrono"];
    this.dateDepot = _chrono["dateDepot"].toString().length > 9
        ? dateFormatter(_chrono["dateDepot"].toString().split("T")[0],
            dateSeparator: "-", noHour: true, format: "YMD")
        : DateTime.now();
  }

  /// Get a boolean to know if the Law project is adopted or not
  bool get isAdopted {
    if ((this.uuid ?? "-").contains("BTA") ||
        (this.uuid ?? "-").contains("BTS") ||
        (this.uuid ?? "-").contains("BTC") ||
        (this.uuid ?? "-").contains("BTG")) {
      return true;
    }
    return false;
  }

  /// Get the 'translation' of the Uuid into an understandable String
  ///
  /// from :
  ///   PRJLANR5L16BTC0144 / PRJLSNR5S359B0561
  /// to :
  ///   Proj. Loi Ass. Nat. Ve Répub. Légis. 16 Adopté Commission au fond 0144
  ///   Proj. Loi Sénat Ve Répub. Sess. 359 Non adopté 0561
  ///

  String get uuidTranslate {
    String _toReturn = "";
    String _localUuid = this.uuid ?? "-";

    if (_localUuid.substring(0, 4) == "PRJL") {
      _toReturn += "Proj.Loi ";
      if (_localUuid.substring(4, 6) == "AN") {
        _toReturn += "(Ass.Nat. - ";
      } else if (_localUuid.substring(4, 6) == "SN") {
        _toReturn += "(Sénat - ";
      }
      if (_localUuid.substring(6, 8) == "R5") {
        _toReturn += "Ve Rép. ";
      } else if (_localUuid.substring(6, 8) == "R6") {
        _toReturn += "VIe Rép. ";
      }
      if (_localUuid.substring(8, 9) == "L") {
        _toReturn += "Légis." + _localUuid.substring(9, 11) + ") • ";
        if (_localUuid.substring(11, 14) == "BTA") {
          _toReturn += "ADOPTÉ " + _localUuid.substring(14);
        } else if (_localUuid.substring(11, 14) == "BTS") {
          _toReturn += "ADOPTÉ Séance " + _localUuid.substring(14);
        } else if (_localUuid.substring(11, 14) == "BTC") {
          _toReturn += "ADOPTÉ Commission au fond " + _localUuid.substring(14);
        } else if (_localUuid.substring(11, 14) == "BTG") {
          _toReturn += "ADOPTÉ en Congrès " + _localUuid.substring(14);
        } else if (_localUuid.substring(11, 12) == "B") {
          _toReturn += "-NON- ADOPTÉ " + _localUuid.substring(12);
        }
      } else if (_localUuid.substring(8, 9) == "S") {
        _toReturn += "Sess." + _localUuid.substring(9, 12) + ") • ";
        if (_localUuid.substring(12, 15) == "BTA") {
          _toReturn += "ADOPTÉ " + _localUuid.substring(15);
        } else if (_localUuid.substring(12, 15) == "BTS") {
          _toReturn += "ADOPTÉ Séance " + _localUuid.substring(15);
        } else if (_localUuid.substring(12, 15) == "BTC") {
          _toReturn += "ADOPTÉ Commission au fond " + _localUuid.substring(15);
        } else if (_localUuid.substring(12, 15) == "BTG") {
          _toReturn += "ADOPTÉ en Congrès " + _localUuid.substring(15);
        } else if (_localUuid.substring(12, 13) == "B") {
          _toReturn += "-NON- ADOPTÉ " + _localUuid.substring(13);
        }
      }
    }
    if (_toReturn == "") {
      return _localUuid;
    } else {
      return _toReturn;
    }
  }

  /// Sorting rules
  @override
  int compareTo(ProjetLoiFromJson other) {
    return (this.dateDepot ?? DateTime.now())
        .compareTo((other.dateDepot ?? DateTime.now()));
  }
}

class ActeLegislatifFromJson {
  String? uuid;
  String? libelleActeLegislatif;
  List<String>? votesRef;
  String? reunionRef;
  dynamic actesIntra;

  ActeLegislatifFromJson(
      this.uuid, this.libelleActeLegislatif, this.actesIntra);

  /// Mapping from JSON
  ActeLegislatifFromJson.fromFrenchNationalAssemblyJson(
      Map<String, dynamic> _acteLegislatif) {
    this.uuid = _acteLegislatif["uid"];
    this.reunionRef = _acteLegislatif["reunionRef"];

    List<String> _tempVotes = [];
    if (_acteLegislatif["voteRefs"] != null) {
      Map<String, dynamic> _voteRefs = _acteLegislatif["voteRefs"];
      _tempVotes
          .add(_voteRefs['voteRef'] + "_" + _acteLegislatif["reunionRef"]);
    }

    Map<String, dynamic> _libelleActe = _acteLegislatif["libelleActe"];
    this.libelleActeLegislatif = _libelleActe['nomCanonique'];

    if (_acteLegislatif["actesLegislatifs"] != null) {
      // this.actesIntra = _acteLegislatif["actesLegislatifs"];

      Map<String, dynamic> _subActesLegislatifs =
          _acteLegislatif["actesLegislatifs"];

      if (_subActesLegislatifs["acteLegislatif"].toString().substring(0, 1) ==
          "{") {
        this.actesIntra = [
          ActeLegislatifFromJson.fromFrenchNationalAssemblyJson(
              _subActesLegislatifs["acteLegislatif"])
        ];
      } else if (_subActesLegislatifs["acteLegislatif"]
              .toString()
              .substring(0, 1) ==
          "[") {
        List<ActeLegislatifFromJson> _temp = [];
        List<dynamic> _acteLegislatifList =
            _subActesLegislatifs["acteLegislatif"] as List;
        for (dynamic instance in _acteLegislatifList) {
          Map<String, dynamic> _acteLegislatif = instance;
          _temp.add(ActeLegislatifFromJson.fromFrenchNationalAssemblyJson(
              _acteLegislatif));
        }
        this.actesIntra = _temp;
      }
    }
    this.votesRef = _tempVotes;
  }
}

class ReturnFromJson {
  ScrutinFromJson scrutin;
  AmendementFromJson? amendement;

  ReturnFromJson(this.scrutin, {this.amendement});
}

enum politicalPartiesEnum {
  DIV,
  DLF,
  DVC,
  DVD,
  DVE,
  DVG,
  EELV,
  EXD,
  EXG,
  LFI,
  LO,
  LR,
  LREM,
  NUPES_ALL,
  NUPES_ECOLO,
  NUPES_LFI,
  NUPES_PCF,
  NUPES_PS,
  NPA,
  PCF,
  PS,
  RN,
  UDI,
  SE,
  blancs_ou_nul,
  abstention
}

class PoliticalParties implements Comparable<PoliticalParties> {
  politicalPartiesEnum code;

  // CONSTRUCTOR

  PoliticalParties(this.code);

  // GETTERS

  String get name {
    if (code.name.startsWith("NUPES")) {
      return "NUPES";
    } else {
      return code.name;
    }
  }

  bool get isNupes {
    bool _prefFeedback = false;

    if (code == politicalPartiesEnum.LFI ||
        code == politicalPartiesEnum.PCF ||
        code == politicalPartiesEnum.EELV ||
        code == politicalPartiesEnum.PS ||
        code == politicalPartiesEnum.NUPES_ALL ||
        code == politicalPartiesEnum.NUPES_ECOLO ||
        code == politicalPartiesEnum.NUPES_LFI ||
        code == politicalPartiesEnum.NUPES_PCF ||
        code == politicalPartiesEnum.NUPES_PS) {
      _prefFeedback = true;
    }

    return _prefFeedback;
  }

  Color get partiColor {
    Color _theColor = Colors.white;

    if (code == politicalPartiesEnum.EXG) {
      _theColor = Color.fromARGB(255, 94, 0, 0);
    } else if (code == politicalPartiesEnum.LO) {
      _theColor = Color.fromARGB(255, 154, 0, 0);
    } else if (code == politicalPartiesEnum.NPA) {
      _theColor = Color.fromARGB(255, 204, 0, 0);
    } else if (code == politicalPartiesEnum.LFI ||
        code == politicalPartiesEnum.NUPES_LFI ||
        code == politicalPartiesEnum.NUPES_ALL) {
      _theColor = nupesViolet;
    } else if (code == politicalPartiesEnum.PCF ||
        code == politicalPartiesEnum.NUPES_PCF) {
      _theColor = nupesRouge;
    } else if (code == politicalPartiesEnum.EELV ||
        code == politicalPartiesEnum.NUPES_ECOLO) {
      _theColor = nupesVert;
    } else if (code == politicalPartiesEnum.DVE) {
      _theColor = nupesJaune;
    } else if (code == politicalPartiesEnum.PS ||
        code == politicalPartiesEnum.NUPES_PS) {
      _theColor = nupesRose;
    } else if (code == politicalPartiesEnum.DVG) {
      _theColor = liotRose;
    } else if (code == politicalPartiesEnum.LREM) {
      _theColor = renaissanceOrange;
    } else if (code == politicalPartiesEnum.DVC) {
      _theColor = modemJaune;
    } else if (code == politicalPartiesEnum.LR) {
      _theColor = republicainsBleu;
    } else if (code == politicalPartiesEnum.DVD ||
        code == politicalPartiesEnum.UDI) {
      _theColor = udiBleu;
    } else if (code == politicalPartiesEnum.DLF) {
      _theColor = Color.fromARGB(255, 12, 0, 93);
    } else if (code == politicalPartiesEnum.EXD) {
      _theColor = Color.fromARGB(255, 0, 0, 0);
    } else if (code == politicalPartiesEnum.RN) {
      _theColor = rnBleu;
    } else if (code == politicalPartiesEnum.DIV) {
      _theColor = Color.fromARGB(255, 200, 200, 200);
    } else if (code == politicalPartiesEnum.SE) {
      _theColor = nonInscritGris;
    } else if (code == politicalPartiesEnum.blancs_ou_nul) {
      _theColor = Color.fromARGB(255, 190, 190, 190);
    } else if (code == politicalPartiesEnum.abstention) {
      _theColor = Color.fromARGB(255, 220, 220, 220);
    }

    return _theColor;
  }

  Color get alterPartiColor {
    int _red = partiColor.red;
    int _green = partiColor.green;
    int _blue = partiColor.blue;

    double multiplier = (_red + _green + _blue) / 1.5;

    int _newRed = min((_red + multiplier).round(), 255);
    int _newGreen = min((_green + multiplier).round(), 255);
    int _newBlue = min((_blue + multiplier).round(), 255);

    return Color.fromARGB(255, _newRed, _newGreen, _newBlue);
  }

  Color get textPartiColor {
    int _red = partiColor.red;
    int _green = partiColor.green;
    int _blue = partiColor.blue;

    double multiplier = (_red + _green + _blue) / 3;

    int _newRed = (_red > multiplier ? 0 : 255);
    int _newGreen = (_green > multiplier ? 0 : 255);
    int _newBlue = (_blue > multiplier ? 0 : 255);

    return Color.fromARGB(255, _newRed, _newGreen, _newBlue);
  }

  @override
  int compareTo(PoliticalParties other) {
    return this.code.index.compareTo(other
        .code.index); // this.compareTo.other = ordre GAUCHE > CENTRE > DROITE
  }
}

List<List<dynamic>> legisGroupsSubstitute = [
  [
    "GDR - NUPES",
    "Gauche Démocrate et Républicaine - NUPES",
    [PoliticalParties(politicalPartiesEnum.NUPES_PCF)]
  ],
  [
    "LFI – NUPES",
    "La France Insoumise - NUPES",
    [PoliticalParties(politicalPartiesEnum.NUPES_LFI)]
  ],
  [
    "SOC",
    "Socialistes - NUPES",
    [PoliticalParties(politicalPartiesEnum.NUPES_PS)]
  ],
  [
    "Ecolo - NUPES",
    "Ecologistes - NUPES",
    [PoliticalParties(politicalPartiesEnum.NUPES_ECOLO)]
  ],
  [
    "RN",
    "Rassemblement National",
    [PoliticalParties(politicalPartiesEnum.RN)]
  ],
  [
    "RE",
    "Renaissance",
    [PoliticalParties(politicalPartiesEnum.LREM)]
  ],
  [
    "Dem",
    "Démocrates",
    [
      PoliticalParties(politicalPartiesEnum.LREM),
      PoliticalParties(politicalPartiesEnum.DVC)
    ]
  ],
  [
    "HOR",
    "Horizons",
    [
      PoliticalParties(politicalPartiesEnum.LREM),
      PoliticalParties(politicalPartiesEnum.DVD)
    ]
  ],
  [
    "LR",
    "Les Républicains",
    [PoliticalParties(politicalPartiesEnum.LR)]
  ],
  [
    "LIOT",
    "Libertés, Indépendants, Outre-mer et Territoires",
    [PoliticalParties(politicalPartiesEnum.DIV)]
  ],
  [
    "NI",
    "Non Inscrits",
    [PoliticalParties(politicalPartiesEnum.SE)]
  ],
];

class DeputesFromCsv implements Comparable<DeputesFromCsv> {
  String identifiant;
  String prenom;
  String nom;
  String region;
  String departement;
  String circoShort;
  String profession;
  String groupeLong;
  String groupShort;
  bool? votedFor;
  bool? votedAgainst;
  bool? didNotVote;
  bool? votedAbstention;

  // CONSTRUCTOR

  DeputesFromCsv(
      this.identifiant,
      this.prenom,
      this.nom,
      this.region,
      this.departement,
      this.circoShort,
      this.profession,
      this.groupShort,
      this.groupeLong,
      this.votedFor,
      this.votedAgainst,
      this.didNotVote,
      this.votedAbstention);

  // GETTERS

  PoliticalParties get groupe {
    List<PoliticalParties> _toReturn = [
      PoliticalParties(politicalPartiesEnum.SE)
    ];
    // print("groupShort=" + groupShort + "-");
    for (var i = 0; i < legisGroupsSubstitute.length; i++) {
      // print("groupesSubstitute=" + groupesSubstitute[i][0] + "-");
      if (groupShort == legisGroupsSubstitute[i][0]) {
        // print("groupesSubstitute");
        _toReturn = legisGroupsSubstitute[i][2];
      }
    }
    // print("_toReturn");
    return _toReturn[0];
  }

  LinearGradient get groupeGradient {
    List<Color> _colors = [
      PoliticalParties(politicalPartiesEnum.SE).partiColor.withOpacity(0.65),
      PoliticalParties(politicalPartiesEnum.SE).partiColor.withOpacity(0.15),
      PoliticalParties(politicalPartiesEnum.SE).partiColor.withOpacity(0.15),
      PoliticalParties(politicalPartiesEnum.SE).partiColor.withOpacity(0.65)
    ];
    List<double> _stops = [0, 0.4, 0.6, 1];
    for (var i = 0; i < legisGroupsSubstitute.length; i++) {
      if (groupShort.replaceAll(".", ",") == legisGroupsSubstitute[i][0]) {
        if (legisGroupsSubstitute[i][2].length == 1) {
          _colors = [
            legisGroupsSubstitute[i][2][0].partiColor.withOpacity(0.65),
            legisGroupsSubstitute[i][2][0].partiColor.withOpacity(0.1),
            legisGroupsSubstitute[i][2][0].partiColor.withOpacity(0.1),
            legisGroupsSubstitute[i][2][0].partiColor.withOpacity(0.65)
          ];
          _stops = [0, 0.3, 0.7, 1];
        } else if (legisGroupsSubstitute[i][2].length == 2) {
          _colors = [];
          _stops = [];
          _colors
              .add(legisGroupsSubstitute[i][2][0].partiColor.withOpacity(0.65));
          _stops.add(0.1);
          _colors
              .add(legisGroupsSubstitute[i][2][0].partiColor.withOpacity(0.1));
          _stops.add(0.3);
          _colors
              .add(legisGroupsSubstitute[i][2][1].partiColor.withOpacity(0.1));
          _stops.add(0.7);
          _colors
              .add(legisGroupsSubstitute[i][2][1].partiColor.withOpacity(0.65));
          _stops.add(0.9);
        } else {
          _colors = [];
          _stops = [];
          for (int j = 0; j < legisGroupsSubstitute[i][2].length; j++) {
            _colors.add(
                legisGroupsSubstitute[i][2][j].partiColor.withOpacity(0.75));
            _stops.add(
                0.1 + (j / (legisGroupsSubstitute[i][2].length - 1)) * 0.8);
          }
        }
      }
    }
    return LinearGradient(
      colors: _colors,
      stops: _stops,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  String get deputeRef {
    return "PA" + identifiant;
  }

  DeputesFromCsv.fromVote(DeputesFromCsv depute, IndividualVoteFromJson voter)
      : identifiant = depute.identifiant,
        prenom = depute.prenom,
        nom = depute.nom,
        region = depute.nom,
        departement = depute.departement,
        circoShort = depute.circoShort,
        profession = depute.profession,
        groupeLong = depute.groupeLong,
        groupShort = depute.groupShort,
        votedFor = voter.votedFor,
        votedAgainst = voter.votedAgainst,
        didNotVote = voter.didNotVote,
        votedAbstention = voter.votedAbstention;

  DeputesFromCsv.fromFrenchNationalAssemblyCsv(List<dynamic> csv)
      : identifiant = csv[0].toString(),
        prenom = csv[1],
        nom = csv[2],
        region = csv[3],
        departement = csv[4],
        circoShort = csv[5].toString(),
        profession = csv[6],
        groupeLong = csv[7],
        groupShort = csv[8].toString().trimRight();

  @override
  int compareTo(DeputesFromCsv other) {
    return (this.identifiant).compareTo(
        (other.identifiant)); // this.compareTo.other = ordre CHRONO debut
  }
}
