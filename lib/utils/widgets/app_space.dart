import 'package:flutter/material.dart';

class AppSpace {
  static const noSpace = SizedBox.shrink();

  static SizedBox vrtSpace(double height) => SizedBox(
        height: height,
      );

  static SizedBox hrtSpace(double width) => SizedBox(
        width: width,
      );
  static const spacer = Spacer();
}
