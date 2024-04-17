import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'package:todo/model/todo_model.dart';
import 'package:todo/model/task_model.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DBProvider {
  static Database? _database; // Declare a static Database object

  DBProvider._(); // Private constructor to prevent instantiation
  static final DBProvider db = DBProvider._(); // Singleton instance

  var todos = [
    Todo(
      "Vegetables",
      DateTime.now(),
      Priority.medium,
      parent: '1',
    ),
    Todo(
      "Birthday gift",
      DateTime.now(),
      Priority.high,
      parent: '1',
    ),
    Todo(
      "Chocolate cookies",
      DateTime.now(),
      Priority.low,
      parent: '1',
      isCompleted: 1,
    ),
    Todo(
      "20 pushups",
      DateTime.now(),
      Priority.medium,
      parent: '2',
    ),
    Todo(
      "Tricep",
      DateTime.now(),
      Priority.low,
      parent: '2',
    ),
    Todo(
      "15 burpees (3 sets)",
      DateTime.now(),
      Priority.high,
      parent: '2',
    ),
  ];

  var tasks = [
    Task('Shopping',
        id: '1',
        color: Colors.purple.value,
        codePoint: Icons.shopping_cart.codePoint),
    Task('Workout',
        id: '2',
        color: Colors.pink.value,
        codePoint: Icons.fitness_center.codePoint),
  ];

  Future<Database> get database async {
    return _database ??
        await initDB(); // Return existing database or initialize a new one
  }

  // Get the path of the database file
  get _dbPath async {
    String documentsDirectory = await _localPath;
    return p.join(documentsDirectory, "Todo.db");
  }

  // Check if the database file exists
  Future<bool> dbExists() async {
    return File(await _dbPath).exists();
  }

  // Initialize the database
  initDB() async {
    String path = await _dbPath;
    if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
      // Initialize sqflite ffi for desktop platforms
      sqfliteFfiInit();
      var db = await databaseFactoryFfi.openDatabase(path);
      await db.execute("CREATE TABLE IF NOT EXISTS Task ("
          "id TEXT PRIMARY KEY,"
          "name TEXT,"
          "color INTEGER,"
          "code_point INTEGER"
          ")");
      await db.execute("CREATE TABLE IF NOT EXISTS Todo ("
          "id TEXT PRIMARY KEY,"
          "name TEXT,"
          "parent TEXT,"
          "dateTime TEXT," // Add the dateTime column
          "completed INTEGER NOT NULL DEFAULT 0"
          ")");
      return db;
    }
    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      print("DBProvider:: onCreate()");
      await db.execute("CREATE TABLE IF NOT EXISTS Task ("
          "id TEXT PRIMARY KEY,"
          "name TEXT,"
          "color INTEGER,"
          "code_point INTEGER"
          ")");
      await db.execute("CREATE TABLE IF NOT EXISTS Todo ("
          "id TEXT PRIMARY KEY,"
          "name TEXT,"
          "parent TEXT,"
          "dateTime TEXT," // Add the dateTime column
          "completed INTEGER NOT NULL DEFAULT 0"
          ")");
    });
  }

  // Insert multiple tasks into the database
  insertBulkTask(List<Task> tasks) async {
    final db = await database;
    tasks.forEach((it) async {
      var res = await db.insert("Task", it.toJson());
      print("Task ${it.id} = $res");
    });
  }

  // Insert multiple todos into the database
  insertBulkTodo(List<Todo> todos) async {
    final db = await database;
    todos.forEach((it) async {
      var res = await db.insert("Todo", it.toJson());
      print("Todo ${it.id} = $res");
    });
  }

  // Retrieve all tasks from the database
  Future<List<Task>> getAllTask() async {
    final db = await database;
    var result = await db.query('Task');
    return result.map((it) => Task.fromJson(it)).toList();
  }

  // Retrieve all todos from the database
  Future<List<Todo>> getAllTodo() async {
    final db = await database;
    var result = await db.query('Todo');
    return result.map((it) => Todo.fromJson(it)).toList();
  }

  // Update a todo in the database
  Future<int> updateTodo(Todo todo) async {
    final db = await database;
    return db
        .update('Todo', todo.toJson(), where: 'id = ?', whereArgs: [todo.id]);
  }

  // Remove a todo from the database
  Future<int> removeTodo(Todo todo) async {
    final db = await database;
    return db.delete('Todo', where: 'id = ?', whereArgs: [todo.id]);
  }

  // Insert a single todo into the database
  Future<int> insertTodo(Todo todo) async {
    final db = await database;
    return db.insert('Todo', todo.toJson());
  }

  // Insert a single task into the database
  Future<int> insertTask(Task task) async {
    final db = await database;
    return db.insert('Task', task.toJson());
  }

  // Remove a task and its associated todos from the database
  Future<void> removeTask(Task task) async {
    final db = await database;
    return db.transaction<void>((txn) async {
      await txn.delete('Todo', where: 'parent = ?', whereArgs: [task.id]);
      await txn.delete('Task', where: 'id = ?', whereArgs: [task.id]);
    });
  }

  // Update a task in the database
  Future<int> updateTask(Task task) async {
    final db = await database;
    return db
        .update('Task', task.toJson(), where: 'id = ?', whereArgs: [task.id]);
  }

  // Get the local path for storing the database file
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  // Close the database
  closeDB() {
    _database?.close();
  }
}
