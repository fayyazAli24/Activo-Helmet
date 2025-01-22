
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';


import '../../../utils/app_colors.dart';
import '../../../utils/widgets/indicator.dart';

class Stats extends StatefulWidget {
  const Stats({Key? key}) : super(key: key);

  @override
  State<Stats> createState() => _StatsState();
}

class _StatsState extends State<Stats> {
  @override
  List<Color> gradientColors = [
    AppColors.contentColorCyan,
    AppColors.contentColorBlue,
  ];

  bool showAvg = false;
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned(
          top: 0, // Position at the top
          child: Container(
            width: 100.w,
            height: 35.h,
            color: AppColors.white,
            // Occupies 30% of the height
            child: Column(
              children: [
                SizedBox(
                  height: 2.5.h,
                ),
                const Text(
                  "Riders journey summary",
                  style: TextStyle(color: Colors.black, fontSize: 18),
                ),
              ],
            ),
          ),
        ),

      ],
    );
  }
}
