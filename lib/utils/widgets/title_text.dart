import 'package:flutter/material.dart';

class TitleText extends StatelessWidget {
  final String title;
  final TextStyle? style;
  final double? fontSize;
  final FontWeight? weight;
  final Color? color;
  final TextAlign? textAlign;
  final bool? isUnderLine;

  TitleText({
    Key? key,
    required this.title,
    this.style,
    this.fontSize,
    this.weight,
    this.color,
    this.isUnderLine,
    this.textAlign,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(title, textAlign: textAlign, style: TextStyle(fontSize: fontSize, fontWeight: weight, color: color));
  }
}
