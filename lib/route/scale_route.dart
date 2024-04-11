import 'package:flutter/material.dart';

class ScaleRoute extends PageRouteBuilder {
  final Widget widget;
  final RelativeRect rect;
  ScaleRoute({required this.widget, required this.rect})
      : super(
          pageBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation) {
            return widget;
          },
          transitionsBuilder: (BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
              Widget child) {
            return Stack(
              children: [
                Container(),
                PositionedTransition(
                  child: child,
                  rect: RelativeRectTween(
                    begin: rect,
                    end: RelativeRect.fromLTRB(0.0, 0.0, 0.0, 0.0),
                  ).animate(animation),
                ),
              ],
            );
          },
          transitionDuration: Duration(milliseconds: 300),
        );
}
