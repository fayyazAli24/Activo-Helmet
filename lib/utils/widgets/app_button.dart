import 'package:flutter/material.dart';
import 'package:unilever_activo/navigations/navigation_helper.dart';
import 'package:unilever_activo/utils/app_colors.dart';
import 'package:unilever_activo/utils/widgets/app_text.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    required this.onPressed,
    this.backgroundColor,
    this.child,
    super.key,
  });

  final Function()? onPressed;
  final Color? backgroundColor;
  final Widget? child;
  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
        ),
        onPressed: onPressed ??
            () {
              pop();
            },
        child: child ??
            const AppText(
              text: 'OK',
              color: AppColors.white,
            ),
      ),
    );
  }
}
