import 'package:flutter/material.dart';

class Logo extends Image {
  Logo({bool dark, double height})
      : super(
          height: height ?? 100,
          image: AssetImage(
              dark ?? false ? 'images/logo-dark.png' : 'images/logo-light.png'),
        );
}
