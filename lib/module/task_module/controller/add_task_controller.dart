
import 'package:flutter/material.dart';

class AddTaskController with ChangeNotifier{
  late String newTask;
  setNewTask(String task){
    newTask = task;
    notifyListeners();
  }

  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  
  late Color taskColor;
  setTaskColor(Color newColor){
    taskColor = newColor;
    notifyListeners();
  }

  late IconData taskIcon;
  setTaskIcon(IconData newIcon){
    taskIcon = newIcon;
    notifyListeners();
  }
}