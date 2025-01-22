import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:unilever_activo/bloc/cubits/timer_cubit/timer_cubit.dart';
import 'package:unilever_activo/bloc/states/bluetooth_state/bluetooth_states.dart';
import 'package:unilever_activo/utils/app_colors.dart';
import 'package:unilever_activo/utils/assets.dart';
import 'package:unilever_activo/utils/widgets/app_space.dart';
import 'package:unilever_activo/utils/widgets/app_text.dart';
import 'package:unilever_activo/utils/widgets/global_method.dart';

import '../../../app/app.dart';
import '../../../bloc/cubits/bluetooth_cubits/bluetooth_cubit.dart';
import '../../../domain/services/helmet_service.dart';

class BluetoothConnectedScreen extends StatefulWidget {
  final BluetoothConnectedState state;
  final Size size;
  final String? deviceName;

  const BluetoothConnectedScreen({
    super.key,
    required this.state,
    required this.size,
    required this.deviceName,
  });

  @override
  State<BluetoothConnectedScreen> createState() => _BluetoothConnectedScreenState();
}

class _BluetoothConnectedScreenState extends State<BluetoothConnectedScreen> with WidgetsBindingObserver {
  Timer? timer;
  Timer? counter;
  late DateTime connectedTime;

  Future<void> initialization() async {
    try {
      if (!mounted) return;

      List? res = await di.get<HelmetService>().sendData(widget.deviceName ?? '', widget.state.batteryPercentage,
          widget.state.isWore, widget.state.cheek, DateTime.now(), DateTime.now());

      // if (help.prevSpeed == 0) return;

      if (res != null) {
        print('successfully synced shukr');
        snackBar('Data Synced Successfully', context);
      } else {
        snackBar('Data Failed To Synced', context);
      }
    } catch (e) {
      if (!mounted) return;

      print('ex: $e');

      snackBar('Data Failed To Synced', context);
    }
  }

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addObserver(this);
    connectedTime = DateTime.now();
    context.read<TimerCubit>().updateTimer(connectedTime);

    counter = Timer.periodic(const Duration(seconds: 1), (value) {
      context.read<TimerCubit>().updateTimer(connectedTime);
    });

    initialization();
    timer = Timer.periodic(const Duration(seconds: 15), (timer) async {
      var device = context.read<BluetoothCubit>().connectedDevice;
      if (device != null) {
        print('calling from init');
        await initialization();
      }
    });
  }

  @override
  void dispose() {
    // WidgetsBinding.instance.removeObserver(this);
    timer?.cancel();
    counter?.cancel();
    connectedTime = DateTime.now();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () async {
              context.read<BluetoothCubit>().disconnectReasonCode = 555;

              await context
                  .read<BluetoothCubit>()
                  .disconnectDevice(context.read<BluetoothCubit>().disconnectReasonCode);

              ///User Disconnect
            },
            child: Lottie.asset(
              AssetsPath.powerOff,
              frameRate: FrameRate.max,
              fit: BoxFit.fill,
              height: widget.size.height * 0.2,
            ),
          ),
          BlocConsumer<TimerCubit, TimerState>(
            builder: (context, state) {
              if (state is TimerCountingState) {
                return AppText(
                  text: '${state.connectedTime}',
                  weight: FontWeight.w500,
                );
              }
              return const AppText(text: '0:00:00:00', weight: FontWeight.w500);
            },
            listener: (context, state) {},
          ),
          AppSpace.vrtSpace(5),
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
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.center,
                  child: AppText(
                    text: '${widget.state.batteryPercentage.toInt()}%',
                    color: AppColors.white,
                    fontSize: 12,
                    textAlign: TextAlign.center,
                    weight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          AppSpace.vrtSpace(10),
          AppText(
            ///condition inverted
            text: (widget.state.isWore == 1 || widget.state.cheek == 1) ? 'Weared' : 'Not Weared',
            weight: FontWeight.w500,
            color: theme.textTheme.bodyLarge?.color,
          ),
          // AppSpace.vrtSpace(10),
          // AppText(
          //   ///condition inverted
          //   text: widget.state.count.toString(),
          //   weight: FontWeight.w500,
          //   color: theme.textTheme.bodyLarge?.color,
          // ),
        ],
      ),
    );
  }
}
