import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers.dart';

Future<bool> checkPrefs() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  bool shouldUpdate = false;
  String _lastFetched = (prefs.getString('NAF_lastFetched') ?? "");

  if (_lastFetched != "") {
    DateTime _lastFetchedTime = dateFormatter(_lastFetched);
    if (_lastFetchedTime
        .isBefore(DateTime.now().subtract(Duration(hours: 6)))) {
      shouldUpdate = true;
    } else if (_lastFetchedTime.day < DateTime.now().day ||
        (_lastFetchedTime.day == DateTime.now().day &&
            _lastFetchedTime.hour < 6)) {
      shouldUpdate = true;
    } else {
      print("No need to update");
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
Future<bool> getUpdatedDatasFromAssembly(
    {String pathToDossiers =
        "https://data.assemblee-nationale.fr/static/openData/repository/16/loi/dossiers_legislatifs/Dossiers_Legislatifs.json.zip",
    String pathToVotes =
        "https://data.assemblee-nationale.fr/static/openData/repository/16/loi/scrutins/Scrutins.json.zip",
    String pathToAmendements =
        "https://data.assemblee-nationale.fr/static/openData/repository/16/loi/amendements_div_legis/Amendements.json.zip",
    required Directory destinationDirectory}) async {
  bool needsUpdate = await checkPrefs();
  if (needsUpdate) {
    print("Update !");
    if (destinationDirectory != null) {
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
          dossiersFilePath = destinationDirectory.path + "/dossiers.zip";
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
          dossiersFilePath, destinationDirectory.path + "/docs_legis");

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
          votesFilePath = destinationDirectory.path + "/votes.zip";
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
      /// extract ZIP "Dossiers Législatifs" to App Support Directory
      ///
      ///

      await extractFileToDisk(
          votesFilePath, destinationDirectory.path + "/votes");

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
          amendementsFilePath = destinationDirectory.path + "/amendements.zip";
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
      /// extract ZIP "Dossiers Législatifs" to App Support Directory
      ///
      ///

      await extractFileToDisk(
          amendementsFilePath, destinationDirectory.path + "/amendements");

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
          print(file.path);
        }
      }
      print("FILES ADDED = " + numberOfFilesAdded.toString());

      ///
      ///
      /// return TRUE for success
      ///
      ///

      updatePrefs();

      return true;
    }
  }

  return false;
}
