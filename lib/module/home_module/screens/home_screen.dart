import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:provider/provider.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:todo/db/db_provider.dart';
import 'package:todo/main.dart';
import 'package:todo/model/hero_id_model.dart';
import 'package:todo/model/task_model.dart';
import 'package:todo/module/auth_module/screens/auth_screen.dart';
import 'package:todo/module/home_module/controller/home_screen_controller.dart';
import 'package:todo/module/home_module/screens/add_page.dart';
import 'package:todo/module/home_module/screens/task_card.dart';
import 'package:todo/scopedmodel/todo_list_model.dart';
import 'package:todo/services/local_notification.dart';
import 'package:todo/services/shared_preferences_services.dart';
import 'package:todo/utils/color_utils.dart';
import 'package:todo/utils/datetime_utils.dart';
import 'package:todo/utils/enum/shared_prefs_keys_enum.dart';
import 'package:todo/utils/gradient_background.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  HeroId _generateHeroIds(Task task) {
    return HeroId(
      codePointId: 'code_point_id_${task.id}',
      progressId: 'progress_id_${task.id}',
      titleId: 'title_id_${task.id}',
      remainingTaskId: 'remaining_task_id_${task.id}',
    );
  }

  String currentDay(BuildContext context) {
    return DateTimeUtils.currentDay;
  }

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  HomeScreenController homeScreenController = HomeScreenController();
  late AnimationController _controller;
  late Animation<double> _animation;
  final GlobalKey _backdropKey = GlobalKey(debugLabel: 'Backdrop');
  late PageController _pageController;

  // bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _pageController = PageController(initialPage: 0, viewportFraction: 0.8);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HomeScreenController>(
      create: (BuildContext context) => homeScreenController,
      child: ScopedModelDescendant<TodoListModel>(
        builder: (BuildContext context, Widget? child, TodoListModel model) {
          var _isLoading = model.isLoading;
          var _tasks = model.tasks;
          var _todos = model.todos;
          var backgroundColor = _tasks.isEmpty ||
                  _tasks.length == homeScreenController.currentPageIndex
              ? Colors.blueGrey
              : ColorUtils.getColorFrom(
                  id: _tasks[homeScreenController.currentPageIndex].color);
          if (!_isLoading) {
            // move the animation value towards upperbound only when loading is complete
            _controller.forward();
          }
          return GradientBackground(
            color: backgroundColor,
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                title: Text(widget.title),
                centerTitle: true,
                elevation: 0.0,
                backgroundColor: Colors.transparent,
                actions: [
                  IconButton(
                    onPressed: () {
                      homeScreenController.deleteDatabase(context);
                      LocalNotification.cancelAllNotifications();
                    },
                    icon: Icon(
                      Icons.logout,
                      color: Colors.white,
                    ),
                  ),
                  // PopupMenuButton<Choice>(
                  //   onSelected: (choice) {
                  //     Navigator.of(context).push(MaterialPageRoute(
                  //         builder: (BuildContext context) => AboutScreen()));
                  //   },
                  //   itemBuilder: (BuildContext context) {
                  //     return choices.map((Choice choice) {
                  //       return PopupMenuItem<Choice>(
                  //         value: choice,
                  //         child: Text(choice.title),
                  //       );
                  //     }).toList();
                  //   },
                  // ),
                ],
              ),
              body: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 1.0,
                        valueColor:
                            new AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : FadeTransition(
                      opacity: _animation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(top: 0.0, left: 56.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                // ShadowImage(),
                                Container(
                                  // margin: EdgeInsets.only(top: 22.0),
                                  child: Text(
                                    '${widget.currentDay(context)}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .displayLarge
                                        ?.copyWith(
                                          color: Colors.white.withOpacity(0.7),
                                        ),
                                  ),
                                ),
                                Text(
                                  '${DateTimeUtils.currentDate} ${DateTimeUtils.currentMonth}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayMedium
                                      ?.copyWith(
                                          color: Colors.white.withOpacity(0.7)),
                                ),
                                Container(height: 16.0),
                                Text(
                                  'You have ${_todos.where((todo) => todo.isCompleted == 0).length} tasks to complete',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                          color: Colors.white.withOpacity(0.7)),
                                ),

                                Container(
                                  height: 16.0,
                                )
                                // Container(
                                //   margin: EdgeInsets.only(top: 42.0),
                                //   child: Text(
                                //     'TODAY : FEBURARY 13, 2019',
                                //     style: Theme.of(context)
                                //         .textTheme
                                //         .subtitle
                                //         .copyWith(color: Colors.white.withOpacity(0.8)),
                                //   ),
                                // ),
                              ],
                            ),
                          ),
                          Expanded(
                            key: _backdropKey,
                            flex: 1,
                            child: NotificationListener<ScrollNotification>(
                              onNotification: (notification) {
                                if (notification is ScrollEndNotification) {
                                  print(
                                      "ScrollNotification = ${_pageController.page}");
                                  var currentPage =
                                      _pageController.page?.round().toInt() ??
                                          0;
                                  if (homeScreenController.currentPageIndex !=
                                      currentPage) {
                                    homeScreenController
                                        .setCurrentPageIndex(currentPage);
                                  }
                                }
                                return true;
                              },
                              child: PageView.builder(
                                controller: _pageController,
                                itemBuilder: (BuildContext context, int index) {
                                  if (index == _tasks.length) {
                                    return AddPageCard(
                                      color: Colors.blueGrey,
                                    );
                                  } else {
                                    return TaskCard(
                                      backdropKey: _backdropKey,
                                      color: ColorUtils.getColorFrom(
                                          id: _tasks[index].color),
                                      getHeroIds: widget._generateHeroIds,
                                      getTaskCompletionPercent:
                                          model.getTaskCompletionPercent,
                                      getTotalTodos: model.getTotalTodosFrom,
                                      task: _tasks[index],
                                      isDarkMode: true, // Add this line
                                    );
                                  }
                                },
                                itemCount: _tasks.length + 1,
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(bottom: 32.0),
                          ),
                        ],
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
