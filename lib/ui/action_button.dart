import 'package:flutter/material.dart';

class ActionButton extends FlatButton {
  final String text;
  final void Function() onPressed;

  ActionButton({this.text, this.onPressed})
      : super(
          child: Text(
            text.toUpperCase(),
            style: TextStyle(
              fontSize: 16,
              letterSpacing: 1.25,
            ),
          ),
          textColor: Colors.white,
          color: Colors.deepPurple[500],
          padding: EdgeInsets.symmetric(
            vertical: 20,
            horizontal: 15,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          onPressed: onPressed,
        );
}
