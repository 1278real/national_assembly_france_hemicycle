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
  List<IndividualVoteFromJson>? individualVotesDetails;

  GroupVotesFromJson(
      this.organeRef,
      this.nbMembers,
      this.votedFor,
      this.votedAgainst,
      this.votedAbstention,
      this.didNotVote,
      this.individualVotesDetails);

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

    Map<String, dynamic> _vote = json["vote"];
    Map<String, dynamic> _decompteVoix = _vote["decompteVoix"];

    this.votedFor = int.tryParse(_decompteVoix['pour']) ?? 0;
    this.votedAgainst = int.tryParse(_decompteVoix['contre']) ?? 0;
    this.votedAbstention = int.tryParse(_decompteVoix['abstentions']) ?? 0;
    this.didNotVote = int.tryParse(_decompteVoix['nonVotants']) ?? 0;

    List<IndividualVoteFromJson> _toPass = [];

    Map<String, dynamic> _decompteNominatif = _vote["decompteNominatif"];
    if (_decompteNominatif['pours'] != null) {
      print("----- POURS not null");
      Map<String, dynamic> _pours = _decompteNominatif['pours'];
/*
      List<dynamic> _votants = _pours['votants'];
      for (var i = 0; i < _votants.length; i++) {
        Map<String, dynamic> _votant = _votants[i];

        _toPass.add(IndividualVoteFromJson.fromFrenchNationalAssemblyJson(
            _votant, "pours"));
      }
*/
    }
    if (_decompteNominatif['contres'] != null) {
      print("----- CONTRES not null");
    }
    if (_decompteNominatif['abstentions'] != null) {
      print("----- ABSTENTION not null");
    }
    if (_decompteNominatif['nonVotants'] != null) {
      print("----- NV not null");
    }

    this.individualVotesDetails = _toPass;
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

  int get nbVoters {
    return (votedFor ?? 0) + (votedAgainst ?? 0) + (votedAbstention ?? 0);
  }

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
