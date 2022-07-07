<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages). 
-->

The purpose of this Flutter package is to draw a full-width (embed in Container to resize) representation of a semi-circle assembly...
The number of dots is up to you, by default 577 as for the French National Assembly.

| ![Image](https://github.com/1278real/hemicycle/blob/d23811596e9ee36c5a728390da145ac60a14273c/assets/groupes.png) | ![Image](https://github.com/1278real/hemicycle/blob/177de3d0ba7e0a8d5e76e0ec73f112b5ab44ee9c/assets/legislatives.png) |
| :------------: | :------------: |
| **DrawHemicycle** groupes parlementaires France 2022 | **DrawHemicycle** législatives France 2022 |

## Features

You can change the number of seats, the arc of the circle (by default, 170°) and, with the specific type of inputs, you can display individual voters or sectors for group appearance...

## Usage

Create a ```List<GroupSectors>``` containing every sectors you want to draw.

```dart
    List<GroupSectors> hemicycleTest = [
      GroupSectors(30, customVoteFor, description: "BEFORE"),
      GroupSectors(50, customVoteAgainst, description: "NEW"),
      GroupSectors(497, customVoteAbstention, description: "AFTER")
    ];
    
    DrawHemicycle(
        30 + 50 + 497,
        nbRows: ((30 + 50 + 497) / 50).ceil(),
        groupSectors: hemicycleTest,
        withLegend: true,
        withTitle: true,
        title: "TEST",
    );
```

OR

Create a ```List<IndividualVotes>``` containing every individual vote you want to draw.

```dart
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

    DrawHemicycle(200,
        nbRows: 8, individualVotes: votesTest, withLegend: true);
```

Then use ```DrawHemicycle``` to get the semi-circle assembly representation. 


| ![Image](https://github.com/1278real/hemicycle/blob/55196e4a7ade0f60c25dbbf5b3a8e7e5179374d9/assets/test_groups.png) | ![Image](https://github.com/1278real/hemicycle/blob/55196e4a7ade0f60c25dbbf5b3a8e7e5179374d9/assets/test_votes.png) |
| :------------: | :------------: |
| **Example** group sectors | **Example** individual votes |

## Additional information

Further infos soon ;-)