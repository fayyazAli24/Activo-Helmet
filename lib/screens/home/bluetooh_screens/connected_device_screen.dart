import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:unilever_activo/bloc/cubits/bluetooth_cubits/bluetooth_cubit.dart';
import 'package:unilever_activo/bloc/cubits/bluetooth_cubits/bluetooth_states.dart';
import 'package:unilever_activo/domain/services/helmet_service.dart';
import 'package:unilever_activo/main.dart';
import 'package:unilever_activo/utils/app_colors.dart';
import 'package:unilever_activo/utils/assets.dart';
import 'package:unilever_activo/utils/widgets/app_space.dart';
import 'package:unilever_activo/utils/widgets/app_text.dart';
import 'package:unilever_activo/utils/widgets/global_method.dart';

class BluetoothConnectedScreen extends StatefulWidget {
  const BluetoothConnectedScreen({
    super.key,
    required this.state,
    required this.size,
    required this.deviceName,
  });

  final BluetoothConnectedState state;
  final Size size;
  final String? deviceName;

  @override
  State<BluetoothConnectedScreen> createState() => _BluetoothConnectedScreenState();
}

class _BluetoothConnectedScreenState extends State<BluetoothConnectedScreen> {
  Timer? timer;

  initialization() async {
    try {
      List? res = await di
          .get<HelmetService>()
          .sendData(widget.state.speed, widget.deviceName ?? "", widget.state.batteryPercentage, widget.state.isWore);
      log("$res");

      if (res != null) {
        snackBar("Data Synced Successfully", context);
      } else {
        snackBar("Data Failed To Synced", context);
      }
    } catch (e) {
      log("ex: $e");
      snackBar("Data Failed To Synced", context);
    }
  }

  @override
  void initState() {
    if (mounted) {
      timer = Timer.periodic(Duration(seconds: 15), (timer) async {
        initialization();
        log("** success hit ${widget.state.isWore}");
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () async {
              await context.read<BluetoothCubit>().disconnect();
            },
            child: Lottie.asset(
              AssetsPath.powerOff,
              frameRate: FrameRate.max,
              fit: BoxFit.fill,
              height: widget.size.height * 0.2,
            ),
          ),
          Container(
            width: widget.size.width * 0.3,
            height: 30,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.white),
              color: AppColors.white,
              borderRadius: BorderRadius.circular(5),
            ),
            child: FractionallySizedBox(
              widthFactor: widget.state.batteryPercentage / 100,
              alignment: Alignment.centerLeft,
              child: Container(
                decoration: BoxDecoration(
                  color: widget.state.batteryPercentage / 100 <= 0.2 ? Colors.red : Colors.green,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Center(
                  child: AppText(
                    text: "${widget.state.batteryPercentage}%",
                    color: AppColors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
          AppSpace.vrtSpace(10),
          AppText(
            ///condition inverted
            text: widget.state.isWore == 0 ? "Not Weared" : "Weared",
            color: AppColors.white,
          ),
        ],
      ),
    );
  }
}
