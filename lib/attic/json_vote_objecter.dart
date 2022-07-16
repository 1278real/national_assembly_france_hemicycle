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
  String? numero;
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
      this.numero,
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
  ScrutinFromJson.fromFrenchNationalAssemblyJson(Map<String, dynamic> _map) {
    Map<String, dynamic> json = _map["scrutin"];

    this.uuid = json['uid'];
    this.organeRef = json['organeRef'];
    this.numero = json['numero'];
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

  /// [AmendementFromJson] is the detail of the Amendment to display
  AmendementFromJson(this.uuid, this.numeroLong, this.texteLegislatifRef,
      this.libelleSignataires, this.cycleDeVieSort, this.exposeSommaire);

  /// Mapping from JSON
  AmendementFromJson.fromFrenchNationalAssemblyJson(Map<String, dynamic> _map) {
    Map<String, dynamic> json = _map["amendement"];

    this.uuid = json['uid'];

    Map<String, dynamic> _identification = json["identification"];
    this.numeroLong = _identification['numeroLong'];

    this.texteLegislatifRef = json['texteLegislatifRef'];

    Map<String, dynamic> _signataires = json["signataires"];
    this.libelleSignataires = _signataires['libelle'];

    Map<String, dynamic> _corps = json["corps"];
    Map<String, dynamic> _contenuAuteur = _corps["contenuAuteur"];
    if (_contenuAuteur['exposeSommaire'] != null) {
      this.exposeSommaire = _contenuAuteur['exposeSommaire'];
    } else {
      this.exposeSommaire = "-";
    }

    Map<String, dynamic> _cycleDeVie = json["cycleDeVie"];
    if (_cycleDeVie['sort'].toString().substring(0, 1) == "{") {
      this.cycleDeVieSort = "";
    } else if (_cycleDeVie['sort'].toString().substring(0, 1) == "\"") {
      this.cycleDeVieSort = _cycleDeVie['sort'];
    }
  }
}

class DossierLegislatifFromJson {
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

  List<String>? get votesRef {
    List<String> _tempVotes = [];
    if (this.actesLegislatifs != null) {
      for (ActeLegislatifFromJson acte in this.actesLegislatifs!) {
        if (acte.votesRef != null && acte.votesRef != []) {
          for (String vote in acte.votesRef!) {
            _tempVotes.add(vote);
          }
        }
        if (acte.actesIntra != null && acte.actesIntra != []) {
          for (ActeLegislatifFromJson subActe
              in acte.actesIntra as List<ActeLegislatifFromJson>) {
            if (subActe.votesRef != null && subActe.votesRef != []) {
              for (String vote in subActe.votesRef!) {
                _tempVotes.add(vote);
              }
            }
            if (subActe.actesIntra != null && subActe.actesIntra != []) {
              for (ActeLegislatifFromJson subSubActe
                  in subActe.actesIntra as List<ActeLegislatifFromJson>) {
                if (subSubActe.votesRef != null && subSubActe.votesRef != []) {
                  for (String vote in subSubActe.votesRef!) {
                    _tempVotes.add(vote);
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
}

class ProjetLoiFromJson {
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
    this.dateDepot = dateFormatter(
        _chrono["dateDepot"].toString().substring(0, 10),
        dateSeparator: "-",
        format: "YMD");
  }

  String get uuidTranslate {
    ///
    /// from :
    ///   PRJLANR5L16BTC0144 / PRJLSNR5S359B0561
    /// to :
    ///   Proj. Loi Ass. Nat. Ve Répub. Légis. 16 Adopté Commission au fond 0144
    ///   Proj. Loi Sénat Ve Répub. Sess. 359 Non adopté 0561
    ///

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
}

class ActeLegislatifFromJson {
  String? uuid;
  String? libelleActeLegislatif;
  List<String>? votesRef;
  dynamic actesIntra;

  ActeLegislatifFromJson(
      this.uuid, this.libelleActeLegislatif, this.actesIntra);

  /// Mapping from JSON
  ActeLegislatifFromJson.fromFrenchNationalAssemblyJson(
      Map<String, dynamic> _acteLegislatif) {
    this.uuid = _acteLegislatif["uid"];

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
    if (_tempVotes.length > 0) {
      print((this.uuid ?? "---") + " >> " + _tempVotes.toString());
    }
    this.votesRef = _tempVotes;
  }
}

class ReturnFromJson {
  ScrutinFromJson scrutin;
  AmendementFromJson? amendement;

  ReturnFromJson(this.scrutin, {this.amendement});
}
