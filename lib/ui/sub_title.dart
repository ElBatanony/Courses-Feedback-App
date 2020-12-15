import 'package:flutter/material.dart';

class SubTitle extends Text {
  SubTitle(String text)
      : super(
          text,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        );
}
