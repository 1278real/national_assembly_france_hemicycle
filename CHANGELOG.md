## 0.9.1

* Update on JSON parsing when AN open data has errors :-/
For instance, number of voters ≠ number of votes described.

## 0.9.0

* Tapping on the "Adopted"/"Rejected" container displays the name of the voters that didn't follow their group's majority vote..

* Possibility to force refresh of the AN Open data before 3-hour delay is elapsed.
* 6-hour to 3-hour delay before AN Open data is refreshed.

## 0.8.1

* Graphic enhancements for Individual Votes : second arc for SuperGroup.

## 0.7.2

* Changed sort order for Amendments : ```(Rect)``` (rectified amendments) is no longer an issue when sorting.

## 0.7.1

* Updated example.dart

* Changed sort order for Amendments : Assembly first, then Commissions

## 0.7.0

* Download the whole JSON files from National Assembly Open Data to process :
```dart
Directory? _appSupportDirectory = await getApplicationSupportDirectory();

getUpdatedDatasFromAssembly(
    destinationDirectory: _appSupportDirectory);
```
In case the URL is changed for any reason, you can specify it...
```dart

Directory? _appSupportDirectory = await getApplicationSupportDirectory();

getUpdatedDatasFromAssembly(
    pathToDossiers:
        "https://data.assemblee-nationale.fr/static/openData/repository/16/loi/dossiers_legislatifs/Dossiers_Legislatifs.json.zip",
    pathToVotes:
        "https://data.assemblee-nationale.fr/static/openData/repository/16/loi/scrutins/Scrutins.json.zip",
    pathToAmendements:
        "https://data.assemblee-nationale.fr/static/openData/repository/16/loi/amendements_div_legis/Amendements.json.zip",
    destinationDirectory: _appSupportDirectory);
```

* Process ```DossierLegislatifFromJson``` from downloaded files :
```dart
Directory? _appSupportDirectory = await getApplicationSupportDirectory();

List<DossierLegislatifFromJson> _listProcessed = getListOfDossiersLegislatifs(
    mainDirectory: _appSupportDirectory);
```

* Process ```ProjetLoiFromJson``` from downloaded files :
```dart
Directory? _appSupportDirectory = await getApplicationSupportDirectory();

List<ProjetLoiFromJson> _listProcessed = getListOfProjetsLois(
    mainDirectory: _appSupportDirectory);
```

* Process ```AmendementFromJson``` from downloaded files :
```dart
Directory? _appSupportDirectory = await getApplicationSupportDirectory();

List<AmendementFromJson> _listProcessed = getListOfAmendements(
    mainDirectory: _appSupportDirectory);
```

* Process ```ScrutinFromJson``` from downloaded files :
```dart
Directory? _appSupportDirectory = await getApplicationSupportDirectory();

List<ScrutinFromJson> _listProcessed = getListOfVotes(
    mainDirectory: _appSupportDirectory);
```

* Ability to display an Hemicycle directly from ```ScrutinFromJson``` :
```dart
Directory? _appSupportDirectory = await getApplicationSupportDirectory();
List<ScrutinFromJson> allVotes = getListOfVotes(mainDirectory: _appSupportDirectory);
for (ScrutinFromJson vote in allVotes)
OpenAssembleeVoteDisplayer().drawVoteHemicycleFromAppSupport(vote: vote);
```


## 0.6.0

* Ability to display a user-selected String as a Title
* Choice between divider before of after : ```withDivider``` needs to be replaced by ```withDividerBefore```. You can also use ```withDividerAfter``` now.
```dart
OpenAssembleeVoteDisplayer().drawVoteHemicycleFromPath(
    remotePath: "your/remote/path/to/file.json",
    initialComment: "Title to display",
    withDividerBefore: false,
    withDividerAfter: true,
);
```

## 0.5.3

* Updating informations and comments for pub.dev scoring...
* Correction on discordant voters appearance
* Correction in dependency link with Hemicycle package

## 0.5.0

* Enable the highlighting for discordant voters in a Group in Individual Votes mode
(i.e. for Vote-For-only votes, the non-voters in a group are interesting to highlight)

## 0.4.8

* Graphic enhancements for Individual Votes and surrounding arc

## 0.4.2

* Implementation of remote files : ```drawVoteHemicycle``` is deprecated and replaced by ```drawVoteHemicycleFromPath```.
```dart
@Deprecated('Use drawVoteHemicycleFromPath instead')
OpenAssembleeVoteDisplayer().drawVoteHemicycle("assets/example_json/VTANR5L15V4417.json");

OpenAssembleeVoteDisplayer().drawVoteHemicycleFromPath(localPath:"assets/example_json/VTANR5L15V4417.json");
OpenAssembleeVoteDisplayer().drawVoteHemicycleFromPath(remotePath:"https://www.example.com/assets/example_json/VTANR5L15V4417.json");
```

## 0.3.7

* Changed the waiting pattern during building.
* Updated the surrounding color arc display.

## 0.3.4

* Changes to publish for score optimization.

## 0.3.1

* First commits...