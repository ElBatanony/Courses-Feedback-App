import 'package:flutter/material.dart';

const textInputDecoration = InputDecoration(
  fillColor: Colors.white,
  filled: true,
  contentPadding: EdgeInsets.all(12.0),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.white, width: 2.0),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.pink, width: 2.0),
  ),
);

class ColorsStyle {
  static const Color primary = Color(0xFF6200EE);
  static const Color inactiveThumb = Color(0xFFA4A4A4);
  static const Color inactiveTrack = Color(0xFFDDDDDD);
}
