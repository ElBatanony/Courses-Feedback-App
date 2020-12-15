import 'package:flutter/material.dart';

class ActionButton extends FlatButton {
  final String text;
  final void Function() onPressed;
  final Icon icon;

  ActionButton({this.text, this.onPressed, this.icon})
      : super(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                  child: icon,
                ),
              Text(
                text.toUpperCase(),
                style: TextStyle(
                  fontSize: 16,
                  letterSpacing: 1.25,
                ),
              ),
            ],
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
