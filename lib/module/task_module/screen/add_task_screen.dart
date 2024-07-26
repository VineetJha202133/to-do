import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:todo/module/task_module/controller/add_task_controller.dart';

import 'package:todo/scopedmodel/todo_list_model.dart';
import 'package:todo/model/task_model.dart';
import 'package:todo/component/iconpicker/screens/icon_picker_builder.dart';
import 'package:todo/component/colorpicker/color_picker_builder.dart';
import 'package:todo/utils/color_utils.dart';

import '../../../services/local_notification.dart';

class AddTaskScreen extends StatefulWidget {
  AddTaskScreen();

  @override
  State<StatefulWidget> createState() {
    return _AddTaskScreenState();
  }
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  AddTaskController addTaskController = AddTaskController();

  @override
  void initState() {
    super.initState();
    addTaskController.setNewTask('');
    addTaskController.setTaskColor(ColorUtils.defaultColors[0]);
    addTaskController.setTaskIcon(Icons.work);
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<TodoListModel>(
      builder: (BuildContext context, Widget? child, TodoListModel model) {
        return ChangeNotifierProvider<AddTaskController>(
          create: (context) => addTaskController,
          child: Scaffold(
            key: addTaskController.scaffoldKey,
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: Text(
                'New Category',
                style: TextStyle(color: Colors.black),
              ),
              centerTitle: true,
              elevation: 0,
              iconTheme: IconThemeData(color: Colors.black26),
              leading: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                  )),
              backgroundColor: Colors.white,
            ),
            body: Container(
              constraints: BoxConstraints.expand(),
              padding: EdgeInsets.symmetric(horizontal: 36.0, vertical: 36.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Category will help you group related task!',
                    style: TextStyle(
                        color: Colors.black38,
                        fontWeight: FontWeight.w600,
                        fontSize: 16.0),
                  ),
                  Container(
                    height: 16.0,
                  ),
                  TextField(
                    onChanged: (text) {
                      addTaskController.setNewTask(text);
                    },
                    cursorColor: addTaskController.taskColor,
                    autofocus: true,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Category Name...',
                        hintStyle: TextStyle(
                          color: Colors.black26,
                        )),
                    style: TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                        fontSize: 36.0),
                  ),
                  Container(
                    height: 26.0,
                  ),
                  Row(
                    children: [
                      ColorPickerBuilder(
                          color: addTaskController.taskColor,
                          onColorChanged: (newColor) =>
                              addTaskController.setTaskColor(newColor)),
                      Container(
                        width: 22.0,
                      ),
                      IconPickerBuilder(
                          iconData: addTaskController.taskIcon,
                          highlightColor: addTaskController.taskColor,
                          action: (newIcon) =>
                              addTaskController.setTaskIcon(newIcon)),
                    ],
                  ),
                ],
              ),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            floatingActionButton: Builder(
              builder: (BuildContext context) {
                return FloatingActionButton.extended(
                  heroTag: 'fab_new_card',
                  icon: Icon(Icons.save),
                  backgroundColor: addTaskController.taskColor,
                  label: Text('Create New Card'),
                  onPressed: () {
                    if (addTaskController.newTask.isEmpty) {
                      final snackBar = SnackBar(
                        content: Text(
                            'Ummm... It seems that you are trying to add an invisible task which is not allowed in this realm.'),
                        backgroundColor: addTaskController.taskColor,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      // _scaffoldKey.currentState.showSnackBar(snackBar);
                    } else {
                      model.addTask(Task(addTaskController.newTask,
                          codePoint: addTaskController.taskIcon.codePoint,
                          color: addTaskController.taskColor.value));

                      Navigator.pop(context);
                    }
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}
