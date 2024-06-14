import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'task.dart';

class ReadAndWrite {
  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/tasks.json');
  }

  static Future<List<Task>> readData() async {
    try {
      final file = await _localFile;
      final contents = await file.readAsString();
      final List<dynamic> jsonData = json.decode(contents);
      return jsonData.map((json) => Task.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<File> writeData(List<Task> tasks) async {
    final file = await _localFile;
    final String jsonData =
        json.encode(tasks.map((task) => task.toJson()).toList());
    return file.writeAsString(jsonData);
  }
}
