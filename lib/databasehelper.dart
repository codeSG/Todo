import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// Task data model
class Task {
  int? id;
  String title;
  String subtitle;
  bool isCompleted;

  Task(
      {this.id,
      required this.title,
      this.subtitle = "",
      this.isCompleted = false});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'isCompleted': isCompleted ? 1 : 0,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      subtitle: map['subtitle'],
      isCompleted: map['isCompleted'] == 1,
    );
  }
}

// SQLite Database Helper
class DatabaseHelper with ChangeNotifier {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), 'tasklist.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE tasklist(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            subtitle TEXT,
            isCompleted INTEGER
          )
        ''');
      },
    );
  }

  Future<List<Task>> getTasks() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('tasklist');
    return List.generate(maps.length, (i) {
      print(maps[i]);
      return Task.fromMap(maps[i]);
    });
  }

  Future<int> insertTask(Task task) async {
    final Database db = await database;
    print(task.title + "Created");
    notifyListeners(); // Notify listeners after insertion
    return await db.insert('tasklist', task.toMap());
  }

  Future<int> updateTask(Task task) async {
    final Database db = await database;

    int rows = await db.update(
      'tasklist',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
    notifyListeners(); // Notify listeners after insertion
    return rows;
  }

  Future<int> deleteTask(int id) async {
    final Database db = await database;

    int delete = await db.delete(
      'tasklist',
      where: 'id = ?',
      whereArgs: [id],
    );
    print(delete);
    print("Deleleted");
    notifyListeners(); // Notify listeners after insertion
    return delete;
  }
}
