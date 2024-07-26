import 'package:flutter/material.dart';
import 'package:todo/component/todo_badge.dart';
import 'package:todo/main.dart';
import 'package:todo/model/hero_id_model.dart';
import 'package:todo/model/task_model.dart';
import 'package:todo/module/page/detail_screen.dart';
import 'package:todo/route/scale_route.dart';
import 'package:todo/utils/color_utils.dart';
import 'package:todo/utils/task_progress_indicator.dart';

typedef TaskGetter<T, V> = V Function(T value);

class TaskCard extends StatelessWidget {
  final GlobalKey backdropKey;
  final Task task;
  final Color color;
  final bool isDarkMode; // Add this line

  final TaskGetter<Task, int> getTotalTodos;
  final TaskGetter<Task, HeroId> getHeroIds;
  final TaskGetter<Task, int> getTaskCompletionPercent;

  TaskCard({
    required this.backdropKey,
    required this.color,
    required this.task,
    required this.getTotalTodos,
    required this.getHeroIds,
    required this.getTaskCompletionPercent,
    required this.isDarkMode, // Add this line
  });

  @override
  Widget build(BuildContext context) {
    var heroIds = getHeroIds(task);
    return GestureDetector(
      onTap: () {
        final RenderBox? renderBox =
            backdropKey.currentContext?.findRenderObject() as RenderBox;
        var backDropHeight = renderBox?.size.height ?? 0;
        var bottomOffset = 60.0;
        var horizontalOffset = 52.0;
        var topOffset = MediaQuery.of(context).size.height - backDropHeight;

        var rect = RelativeRect.fromLTRB(
            horizontalOffset, topOffset, horizontalOffset, bottomOffset);
        Navigator.push(
          context,
          ScaleRoute(
            rect: rect,
            widget: DetailScreen(
              taskId: task.id,
              heroIds: heroIds,
            ),
          ),
          // MaterialPageRoute(
          //   builder: (context) => DetailScreen(
          //         taskId: task.id,
          //         heroIds: heroIds,
          //       ),
          // ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        elevation: 4.0,
        margin: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
        color: isDarkMode
            ? Colors.white.withOpacity(0.7)
            : Colors.grey.withOpacity(0.5), // Use isDarkMode here
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TodoBadge(
                id: heroIds.codePointId,
                codePoint: task.codePoint,
                color: ColorUtils.getColorFrom(
                  id: task.color,
                ),
              ),
              Spacer(
                flex: 8,
              ),
              Container(
                margin: EdgeInsets.only(bottom: 4.0),
                child: Hero(
                  tag: heroIds.remainingTaskId,
                  child: Text(
                    "${getTotalTodos(task)} Task",
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: Colors.grey[500]),
                  ),
                ),
              ),
              Container(
                child: Hero(
                  tag: heroIds.titleId,
                  child: Text(task.name,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: Colors.black54)),
                ),
              ),
              Spacer(),
              Hero(
                tag: heroIds.progressId,
                child: TaskProgressIndicator(
                  color: color,
                  progress: getTaskCompletionPercent(task),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
