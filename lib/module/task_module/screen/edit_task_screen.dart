import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:todo/module/task_module/controller/edit_task_controller.dart';

import 'package:todo/scopedmodel/todo_list_model.dart';
import 'package:todo/model/task_model.dart';
import 'package:todo/component/iconpicker/screens/icon_picker_builder.dart';
import 'package:todo/component/colorpicker/color_picker_builder.dart';

class EditTaskScreen extends StatefulWidget {
  final String taskId;
  final String taskName;
  final Color color;
  final IconData icon;

  EditTaskScreen({
    required this.taskId,
    required this.taskName,
    required this.color,
    required this.icon,
  });

  @override
  State<StatefulWidget> createState() {
    return _EditCardScreenState();
  }
}

class _EditCardScreenState extends State<EditTaskScreen> {
  EditTaskController editTaskController = EditTaskController();

  final btnSaveTitle = "Save Changes";

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    editTaskController.setTaskName(widget.taskName);
    editTaskController.setTaskColor(widget.color);
    editTaskController.setTaskIcon(widget.icon);
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<TodoListModel>(
      builder: (BuildContext context, Widget? child, TodoListModel model) {
        return ChangeNotifierProvider<EditTaskController>(
          create: (BuildContext context) => editTaskController,
          child: Scaffold(
            key: _scaffoldKey,
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: Text(
                'Edit Category',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              centerTitle: true,
              elevation: 0,
              iconTheme: IconThemeData(
                color: Colors.black26,
              ),
              backgroundColor: Colors.white,
            ),
            body: Container(
              constraints: BoxConstraints.expand(),
              padding: EdgeInsets.symmetric(
                horizontal: 36.0,
                vertical: 36.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Category will help you group related task!',
                    style: TextStyle(
                      color: Colors.black38,
                      fontWeight: FontWeight.w600,
                      fontSize: 16.0,
                    ),
                  ),
                  Container(
                    height: 16.0,
                  ),
                  TextFormField(
                    initialValue: editTaskController.taskName,
                    onChanged: (text) {
                      editTaskController.setTaskName(text);
                    },
                    cursorColor: editTaskController.taskColor,
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
                        color: editTaskController.taskColor,
                        onColorChanged: (newColor) =>
                            editTaskController.setTaskColor(newColor),
                      ),
                      Container(
                        width: 22.0,
                      ),
                      IconPickerBuilder(
                        iconData: editTaskController.taskIcon,
                        highlightColor: editTaskController.taskColor,
                        action: (newIcon) =>
                            editTaskController.setTaskIcon(newIcon),
                      ),
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
                  backgroundColor: editTaskController.taskColor,
                  label: Text(btnSaveTitle),
                  onPressed: () {
                    if (editTaskController.taskName.isEmpty) {
                      final snackBar = SnackBar(
                        content: Text(
                            'Ummm... It seems that you are trying to add an invisible task which is not allowed in this realm.'),
                        backgroundColor: editTaskController.taskColor,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      // _scaffoldKey.currentState.showSnackBar(snackBar);
                    } else {
                      model.updateTask(
                        Task(
                          editTaskController.taskName,
                          codePoint: editTaskController.taskIcon.codePoint,
                          color: editTaskController.taskColor.value,
                          id: widget.taskId,
                        ),
                      );
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

// Reason for wraping fab with builder (to get scafold context)
// https://stackoverflow.com/a/52123080/4934757
