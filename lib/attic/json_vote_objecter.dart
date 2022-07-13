import 'package:flutter/material.dart';
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

  /// [GroupVotesFromJson] is the group of persons
  GroupVotesFromJson(
      this.organeRef,
      this.nbMembers,
      this.votedFor,
      this.votedAgainst,
      this.votedAbstention,
      this.didNotVote,
      this.individualVotesDetails);

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

  /// Used ofr left-to-right display
  int get groupIndex {
    if (_groupTranscoded != null) {
      return _groupTranscoded!.index;
    }
    return 0;
  }

  /// Political Color to display
  Color get groupColor {
    if (_groupTranscoded != null) {
      return _groupTranscoded!.groupeColor;
    }
    return Color.fromARGB(255, 200, 200, 200);
  }

  /// Name to display
  String get groupName {
    if (_groupTranscoded != null) {
      return _groupTranscoded!.name;
    }
    return "-";
  }

  /// Mapping from JSON
  GroupVotesFromJson.fromFrenchNationalAssemblyJson(Map<String, dynamic> json) {
    this.organeRef = json['organeRef'];
    this.nbMembers = int.tryParse(json['nombreMembresGroupe']) ?? 0;

    Map<String, dynamic> _vote = json["vote"];
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

class ScrutinFromJson {
  String? uuid;
  String? organeRef;
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

  /// [ScrutinFromJson] is the vote in the whole assembly
  ScrutinFromJson(
      this.uuid,
      this.organeRef,
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
      this.groupVotesDetails);

  /// calculate the numebr of actual voters
  int get nbVoters {
    return (votedFor ?? 0) + (votedAgainst ?? 0) + (votedAbstention ?? 0);
  }

  /// Mapping from JSON
  ScrutinFromJson.fromFrenchNationalAssemblyJson(Map<String, dynamic> json) {
    this.uuid = json['uid'];
    this.organeRef = json['organeRef'];
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
      _toPass
          .add(GroupVotesFromJson.fromFrenchNationalAssemblyJson(_toConvert));
    }
    this.groupVotesDetails = _toPass;
  }
}

class AmendementFromJson {
  String? uuid;
  String? numeroLong;
  String? texteLegislatifRef;
  String? libelleSignataires;
  String? cycleDeVieSort;
  String? exposeSommaire;

  /// [AmendementFromJson] is the detail of the Amendement to display
  AmendementFromJson(this.uuid, this.numeroLong, this.texteLegislatifRef,
      this.libelleSignataires, this.cycleDeVieSort, this.exposeSommaire);

  /// Mapping from JSON
  AmendementFromJson.fromFrenchNationalAssemblyJson(Map<String, dynamic> json) {
    this.uuid = json['uid'];

    Map<String, dynamic> _identification = json["identification"];
    this.numeroLong = _identification['numeroLong'];

    this.texteLegislatifRef = json['texteLegislatifRef'];

    Map<String, dynamic> _signataires = json["signataires"];
    this.libelleSignataires = _signataires['libelle'];

    Map<String, dynamic> _corps = json["corps"];
    Map<String, dynamic> _contenuAuteur = _corps["contenuAuteur"];
    this.exposeSommaire = _contenuAuteur['exposeSommaire'];

    Map<String, dynamic> _cycleDeVie = json["cycleDeVie"];
    this.cycleDeVieSort = _cycleDeVie['sort'];
  }
}

class ReturnFromJson {
  ScrutinFromJson scrutin;
  AmendementFromJson? amendement;

  ReturnFromJson(this.scrutin, {this.amendement});
}
