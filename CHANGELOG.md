## 0.4.6

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