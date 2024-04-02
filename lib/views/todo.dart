import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({Key? key}) : super(key: key);

  @override
  _TodoScreenState createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  final List<TodoItem> _todoList = [];
  int _quoteIndex = 0;
  final List<String> _quotes = [
    "The key is not to prioritize what's on your schedule, but to schedule your priorities. - Stephen Covey",
    "You cannot do everything at once, so find people who can help you and divide the work. Each person’s contribution is important, and together, we can achieve great things. - Sonia Sotomayor",
    "Productivity is not about doing more; it's about doing the right things at the right time. - Unknown",
    "Focus on being productive instead of busy. - Tim Ferriss",
    "The future depends on what you do today. - Mahatma Gandhi",
  ];

  ThemeMode _currentThemeMode = ThemeMode.system;

  final String _todoListKey = 'todoList';
  final String _themeModeKey = 'themeMode';

  @override
  void initState() {
    super.initState();
    _loadTodoListFromPrefs();
    _loadThemeModeFromPrefs();
    Timer.periodic(const Duration(seconds: 10), (timer) {
      _changeQuote();
    });
    initializeNotifications();
  }

  void initializeNotifications() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    var initializationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = DarwinInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
        onDidReceiveLocalNotification:
            (int id, String? title, String? body, String? payload) async {});
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void _loadThemeModeFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    ThemeMode? savedThemeMode =
        ThemeMode.values[prefs.getInt(_themeModeKey) ?? ThemeMode.system.index];
    setState(() {
      _currentThemeMode = savedThemeMode ?? ThemeMode.system;
    });
  }

  void _saveThemeModeToPrefs(ThemeMode themeMode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeModeKey, themeMode.index);
  }

  void _loadTodoListFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? todoListJson = prefs.getStringList(_todoListKey);
    if (todoListJson != null) {
      setState(() {
        _todoList.clear();
        _todoList.addAll(todoListJson
            .map((json) => TodoItem.fromJson(jsonDecode(json)))
            .toList());
      });
    }
  }

  void _saveTodoListToPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> todoListJson =
        _todoList.map((todo) => jsonEncode(todo.toJson())).toList();
    await prefs.setStringList(_todoListKey, todoListJson);
  }

  void _addTodoItem(
    String title,
    String task,
    Priority priority,
    DateTime? date,
  ) async {
    setState(() {
      _todoList.add(TodoItem(
        title: title,
        task: task,
        priority: priority,
        date: date,
      ));
      _saveTodoListToPrefs();
    });

    if (date != null) {
      tz.Location timeZone = tz.getLocation('Asia/Kolkata');

      tz.TZDateTime notificationTime = tz.TZDateTime.from(
        date.subtract(const Duration(seconds: 24)),
        timeZone,
      );

      await flutterLocalNotificationsPlugin.zonedSchedule(
        _todoList.length,
        'Task Deadline Reminder',
        'You have a task "$title" due in 24 hours!',
        notificationTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'task deadline channel id',
            'task deadline channel name',
            channelDescription: 'task deadline channel description',
          ),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  void _editTodoItem(
    int index,
    String title,
    String task,
    Priority priority,
    DateTime? date,
  ) {
    setState(() {
      _todoList[index] = TodoItem(
        title: title,
        task: task,
        priority: priority,
        date: date,
      );
      _saveTodoListToPrefs();
    });
  }

  void _changeQuote() {
    setState(() {
      _quoteIndex = (_quoteIndex + 1) % _quotes.length;
    });
  }

  void _showAddTodoDialog(BuildContext context, {TodoItem? todoItem}) {
    String title = todoItem?.title ?? '';
    String task = todoItem?.task ?? '';
    Priority priority = todoItem?.priority ?? Priority.Low;
    DateTime? selectedDate = todoItem?.date;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Task'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: TextEditingController(text: title),
                  onChanged: (value) {
                    title = value;
                  },
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: TextEditingController(text: task),
                  onChanged: (value) {
                    task = value;
                  },
                  decoration: const InputDecoration(labelText: 'Task'),
                ),
                DropdownButtonFormField<Priority>(
                  value: priority,
                  onChanged: (Priority? value) {
                    setState(() {
                      priority = value!;
                    });
                  },
                  items: Priority.values
                      .map((priority) => DropdownMenuItem<Priority>(
                            value: priority,
                            child: Text(priority.toString().split('.').last),
                          ))
                      .toList(),
                  decoration: const InputDecoration(labelText: 'Priority'),
                ),
                ListTile(
                  title: Text(
                    selectedDate == null
                        ? 'Select Due Date'
                        : 'Due Date: ${selectedDate.toString().split(' ')[0]}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: selectedDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null && pickedDate != selectedDate) {
                      setState(() {
                        selectedDate = pickedDate;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (todoItem != null) {
                  int index = _todoList.indexOf(todoItem);
                  _editTodoItem(index, title, task, priority, selectedDate);
                } else {
                  _addTodoItem(title, task, priority, selectedDate);
                }
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do List'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _quotes[_quoteIndex],
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _todoList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_todoList[index].title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_todoList[index].task),
                      Text(
                        _todoList[index].getPriorityString(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                          color:
                              _getColorForPriority(_todoList[index].priority),
                        ),
                      ),
                      if (_todoList[index].date != null)
                        Text(
                          'Due Date: ${_todoList[index].date!.toString().split(' ')[0]}',
                          style: const TextStyle(
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],
                  ),
                  leading: CircleAvatar(
                    radius: 10,
                    backgroundColor:
                        _getColorForPriority(_todoList[index].priority),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      _showAddTodoDialog(context, todoItem: _todoList[index]);
                    },
                  ),
                  onTap: () {
                    _showAddTodoDialog(context, todoItem: _todoList[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTodoDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Color _getColorForPriority(Priority priority) {
    switch (priority) {
      case Priority.Low:
        return const Color.fromARGB(255, 70, 199, 75);
      case Priority.Medium:
        return const Color.fromARGB(255, 243, 222, 41);
      case Priority.High:
        return const Color.fromARGB(255, 255, 65, 51);
    }
  }
}

enum Priority {
  Low,
  Medium,
  High,
}

class TodoItem {
  final String title;
  final String task;
  final Priority priority;
  final DateTime? date;

  TodoItem({
    required this.title,
    required this.task,
    required this.priority,
    this.date,
  });

  factory TodoItem.fromJson(Map<String, dynamic> json) {
    return TodoItem(
      title: json['title'],
      task: json['task'],
      priority: Priority.values[json['priority']],
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'task': task,
      'priority': priority.index,
      'date': date?.toIso8601String(),
    };
  }

  String getPriorityString() {
    switch (priority) {
      case Priority.High:
        return 'High Priority';
      case Priority.Medium:
        return 'Medium Priority';
      case Priority.Low:
        return 'Low Priority';
      default:
        return 'Unknown Priority';
    }
  }
}
