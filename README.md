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

You can give a local Path from your app to the JSON raw from open data (soon : URL to online JSON)... No need to reformat the JSON from Assemblee National open data website. 

## Usage

Just type ```OpenAssembleeVoteDisplayer().drawVoteHemicycle``` and submit local or remote JSON as a Path.
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


## NOTA BENE :

Since we are introducing  ```localPath:``` and ```remotePath:```, ```drawVoteHemicycle``` is deprecated and replaced by ```drawVoteHemicycleFromPath```.

```dart
@Deprecated('Use drawVoteHemicycleFromPath instead')
OpenAssembleeVoteDisplayer().drawVoteHemicycle("assets/example_json/VTANR5L15V4417.json");

OpenAssembleeVoteDisplayer().drawVoteHemicycleFromPath(localPath:"assets/example_json/VTANR5L15V4417.json");
```

## Additional information

Further infos soon ;-)