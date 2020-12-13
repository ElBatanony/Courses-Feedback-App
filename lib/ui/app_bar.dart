import 'package:flutter/material.dart' as M;

class AppBar extends M.AppBar {
  AppBar({String title, List<M.Widget> actions})
      : super(
          title: M.Text(
            title,
            style: M.TextStyle(
              color: M.Colors.deepPurple[400],
              fontSize: 24,
              letterSpacing: 0.18,
            ),
          ),
          actions: actions,
          backgroundColor: M.Colors.white,
          elevation: 0,
          titleSpacing: 30,
        );
}
