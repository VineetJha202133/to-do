import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:todo/model/todo_model.dart';

class AddTodoController with ChangeNotifier{
  late String newTask;
  setNewTask(String task){
    newTask = task;
    notifyListeners();
  }
  late DateTime selectedDate = DateTime.now(); // Selected date
  late Priority selectedPriority = Priority.Medium; // Selected priority
  setSelectedPriority(Priority p){
    selectedPriority = p;
    notifyListeners();
  }
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
}