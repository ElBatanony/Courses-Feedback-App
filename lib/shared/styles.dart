import 'package:flutter/material.dart';

const textInputDecoration = InputDecoration(
  fillColor: Colors.white,
  filled: true,
  contentPadding: EdgeInsets.all(12.0),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Color.fromARGB(30, 0, 0, 0), width: 2.0),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: ColorsStyle.primary, width: 2.0),
  ),
);

class ColorsStyle {
  static const Color primary = Color(0xFF6200EE);
  static const Color inactiveThumb = Color(0xFFA4A4A4);
  static const Color inactiveTrack = Color(0xFFDDDDDD);
  static const Color error = Colors.redAccent;
  static const Color success = Colors.green;
  static const Color divider = Color.fromARGB(200, 33, 33, 33);
}
