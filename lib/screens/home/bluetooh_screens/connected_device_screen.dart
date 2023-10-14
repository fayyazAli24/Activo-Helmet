import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:unilever_activo/bloc/cubits/bluetooth_cubits/bluetooth_cubit.dart';
import 'package:unilever_activo/utils/app_colors.dart';
import 'package:unilever_activo/utils/assets.dart';
import 'package:unilever_activo/utils/widgets/app_space.dart';
import 'package:unilever_activo/utils/widgets/app_text.dart';

class BluetoothConnectedScreen extends StatelessWidget {
  const BluetoothConnectedScreen({
    super.key,
    required this.newCubit,
    required this.size,
    required this.batterPer,
  });

  final BluetoothCubit newCubit;
  final Size size;
  final double batterPer;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () async {
              await newCubit.disconnect();
            },
            child: Lottie.asset(
              AssetsPath.powerOff,
              frameRate: FrameRate.max,
              fit: BoxFit.fill,
              height: size.height * 0.2,
            ),
          ),
          Container(
            width: size.width * 0.3,
            height: 30,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.white),
              color: AppColors.white,
              borderRadius: BorderRadius.circular(5),
            ),
            child: FractionallySizedBox(
              widthFactor: batterPer,
              alignment: Alignment.centerLeft,
              child: Container(
                decoration: BoxDecoration(
                  color: batterPer <= 0.2 ? Colors.red : Colors.green,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Center(
                  child: AppText(
                    text: "${newCubit.batteryPercentage ?? "0"}%",
                    color: AppColors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
          AppSpace.vrtSpace(10),
          AppText(
            text: newCubit.isWore > 0 ? "Not Weared" : "Weared",
            color: AppColors.white,
          ),
        ],
      ),
    );
  }
}
