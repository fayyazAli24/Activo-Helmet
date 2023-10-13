import 'package:flutter/material.dart';
import 'package:unilever_activo/utils/widgets/app_text.dart';

snackBar(String msg, BuildContext context, {Color? color, Color? textColor}) {
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
