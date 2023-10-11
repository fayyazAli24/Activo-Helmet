import 'package:flutter/material.dart';

class AppSpace {
  static const noSpace = SizedBox.shrink();

  static vrtSpace(double height) => SizedBox(
        height: height,
      );

  static hrtSpace(double width) => SizedBox(
        width: width,
      );
  static const spacer = Spacer();
}
