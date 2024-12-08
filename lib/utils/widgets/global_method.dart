import 'package:flutter/material.dart';
import 'package:unilever_activo/utils/widgets/app_text.dart';

DateTime appAlarmTime = DateTime(
    2030, // Year
    DateTime.now().month, // Current month
    DateTime.now().day, // Current day
    DateTime.now().hour, // Current hour
    DateTime.now().minute, // Current minute
    DateTime.now().second, // Current second
    DateTime.now().millisecond, // Current millisecond
    DateTime.now().microsecond // Current microsecond
    );
void snackBar(String msg, BuildContext context, {Color? color, Color? textColor}) {
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: color ?? Theme.of(context).colorScheme.background,
      content: AppText(
        text: msg,
        color: textColor ?? Theme.of(context).textTheme.bodyLarge?.color,
      ),
    ),
  );
}
