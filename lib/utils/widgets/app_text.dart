import 'package:flutter/material.dart';


class AppText extends StatelessWidget {
  const AppText({required this.text, this.fontSize, this.textAlign, this.color, this.weight, super.key});
  final String text;
  final Color? color;
  final double? fontSize;
  final FontWeight? weight;
  final TextAlign? textAlign;
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: TextStyle(
        color: color ?? Theme.of(context).textTheme.bodyLarge?.color,
        fontSize: fontSize ?? 14,
        fontWeight: weight,
      ),
    );
  }
}
