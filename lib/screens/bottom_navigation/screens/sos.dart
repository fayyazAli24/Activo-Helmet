import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../../utils/app_colors.dart';

class SOS extends StatelessWidget {
  const SOS({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          SizedBox(
            height: 10.h,
          ),
          const CircleAvatar(
            backgroundColor: Colors.redAccent,
            radius: 50,
            child: Center(child: Text(style: TextStyle(fontSize: 20, color: Colors.white), "SOS")),
          ),
          SizedBox(
            height: 3.h,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Container(
              width: 100.w,
              height: 50.h,
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
              child: Column(
                children: [
                  SizedBox(
                    height: 2.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        "Add a Contact for SOS signal",
                        style: TextStyle(fontSize: 18, color: Colors.grey.shade700, fontWeight: FontWeight.bold),
                      ),
                      const CircleAvatar(
                        backgroundColor: AppColors.test4,
                        child: Icon(Icons.add),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 1.3.h,
                  ),
                  const Divider(),
                  SizedBox(
                    height: 10.h,
                  ),
                  Container(
                    width: 55.w,
                    height: 7.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2), // Shadow color with opacity
                          spreadRadius: 2, // How far the shadow spreads
                          blurRadius: 5, // Blur effect of the shadow
                          offset: const Offset(0, 4), // Position of the shadow (horizontal and vertical)
                        ),
                      ],
                    ),
                    child: const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Center(
                                child: Text(
                                  "Samar Ali",
                                  style: TextStyle(color: Colors.black38, fontSize: 16),
                                ),
                              ),
                              Center(
                                child: Text(
                                  "+92 3303150276",
                                  style: TextStyle(color: Colors.black38, fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Icon(
                            Icons.edit,
                            color: Colors.black,
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
