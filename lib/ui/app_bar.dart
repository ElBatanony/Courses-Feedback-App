import 'package:flutter/material.dart';

class CustomAppBar extends AppBar {
  CustomAppBar({String title, List<Widget> actions})
      : super(
          title: Text(
            title,
            style: TextStyle(
              color: Colors.deepPurple[400],
              fontSize: 24,
              letterSpacing: 0.18,
            ),
          ),
          actions: actions,
          backgroundColor: Colors.white,
          elevation: 0,
          titleSpacing: 30,
        );
}
