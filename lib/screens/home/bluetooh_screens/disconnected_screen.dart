import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:unilever_activo/utils/assets.dart';

class BluetoothOffScreen extends StatelessWidget {
  const BluetoothOffScreen({
    super.key,
    required this.size,
  });

  final Size size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Lottie.asset(
        AssetsPath.powerOn,
        frameRate: FrameRate.max,
        fit: BoxFit.fill,
        height: size.height * 0.2,
      ),
    );
  }
}
