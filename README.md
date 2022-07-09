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

| ![Image](https://github.com/1278real/national_assembly_france_hemicycle/blob/64b159c0497ed8fd06bf7a3df593def27eae7b11/assets/example1b.png) | ![Image](https://github.com/1278real/national_assembly_france_hemicycle/blob/64b159c0497ed8fd06bf7a3df593def27eae7b11/assets/example2b.png) |
| :------------: | :------------: |
| **With surrounding** Group colors | **Without surrounding** Group colors |

## Features

You can give a local Path from your app to the JSON raw from open data (soon : URL to online JSON)... No need to reformat the JSON from Assemblee National open data website. 

## Usage

Just type ```OpenAssembleeVoteDisplayer().drawVoteHemicycle``` and submit local or remote JSON as a Path.

```dart
    OpenAssembleeVoteDisplayer().drawVoteHemicycle(localPath:
        "assets/example_json/VTANR5L15V4417.json"),

    OpenAssembleeVoteDisplayer().drawVoteHemicycle(localPath:
        "assets/example_json/VTANR5L15V4418.json",
        useGroupSector: true),

    OpenAssembleeVoteDisplayer().drawVoteHemicycle(remotePath:
        "https://www.example.com/assets/example_json/VTANR5L15V4419.json",
        useGroupSector: false),
```

You can choose to display or not the surrounding Arc of Group colors by submitting ```useGroupSector```. By default, it is set to false.

## Additional information

Further infos soon ;-)