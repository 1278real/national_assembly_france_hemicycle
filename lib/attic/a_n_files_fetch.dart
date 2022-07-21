import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:national_assembly_france_hemicycle/attic/json_vote_objecter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers.dart';
import 'files_and_folders.dart';

int timingInHoursBeforeRefresh = 3;

Future<bool> checkPrefs() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  bool shouldUpdate = false;
  String _lastFetched = (prefs.getString('NAF_lastFetched') ?? "");

  if (_lastFetched != "") {
    DateTime _lastFetchedTime = dateFormatter(_lastFetched);
    if (_lastFetchedTime.isBefore(
        DateTime.now().subtract(Duration(hours: timingInHoursBeforeRefresh)))) {
      shouldUpdate = true;
    } else if (_lastFetchedTime.day < DateTime.now().day ||
        (_lastFetchedTime.day == DateTime.now().day &&
            _lastFetchedTime.hour < 6)) {
      shouldUpdate = true;
    } else {
      print("No need to update A.N. OPEN DATA");
    }
  } else {
    shouldUpdate = true;
  }

  return shouldUpdate;
}

void updatePrefs() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  prefs
      .setString('NAF_lastFetched', dateStringFormatter(DateTime.now()))
      .then((bool success) {
    return true;
  });
}

/// ### *Download the ZIP archives* from National Assembly open data and *extract* in designated directory :
///
/// • [pathToDossiers] is the path to AN Legislative Files. If not provided, uses the default Path.
///
/// • [pathToVotes] is the path to AN Votes. If not provided, uses the default Path.
///
/// • [pathToAmendements] is the path to AN Amendments. If not provided, uses the default Path.
///
/// • [destinationDirectory] is the required Directory to download and extract files. You can use App Support directory for instance.
///
/// • cforceRefresh] is a boolean to force the refresh of Open Data files before the [timingInHoursBeforeRefresh] is elapsed.
Future<bool> getUpdatedDatasFromAssembly(
    {String pathToDossiers =
        "https://data.assemblee-nationale.fr/static/openData/repository/16/loi/dossiers_legislatifs/Dossiers_Legislatifs.json.zip",
    String pathToVotes =
        "https://data.assemblee-nationale.fr/static/openData/repository/16/loi/scrutins/Scrutins.json.zip",
    String pathToAmendements =
        "https://data.assemblee-nationale.fr/static/openData/repository/16/loi/amendements_div_legis/Amendements.json.zip",
    required Directory destinationDirectory,
    bool forceRefresh = false}) async {
  bool needsUpdate = await checkPrefs();

  if (needsUpdate || forceRefresh) {
    print("Updating A.N. OPEN DATA !");

    HttpClient httpClient = new HttpClient();

    ///
    ///
    /// delete existing Files and Links in App Support Directory
    ///
    ///

    List<FileSystemEntity> initialListOfFiles =
        await destinationDirectory.list(recursive: true).toList();

    int numberOfFilesDeleted = 0;
    for (FileSystemEntity file in initialListOfFiles) {
      numberOfFilesDeleted += 1;
      if (file is File) {
        file.delete();
        // print("FILES DELETED = " + numberOfFilesDeleted.toString());
      }
    }
    for (FileSystemEntity file in initialListOfFiles) {
      numberOfFilesDeleted += 1;
      if (file is Link) {
        file.delete();
        // print("LINKS DELETED = " + numberOfFilesDeleted.toString());
      }
    }
    print("FILE ENTITIES DELETED = " + numberOfFilesDeleted.toString());

    ///
    ///
    /// download ZIP "Dossiers Législatifs" from open data AN
    ///
    ///

    File dossiersFile;
    String dossiersFilePath = '';

    try {
      var request = await httpClient.getUrl(Uri.parse(pathToDossiers));
      var response = await request.close();
      if (response.statusCode == 200) {
        var bytes = await consolidateHttpClientResponseBytes(response);
        dossiersFilePath =
            destinationDirectory.path + dossierParlementaireZipFile;
        dossiersFile = File(dossiersFilePath);
        await dossiersFile.writeAsBytes(bytes);
      } else {
        dossiersFilePath = 'Error code: ' + response.statusCode.toString();
      }
    } catch (ex) {
      dossiersFilePath = 'Can not fetch url';
    }

    ///
    ///
    /// extract ZIP "Dossiers Législatifs" to App Support Directory
    ///
    ///

    await extractFileToDisk(
        dossiersFilePath, destinationDirectory.path + docsLegisDirectory);

    initialListOfFiles =
        await destinationDirectory.list(recursive: true).toList();
    for (FileSystemEntity file in initialListOfFiles) {
      if (file.path == dossiersFilePath) {
        file.delete();
        // print("FILES DELETED = " + numberOfFilesDeleted.toString());
      }
    }

    ///
    ///
    /// download ZIP "Votes" from open data AN
    ///
    ///

    File votesFile;
    String votesFilePath = '';

    try {
      var request = await httpClient.getUrl(Uri.parse(pathToVotes));
      var response = await request.close();
      if (response.statusCode == 200) {
        var bytes = await consolidateHttpClientResponseBytes(response);
        votesFilePath = destinationDirectory.path + votesZipFile;
        votesFile = File(votesFilePath);
        await votesFile.writeAsBytes(bytes);
      } else {
        votesFilePath = 'Error code: ' + response.statusCode.toString();
      }
    } catch (ex) {
      votesFilePath = 'Can not fetch url';
    }

    ///
    ///
    /// extract ZIP "Votes" to App Support Directory
    ///
    ///

    await extractFileToDisk(
        votesFilePath, destinationDirectory.path + votesDirectory);

    initialListOfFiles =
        await destinationDirectory.list(recursive: true).toList();
    for (FileSystemEntity file in initialListOfFiles) {
      if (file.path == votesFilePath) {
        file.delete();
        // print("FILES DELETED = " + numberOfFilesDeleted.toString());
      }
    }

    ///
    ///
    /// download ZIP "Amendements" from open data AN
    ///
    ///

    File amendementsFile;
    String amendementsFilePath = '';

    try {
      var request = await httpClient.getUrl(Uri.parse(pathToAmendements));
      var response = await request.close();
      if (response.statusCode == 200) {
        var bytes = await consolidateHttpClientResponseBytes(response);
        amendementsFilePath = destinationDirectory.path + amendementsZipFile;
        amendementsFile = File(amendementsFilePath);
        await amendementsFile.writeAsBytes(bytes);
      } else {
        amendementsFilePath = 'Error code: ' + response.statusCode.toString();
      }
    } catch (ex) {
      amendementsFilePath = 'Can not fetch url';
    }

    ///
    ///
    /// extract ZIP "Amendements" to App Support Directory
    ///
    ///

    await extractFileToDisk(
        amendementsFilePath, destinationDirectory.path + amendementsDirectory);

    initialListOfFiles =
        await destinationDirectory.list(recursive: true).toList();
    for (FileSystemEntity file in initialListOfFiles) {
      if (file.path == amendementsFilePath) {
        file.delete();
        // print("FILES DELETED = " + numberOfFilesDeleted.toString());
      }
    }

    ///
    ///
    /// list directories and count files in App Support Directory
    ///
    ///

    List<FileSystemEntity> listOfFiles =
        await destinationDirectory.list(recursive: true).toList();

    int numberOfFilesAdded = 0;
    for (FileSystemEntity file in listOfFiles) {
      numberOfFilesAdded += 1;
      if (file is Directory) {
        // print(file.path);
      }
    }
    print("FILES ADDED = " + numberOfFilesAdded.toString());

    ///
    ///
    /// return TRUE for success
    ///
    ///

    if (numberOfFilesAdded > 0) {
      updatePrefs();

      return true;
    }
  } else {
    return true;
  }

  return false;
}

/// ### *Get the Dossiers Legislatifs JSON files* in designated directory and *convert* to [DossierLegislatifFromJson]:
///
/// • [mainDirectory] is the required Directory where Open Data ZIP was extracted. You can use App Support directory for instance.
Future<List<DossierLegislatifFromJson>> getListOfDossiersLegislatifs(
    {required Directory mainDirectory}) async {
  List<DossierLegislatifFromJson> _listToReturn = [];
  Directory theDirectory = Directory(mainDirectory.path +
      docsLegisDirectory +
      jsonIntermediaryDirectory +
      dossierParlementaireDirectory);
  List<FileSystemEntity> _initialListOfFiles =
      await theDirectory.list(recursive: true).toList();
  for (FileSystemEntity file in _initialListOfFiles) {
    if (file.path.split("/").last.substring(0, 1) != ".") {
      // to exclude any system file
      File _theFile = File(file.path);
      dynamic response = await _theFile.readAsString();

      if (response != null) {
        Map<String, dynamic> _map = json.decode(response);
        DossierLegislatifFromJson _toReturn =
            DossierLegislatifFromJson.fromFrenchNationalAssemblyJson(_map);
        _listToReturn.add(_toReturn);
      }
    }
  }
  return _listToReturn;
}

/// ### *Get the Amendements JSON files* in designated directory and *convert* to [AmendementFromJson]:
///
/// • [mainDirectory] is the required Directory where Open Data ZIP was extracted. You can use App Support directory for instance.
Future<List<AmendementFromJson>> getListOfAmendements(
    {required Directory mainDirectory}) async {
  List<AmendementFromJson> _listToReturn = [];
  Directory theDirectory = Directory(
      mainDirectory.path + amendementsDirectory + jsonIntermediaryDirectory);
  List<FileSystemEntity> _initialListOfFiles =
      await theDirectory.list(recursive: true).toList();

  for (FileSystemEntity entityLevelOne in _initialListOfFiles) {
    if (entityLevelOne.path.split("/").last.substring(0, 1) != ".") {
      // to exclude any system file

      ///
      ///
      /// LIST OF DOSSIERS LEGISLATIFS
      ///
      ///

      if (entityLevelOne is Directory) {
        List<FileSystemEntity> _listOfDossiers =
            await entityLevelOne.list(recursive: true).toList();

        for (FileSystemEntity entityLevelTwo in _listOfDossiers) {
          if (entityLevelTwo.path.split("/").last.substring(0, 1) != ".") {
            // to exclude any system file

            ///
            ///
            /// LIST OF PROJETS LOIS
            ///
            ///

            if (entityLevelTwo is Directory) {
              List<FileSystemEntity> _listOfProjets =
                  await entityLevelTwo.list(recursive: true).toList();

              for (FileSystemEntity entityLevelThree in _listOfProjets) {
                if (entityLevelThree.path.split("/").last.substring(0, 1) !=
                    ".") {
                  // to exclude any system file

                  ///
                  ///
                  /// LIST OF AMENDEMENTS
                  ///
                  ///

                  File _theFile = File(entityLevelThree.path);
                  dynamic response = await _theFile.readAsString();

                  if (response != null) {
                    Map<String, dynamic> _map = json.decode(response);
                    AmendementFromJson _toReturn =
                        AmendementFromJson.fromFrenchNationalAssemblyJson(_map);
                    _listToReturn.add(_toReturn);
                  }
                }
              }
            }
          }
        }
      }
    }
  }
  return _listToReturn;
}

/// ### *Get the Projets Lois JSON files* in designated directory and *convert* to [ProjetLoiFromJson]:
///
/// • [mainDirectory] is the required Directory where Open Data ZIP was extracted. You can use App Support directory for instance.
Future<List<ProjetLoiFromJson>> getListOfProjetsLois(
    {required Directory mainDirectory}) async {
  List<ProjetLoiFromJson> _listToReturn = [];
  Directory theDirectory = Directory(mainDirectory.path +
      docsLegisDirectory +
      jsonIntermediaryDirectory +
      documentDirectory);
  List<FileSystemEntity> _initialListOfFiles =
      await theDirectory.list(recursive: true).toList();
  for (FileSystemEntity file in _initialListOfFiles) {
    if (file.path.split("/").last.substring(0, 1) != ".") {
      // to exclude any system file
      if (file.path.split("/").last.substring(0, 4) == "PRJL") {
        File _theFile = File(file.path);
        dynamic response = await _theFile.readAsString();

        if (response != null) {
          Map<String, dynamic> _map = json.decode(response);
          ProjetLoiFromJson _toReturn =
              ProjetLoiFromJson.fromFrenchNationalAssemblyJson(_map);
          _listToReturn.add(_toReturn);
        }
      }
    }
  }
  return _listToReturn;
}

/// ### *Get the Scrutin JSON files* in designated directory and *convert* to [ScrutinFromJson]:
///
/// • [mainDirectory] is the required Directory where Open Data ZIP was extracted. You can use App Support directory for instance.
Future<List<ScrutinFromJson>> getListOfVotes(
    {required Directory mainDirectory}) async {
  List<ScrutinFromJson> _listToReturn = [];
  Directory theDirectory = Directory(
      mainDirectory.path + votesDirectory + jsonIntermediaryDirectory);
  List<FileSystemEntity> _initialListOfFiles =
      await theDirectory.list(recursive: true).toList();
  for (FileSystemEntity file in _initialListOfFiles) {
    if (file.path.split("/").last.substring(0, 1) != ".") {
      // to exclude any system file

      File _theFile = File(file.path);
      dynamic response = await _theFile.readAsString();

      if (response != null) {
        Map<String, dynamic> _map = json.decode(response);
        ScrutinFromJson _toReturn =
            ScrutinFromJson.fromFrenchNationalAssemblyJson(_map);
        _listToReturn.add(_toReturn);
      }
    }
  }
  return _listToReturn;
}

/// Used if needed or forced from [getListOfDeputes] :
Future<bool> _updateListOfDeputes(
    {required String pathToDeputes,
    required Directory destinationDirectory}) async {
  HttpClient httpClient = new HttpClient();

  File dossiersFile;
  String dossiersFilePath = '';

  try {
    var request = await httpClient.getUrl(Uri.parse(pathToDeputes));
    var response = await request.close();
    if (response.statusCode == 200) {
      var bytes = await consolidateHttpClientResponseBytes(response);
      dossiersFilePath = destinationDirectory.path + deputesCsvFile;
      dossiersFile = File(dossiersFilePath);
      await dossiersFile.writeAsBytes(bytes);
      return true;
    } else {
      dossiersFilePath = 'Error code: ' + response.statusCode.toString();
    }
  } catch (ex) {
    dossiersFilePath = 'Can not fetch url';
  }
  return false;
}

/// ### If needed, *download the CSV Excel-format* from National Assembly open data. In any case, *convert* downloaded data :
///
/// • [pathToDeputes] is the path to AN Deputees. If not provided, uses the default Path.
///
/// • [mainDirectory] is the required Directory to download and extract files. You can use App Support directory for instance.
///
/// • [forceRefresh] is a boolean to force the refresh of Open Data files.
Future<List<DeputesFromCsv>> getListOfDeputes(
    {String pathToDeputes =
        "https://data.assemblee-nationale.fr/static/openData/repository/16/amo/deputes_actifs_csv_opendata/liste_deputes_excel.csv",
    required Directory mainDirectory,
    bool forceRefresh = false}) async {
  List<List<dynamic>> _listData = [];
  HttpClient httpClient = new HttpClient();

  String dossiersFilePath = mainDirectory.path + deputesCsvFile;

  if (!File(dossiersFilePath).existsSync() || forceRefresh) {
    await _updateListOfDeputes(
        pathToDeputes: pathToDeputes, destinationDirectory: mainDirectory);
  }

  File? dossiersFile = File(dossiersFilePath);

  String dossiersString = await dossiersFile.readAsString(encoding: latin1);
  _listData = CsvToListConverter()
      .convert(dossiersString, fieldDelimiter: ";", eol: "\n");

  List<DeputesFromCsv> _tempDeputes = [];
  for (var i = 1; i < _listData.length; i++) {
    DeputesFromCsv _tempTranscode =
        DeputesFromCsv.fromFrenchNationalAssemblyCsv(_listData[i]);
    _tempDeputes.add(_tempTranscode);
  }

  return _tempDeputes;
}
