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

The purpose of this Flutter package depends on hemicycle Flutter package but is specific to French National Assembly.

| ![Image](https://github.com/1278real/national_assembly_france_hemicycle/blob/b94238535524e31f88da39d0e0df173d823395f4/assets/example1_OK.png) | ![Image](https://github.com/1278real/national_assembly_france_hemicycle/blob/b94238535524e31f88da39d0e0df173d823395f4/assets/example2_OK.png) |
| :------------: | :------------: |
| **With surrounding** Group colors | **Without surrounding** Group colors |

## Features

You can give a local or remote Path from your app to the JSON raw from open data, or download the whole JSON package from open data and process it... No need to reformat the JSON from Assemblee National open data website. 

## Usage

Just type ```OpenAssembleeVoteDisplayer().drawVoteHemicycleFromPath``` and submit local or remote JSON as a Path.
```dart
OpenAssembleeVoteDisplayer().drawVoteHemicycleFromPath(localPath:"assets/example_json/VTANR5L15V4417.json");

OpenAssembleeVoteDisplayer().drawVoteHemicycleFromPath(remotePath:"https://www.example.com/assets/example_json/VTANR5L15V4419.json");
```

You can choose to display or not the surrounding Arc of Group colors by submitting ```useGroupSector```. By default, it is set to false.
```dart
OpenAssembleeVoteDisplayer().drawVoteHemicycleFromPath(localPath:"theJson.json");

OpenAssembleeVoteDisplayer().drawVoteHemicycleFromPath(localPath:"theJson.json", useGroupSector: true);

OpenAssembleeVoteDisplayer().drawVoteHemicycleFromPath(localPath:"theJson.json", useGroupSector: false);
```

You can type ```OpenAssembleeVoteDisplayer().drawVoteHemicycleFromAppSupport``` and submit local [ScrutinFromJson].
```dart
Directory? _appSupportDirectory = await getApplicationSupportDirectory();
List<ScrutinFromJson> allVotes = getListOfVotes(mainDirectory: _appSupportDirectory);
for (ScrutinFromJson vote in allVotes)
OpenAssembleeVoteDisplayer().drawVoteHemicycleFromAppSupport(vote: vote);
```

Download the whole JSON files from National Assembly Open Data to process :
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

Then, process from downloaded files :
```dart
List<DossierLegislatifFromJson> _listProcessed = getListOfDossiersLegislatifs(
    mainDirectory: _appSupportDirectory);

List<ProjetLoiFromJson> _listProcessed = getListOfProjetsLois(
    mainDirectory: _appSupportDirectory);

`List<AmendementFromJson> _listProcessed = getListOfAmendements(
    mainDirectory: _appSupportDirectory);

List<ScrutinFromJson> _listProcessed = getListOfVotes(
    mainDirectory: _appSupportDirectory);
```


## NOTA BENE :

Since we are introducing  ```localPath:``` and ```remotePath:```, ```drawVoteHemicycle``` is deprecated and replaced by ```drawVoteHemicycleFromPath```.

```dart
@Deprecated('Use drawVoteHemicycleFromPath instead')
OpenAssembleeVoteDisplayer().drawVoteHemicycle("assets/example_json/VTANR5L15V4417.json");

OpenAssembleeVoteDisplayer().drawVoteHemicycleFromPath(localPath:"assets/example_json/VTANR5L15V4417.json");
```