import 'package:flutter/material.dart';

import '../../navigations/app_routes.dart';
import '../../navigations/navigation_helper.dart';
import '../app_colors.dart';
import 'app_space.dart';
import 'app_text.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onOptionsPressed;

  const CustomAppBar({
    Key? key,
    required this.title,
    required this.onOptionsPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      backgroundColor: theme.primaryColor,
      leading: Container(), // This replaces AppSpace.noSpace
      leadingWidth: 0,
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      actions: [
        IconButton(
          onPressed: onOptionsPressed,
          icon: const Icon(
            Icons.more_vert_rounded,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

Future<dynamic> optionsDialogBox(BuildContext context) {
  return showAdaptiveDialog(
    barrierColor: AppColors.black.withOpacity(0.4),
    context: context,
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.only(left: 150),
        child: AlertDialog.adaptive(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          alignment: Alignment.topRight,
          titlePadding: EdgeInsets.zero,
          iconPadding: EdgeInsets.zero,
          actionsPadding: EdgeInsets.zero,
          buttonPadding: EdgeInsets.zero,
          contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
          insetPadding: const EdgeInsets.only(
            right: 10,
            top: kToolbarHeight,
          ),
          content: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () {
                  pop();
                  pushNamed(AppRoutes.deviceHistory);
                },
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: AppText(
                    text: 'Connection History',
                    fontSize: 16,
                    weight: FontWeight.w500,
                  ),
                ),
              ),
              AppSpace.vrtSpace(10),
              InkWell(
                onTap: () {
                  pop();
                  pushNamed(AppRoutes.locationHistory);
                },
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: AppText(
                    text: 'Location History',
                    fontSize: 16,
                    weight: FontWeight.w500,
                  ),
                ),
              ),

              // AppSpace.vrtSpace(10),
              // InkWell(
              //   onTap: () {
              //     pop();
              //     pushNamed(AppRoutes.locationHistory);
              //   },
              //   child: const Padding(
              //     padding: EdgeInsets.all(8.0),
              //     child: AppText(
              //       text: 'Location History',
              //       fontSize: 16,
              //       weight: FontWeight.w500,
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      );
    },
  );
}
