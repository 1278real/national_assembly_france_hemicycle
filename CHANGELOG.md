## 0.7.0

* Download the whole JSON files from National Assembly Open Data to process :
```dart
Directory? _appSupportDirectory = await getApplicationSupportDirectory();

getUpdatedDatasFromAssembly(
    destinationDirectory: _appSupportDirectory);
```
In case the URL is changed for any reason, you can specify it...
```dart
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