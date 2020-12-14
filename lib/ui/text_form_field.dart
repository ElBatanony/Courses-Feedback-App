import 'package:flutter/material.dart';

class CustomTextFormField extends TextFormField {
  CustomTextFormField({
    bool obscureText = false,
    String placeholder,
    String Function(String) validator,
    void Function(String) onChanged,
  }) : super(
          obscureText: obscureText,
          validator: validator,
          onChanged: onChanged,
          decoration: InputDecoration(
            labelText: placeholder,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4.0),
            ),
          ),
        );
}
