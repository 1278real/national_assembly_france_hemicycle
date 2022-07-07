import 'helpers.dart';

class IndividualVoteFromJson {
  String? acteurRef;
  String? mandatRef;
  bool? parDelegation;
  bool? votedFor;
  bool? votedAgainst;
  bool? didNotVote;
  bool? votedAbstention;

  IndividualVoteFromJson(this.acteurRef, this.mandatRef, this.parDelegation,
      this.votedFor, this.votedAgainst, this.didNotVote, this.votedAbstention);

  bool get didNotAttend {
    return (!(votedFor ?? false) &&
        !(votedAgainst ?? false) &&
        !(votedAbstention ?? false) &&
        !(didNotVote ?? false));
  }

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
      votedAgainst = true;
    } else {
      votedAgainst = false;
    }
    if (voteReceived == "nonVotants") {
      didNotVote = true;
    } else {
      didNotVote = false;
    }
  }
}

class GroupVotesFromJson {
  String? organeRef;
  int? nbMembers;
  int? votedFor;
  int? votedAgainst;
  int? votedAbstention;
  int? didNotVote;
  List<IndividualVoteFromJson>? votesDetails;

  GroupVotesFromJson(
      this.organeRef,
      this.nbMembers,
      this.votedFor,
      this.votedAgainst,
      this.votedAbstention,
      this.didNotVote,
      this.votesDetails);

  int get didNotAttend {
    return (nbMembers ?? 0) -
        (votedFor ?? 0) -
        (votedAgainst ?? 0) -
        (votedAbstention ?? 0) -
        (didNotVote ?? 0);
  }

  GroupVotesFromJson.fromFrenchNationalAssemblyJson(Map<String, dynamic> json) {
    this.organeRef = json['organeRef'];
    this.nbMembers = int.tryParse(json['nombreMembresGroupe']) ?? 0;
    this.votedFor = int.tryParse(json['vote']['decompteVoix']['pour']) ?? 0;
    this.votedAgainst =
        int.tryParse(json['vote']['decompteVoix']['contre']) ?? 0;
    this.votedAbstention =
        int.tryParse(json['vote']['decompteVoix']['abstentions']) ?? 0;
    this.didNotVote =
        int.tryParse(json['vote']['decompteVoix']['nonVotants']) ?? 0;
    List<dynamic> _roughJson = json['vote']['decompteNominatif'];
    List<IndividualVoteFromJson> _toPass = [];
    for (var i = 0; i < _roughJson.length; i++) {
      print("##### > " + _roughJson[i].toString());
      /*
      if (_roughJson[i].length > 0) {
        for (var j = 0; j < _roughJson[i].length; j++) {
          _toPass.add(individualVoteFromJson
              .fromFrenchNationalAssemblyJson(_roughJson[i][j]));
        }
      }
*/
    }
    this.votesDetails = _toPass;
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
  List<GroupVotesFromJson>? votesDetails;

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
      this.votesDetails);

  int get nbVoters {
    return (votedFor ?? 0) + (votedAgainst ?? 0) + (votedAbstention ?? 0);
  }

  ScrutinFromJson.fromFrenchNationalAssemblyJson(Map<String, dynamic> json) {
    this.uuid = json['scrutin']['uid'];
    this.organeRef = json['scrutin']['organeRef'];
    this.dateScrutin = dateFormatter(json['scrutin']['dateScrutin'],
        dateSeparator: "-", format: "YMD", noHour: true);
    this.codeVote = json['scrutin']['typeVote']['codeTypeVote'];
    this.libelleVote = json['scrutin']['typeVote']['libelleTypeVote'];
    this.majoriteVote = json['scrutin']['typeVote']['typeMajorite'];
    this.resultatVote = json['scrutin']['sort']['code'];
    this.titre = json['scrutin']['titre'];
    this.demandeur = json['scrutin']['demandeur']['texte'];
    this.votedFor =
        int.tryParse(json['scrutin']['syntheseVote']['decompte']['pour']) ?? 0;
    this.votedAgainst =
        int.tryParse(json['scrutin']['syntheseVote']['decompte']['contre']) ??
            0;
    this.votedAbstention = int.tryParse(
            json['scrutin']['syntheseVote']['decompte']['abstentions']) ??
        0;
    this.didNotVote = int.tryParse(
            json['scrutin']['syntheseVote']['decompte']['nonVotants']) ??
        0;
    List<dynamic> _roughJson =
        json['scrutin']['ventilationVotes']['organe']['groupes']['groupe'];
    List<GroupVotesFromJson> _toPass = [];
    for (var i = 0; i < _roughJson.length; i++) {
      _toPass.add(
          GroupVotesFromJson.fromFrenchNationalAssemblyJson(_roughJson[i]));
    }
    this.votesDetails = _toPass;
  }
}
