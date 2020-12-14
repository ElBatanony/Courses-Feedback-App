import 'package:flutter/material.dart';

class Logo extends Image {
  Logo({bool dark = false, double height = 100})
      : super(
          height: height,
          image: AssetImage(
              dark ? 'images/logo-dark.png' : 'images/logo-light.png'),
        );
}
