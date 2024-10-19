import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:unilever_activo/bloc/states/bluetooth_state/bluetooth_states.dart';

import '../../../../app/app.dart';
import '../../../../bloc/cubits/bluetooth_cubits/bluetooth_cubit.dart';
import '../../../../bloc/cubits/location_cubits/location_cubit.dart';
import '../../../../bloc/cubits/timer_cubit/timer_cubit.dart';
import '../../../../domain/services/helmet_service.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/widgets/app_text.dart';
import '../../../../utils/widgets/global_method.dart';

class HelmetConnectedScreen extends StatefulWidget {
  BluetoothConnectedState state;
  final String? deviceName;
  HelmetConnectedScreen({
    super.key,
    required this.state,
    required this.deviceName,
  });

  @override
  State<HelmetConnectedScreen> createState() => _HelmetConnectedScreenState();
}

class _HelmetConnectedScreenState extends State<HelmetConnectedScreen> {
  Timer? timer;
  Timer? counter;
  late DateTime connectedTime;

  Future<void> initialization() async {
    try {
      if (!mounted) return;

      List? res = await di
          .get<HelmetService>()
          .sendData(widget.deviceName ?? '', widget.state.batteryPercentage, widget.state.isWore, widget.state.cheek);

      // if (help.prevSpeed == 0) return;

      print('testing  the response $res');
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
    double batteryPercentage = 100.0;
    return Container(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12.0, bottom: 5),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Connected to ${widget.state.deviceName}',
                style: const TextStyle(color: Colors.black, fontSize: 16),
              ),
            ),
          ),
          const Divider(),
          SizedBox(
            height: 2.5.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Container(
                    width: 17.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: batteryPercentage <= 20 ? Colors.red : AppColors.test2,
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
                  SizedBox(
                    height: 1.h,
                  ),
                  Text(
                    'Battery',
                    style: TextStyle(color: Colors.grey.shade700),
                  )
                ],
              ),
              Column(
                children: [
                  Icon(
                    Icons.headphones,
                    color: (widget.state.isWore == 1 || widget.state.cheek == 1) ? AppColors.test2 : Colors.grey,
                    size: 40,
                  ),
                  SizedBox(
                    height: 1.h,
                  ),
                  AppText(

                      ///condition inverted
                      text: (widget.state.isWore == 1 || widget.state.cheek == 1) ? 'Weared' : 'Not Weared',
                      weight: FontWeight.w500,
                      color: (widget.state.isWore == 1 || widget.state.cheek == 1)
                          ? AppColors.test2
                          : Colors.grey.shade700),
                ],
              ),
              Column(
                children: [
                  BlocBuilder<LocationCubit, LocationStatus>(
                    builder: (context, locationState) {
                      if (locationState is LocationOff) {
                        return Column(children: [
                          Icon(
                            Icons.location_on,
                            color: Colors.grey.shade700,
                            size: 40,
                          ),
                          SizedBox(
                            height: 1.h,
                          ),
                          Text(
                            "Location off",
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                        ]);
                      } else {
                        return Column(children: [
                          const Icon(
                            Icons.location_on,
                            color: AppColors.test2,
                            size: 40,
                          ),
                          SizedBox(
                            height: 1.h,
                          ),
                          const Text(
                            "Location on",
                            style: TextStyle(color: AppColors.test2),
                          ),
                        ]);
                      }
                    },
                  )
                ],
              )
            ],
          ),
          SizedBox(
            height: 2.5.h,
          ),
          const Divider(),
          SizedBox(
            height: 2.5.h,
          ),
          BlocConsumer<TimerCubit, TimerState>(
            builder: (context, state) {
              if (state is TimerCountingState) {
                return Column(
                  children: [
                    AppText(
                      text: 'Connection Time:',
                      weight: FontWeight.w500,
                      color: Colors.grey.shade700,
                      fontSize: 18,
                    ),
                    SizedBox(
                      height: 1.h,
                    ),
                    AppText(
                      text: '${state.connectedTime}',
                      weight: FontWeight.w500,
                      fontSize: 18,
                      color: Colors.grey.shade700,
                    ),
                  ],
                );
              }
              return const AppText(text: '0:00:00:00', weight: FontWeight.w500);
            },
            listener: (context, state) {},
          ),
        ],
      ),
    );
  }
}
