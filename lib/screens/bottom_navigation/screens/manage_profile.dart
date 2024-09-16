import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ManageProfile extends StatelessWidget {
  const ManageProfile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: Get.height * 0.28,
          child: Container(
            width: 100.w,
            height: 70.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4), // Shadow color with opacity
                  spreadRadius: 2, // How far the shadow spreads
                  blurRadius: 5, // Blur effect of the shadow
                  offset: const Offset(0, 4), // Position of the shadow (horizontal and vertical)
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
