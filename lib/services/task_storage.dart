import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/task.dart';

class TaskStorage {
  static const String _tasksKey = 'tasks';

  Future<void> saveTasks(
    List<Task> tasks,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final taskList = tasks.map((task) => task.toJson()).toList();
    final encodedTasks = jsonEncode(taskList);
    await prefs.setString(_tasksKey, encodedTasks);
  }

  Future<List<Task>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final encodedTasks = prefs.getString(_tasksKey);
    if (encodedTasks == null || encodedTasks.isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(encodedTasks);
      if (decoded is! List) {
        return [];
      }
      return decoded
          .map(
            (item) => Task.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> clearTasks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tasksKey);
  }
}
