
import 'package:flutter/widgets.dart';

class EditTaskController with ChangeNotifier {
  late String taskName;
  setTaskName(String task) {
    taskName = task;
    notifyListeners();
  }

  late Color taskColor;
  setTaskColor(Color newColor) {
    taskColor = newColor;
    notifyListeners();
  }

  late IconData taskIcon;
  setTaskIcon(IconData newIcon) {
    taskIcon = newIcon;
    notifyListeners();
  }
}
