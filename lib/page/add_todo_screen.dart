import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for date formatting
import 'package:scoped_model/scoped_model.dart';

import 'package:todo/scopedmodel/todo_list_model.dart';
import 'package:todo/model/todo_model.dart';
import 'package:todo/utils/color_utils.dart';
import 'package:todo/component/todo_badge.dart';
import 'package:todo/model/hero_id_model.dart';

class AddTodoScreen extends StatefulWidget {
  final String taskId;
  final HeroId heroIds;

  AddTodoScreen({
    required this.taskId,
    required this.heroIds,
  });

  @override
  State<StatefulWidget> createState() {
    return _AddTodoScreenState();
  }
}

class _AddTodoScreenState extends State<AddTodoScreen> {
  late String newTask;
  late DateTime selectedDate = DateTime.now(); // Selected date
  late Priority selectedPriority = Priority.medium; // Selected priority
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    newTask = '';
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<TodoListModel>(
      builder: (BuildContext context, Widget? child, TodoListModel model) {
        if (model.tasks.isEmpty) {
          // Loading
          return Container(
            color: Colors.white,
          );
        }

        var _task = model.tasks.firstWhere((it) => it.id == widget.taskId);
        var _color = ColorUtils.getColorFrom(id: _task.color);
        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(
              'New Task',
              style: TextStyle(color: Colors.black),
            ),
            centerTitle: true,
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.black26),
            backgroundColor: Colors.white,
          ),
          body: Container(
            constraints: BoxConstraints.expand(),
            padding: EdgeInsets.symmetric(horizontal: 36.0, vertical: 36.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What task are you planning to perform?',
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
                    setState(() => newTask = text);
                  },
                  cursorColor: _color,
                  autofocus: true,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Your Task...',
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
                    TodoBadge(
                      codePoint: _task.codePoint,
                      color: _color,
                      id: widget.heroIds.codePointId,
                      size: 20.0,
                    ),
                    Container(
                      width: 16.0,
                    ),
                    Hero(
                      child: Text(
                        _task.name,
                        style: TextStyle(
                          color: Colors.black38,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      tag: "not_using_right_now", //widget.heroIds.titleId,
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Select Date:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        final selectedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2021),
                          lastDate: DateTime(2030),
                        );
                        if (selectedDate != null) {
                          setState(() {
                            this.selectedDate = selectedDate;
                          });
                        }
                      },
                      child: Text(
                        DateFormat('yyyy-MM-dd').format(selectedDate),
                        style: TextStyle(
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Select Priority:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    DropdownButton<Priority>(
                      value: selectedPriority,
                      onChanged: (Priority? newValue) {
                        setState(() {
                          selectedPriority = newValue!;
                        });
                      },
                      items: Priority.values.map((Priority priority) {
                        return DropdownMenuItem<Priority>(
                          value: priority,
                          child: Text(priority.toString().split('.').last),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: FloatingActionButton.extended(
            heroTag: 'fab_new_task',
            icon: Icon(Icons.add),
            backgroundColor: _color,
            label: Text('Create Task'),
            onPressed: () {
              if (newTask.isEmpty) {
                final snackBar = SnackBar(
                  content: Text(
                    'Ummm... It seems that you are trying to add an invisible task which is not allowed in this realm.',
                  ),
                  backgroundColor: _color,
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              } else {
                model.addTodo(Todo(
                  newTask,
                  selectedDate,
                  selectedPriority,
                  parent: _task.id,
                ));
                Navigator.pop(context);
              }
            },
          ),
        );
      },
    );
  }
}
