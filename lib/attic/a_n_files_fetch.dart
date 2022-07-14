import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

Future<bool> getUpdatedDatasFromAssembly(
    {required String pathToDossiers,
    required String pathToVotes,
    required String pathToAmendements,
    bool progress = false}) async {
  Directory? _appSupportDirectory = await getApplicationSupportDirectory();

  if (_appSupportDirectory != null) {
    HttpClient httpClient = new HttpClient();

    ///
    ///
    /// delete existing Files and Links in App Support Directory
    ///
    ///

    List<FileSystemEntity> initialListOfFiles =
        await _appSupportDirectory.list(recursive: true).toList();

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
        dossiersFilePath = _appSupportDirectory.path + "/dossiers.zip";
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
        dossiersFilePath, _appSupportDirectory.path + "/docs_legis");

    initialListOfFiles =
        await _appSupportDirectory.list(recursive: true).toList();
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
        votesFilePath = _appSupportDirectory.path + "/votes.zip";
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
        votesFilePath, _appSupportDirectory.path + "/votes");

    initialListOfFiles =
        await _appSupportDirectory.list(recursive: true).toList();
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
        amendementsFilePath = _appSupportDirectory.path + "/amendements.zip";
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
        amendementsFilePath, _appSupportDirectory.path + "/amendements");

    initialListOfFiles =
        await _appSupportDirectory.list(recursive: true).toList();
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
        await _appSupportDirectory.list(recursive: true).toList();

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

    return true;
  }

  return false;
}
