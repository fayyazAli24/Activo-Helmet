import 'package:flutter/material.dart';
import 'package:unilever_activo/utils/app_colors.dart';

class AppLoader extends StatelessWidget {
  const AppLoader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.primaryColor,
      ),
    );
  }
}
