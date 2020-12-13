import 'package:flutter/material.dart';

class Logo extends Image {
  Logo({bool dark})
      : super(
          image: AssetImage(
              dark ?? false ? 'images/logo-dark.png' : 'images/logo-light.png'),
        );
}
