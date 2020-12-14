import 'package:flutter/material.dart';

class CustomAppBar extends AppBar {
  CustomAppBar(
      {String title,
      List<Widget> actions,
      Function onGoBack,
      bool goBackIconVisible = false})
      : super(
          title: Text(
            title,
            style: TextStyle(
              color: Colors.deepPurple[400],
              fontSize: 24,
              letterSpacing: 0.18,
            ),
          ),
          leading: goBackIconVisible
              ? IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.deepPurple[400],
                  ),
                  onPressed: onGoBack,
                )
              : null,
          actions: actions,
          backgroundColor: Colors.white,
          elevation: 0,
        );
}
