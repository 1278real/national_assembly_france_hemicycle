import 'package:flutter/material.dart';
import 'colors.dart';

class IndividualVotes {
  int index;
  bool? voteResult;
  String? groupPairing;

  /// [voteColor] is the dot color corresponding to [voteResult] boolean :
  Color get voteColor {
    if (voteResult == null) {
      return customVoteAbstention;
    } else {
      if (voteResult == true) {
        return customVoteFor;
      } else {
        return customVoteAgainst;
      }
    }
  }

  /// ### Creates individual dots that react with the group overall color :
  ///
  /// • [index] is the increasing index starting at 0 for the dots from left to right.
  ///
  /// • [voteResult] is TRUE if voted for, FALSE if vote against and NULL if not voted.
  ///
  /// • [groupPairing] is a nullable String used to group dots around a single appearance and compare : see GroupPairing.
  IndividualVotes(this.index, {this.voteResult, this.groupPairing});
}

class GroupPairing {
  String groupPairing;
  int? valueFor;
  int? valueAgainst;
  int? valueAbstention;

  /// ### Used by Individual Votes to make each dot react with the group overall color :
  ///
  /// • [groupPairing] is the String that makes the group pairing work. You can set anything : just be sure that each dot that is supposed to compare with each other have the same String.
  ///
  /// • [valueFor] is the nullable total of vote FOR.
  ///
  /// • [valueAgainst] is the nullable total of vote AGAINST.
  ///
  /// • [valueAbstention] is the nullable total of vote ABSTENTION (no vote).
  GroupPairing(this.groupPairing,
      {this.valueFor, this.valueAgainst, this.valueAbstention});

  /// [groupChoice] is the boolean that describe group choice :
  bool? get groupChoice {
    if ((valueAgainst ?? 0) > (valueFor ?? 0) + (valueAbstention ?? 0)) {
      return false;
    } else if ((valueFor ?? 0) > (valueAgainst ?? 0) + (valueAbstention ?? 0)) {
      return true;
    } else {
      return null;
    }
  }

  /// [groupChoiceColor] is the dot color corresponding to [groupChoice] boolean :
  Color get groupChoiceColor {
    if (groupChoice == null) {
      return customVoteAbstention;
    } else {
      if (groupChoice == true) {
        return customVoteFor;
      } else {
        return customVoteAgainst;
      }
    }
  }
}
