import 'package:flutter/material.dart' as M;

class TextFormField extends M.TextFormField {
  TextFormField({
    bool obscureText = false,
    String placeholder,
    String Function(String) validator,
    void Function(String) onChanged,
  }) : super(
          obscureText: obscureText,
          validator: validator,
          onChanged: onChanged,
          decoration: M.InputDecoration(
            labelText: placeholder,
            border: M.OutlineInputBorder(
              borderRadius: M.BorderRadius.circular(4.0),
            ),
          ),
        );
}
