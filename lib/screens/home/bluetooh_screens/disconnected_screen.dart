import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:unilever_activo/bloc/cubits/bluetooth_cubits/bluetooth_cubit.dart';
import 'package:unilever_activo/utils/assets.dart';

class BluetoothOffScreen extends StatelessWidget {
  const BluetoothOffScreen({
    super.key,
    required this.size,
  });

  final Size size;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        await context.read<BluetoothCubit>().turnOn();
      },
      child: Center(
        child: Lottie.asset(
          AssetsPath.powerOn,
          frameRate: FrameRate.max,
          fit: BoxFit.fill,
          height: size.height * 0.2,
        ),
      ),
    );
  }
}
