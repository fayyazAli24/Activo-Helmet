import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:unilever_activo/bloc/cubits/switch_cubit/bluetooth_switch.dart';
import 'package:unilever_activo/screens/bottom_navigation/screens/connected_sub_screens/helmet_connected_screen.dart';
import 'package:unilever_activo/screens/bottom_navigation/screens/connected_sub_screens/helmet_scanning_screen.dart';
import '../../../bloc/cubits/bluetooth_cubits/bluetooth_cubit.dart';
import '../../../bloc/cubits/switch_cubit/switch_cubit.dart';
import '../../../bloc/states/bluetooth_state/bluetooth_states.dart';
import '../../../domain/services/accident_detect.dart';
import '../../../navigations/navigation_helper.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/widgets/app_space.dart';
import '../../../utils/widgets/app_text.dart';
import '../../../utils/widgets/global_method.dart';

class HelmetConnected extends StatefulWidget {
  var counter;
  HelmetConnected({Key? key, this.counter}) : super(key: key);
  @override
  State<HelmetConnected> createState() => _HelmetConnectedState();
}

class _HelmetConnectedState extends State<HelmetConnected>
    with WidgetsBindingObserver {
  StreamSubscription? _subscription;
  String status = 'Listening...';

  Future<void> initialization() async {
    context.read<BluetoothCubit>().autoConnected =
        await context.read<SwitchCubit>().initialValue();
    print('in init of scan ${context.read<BluetoothCubit>().autoConnected}');
  }

  @override
  void initState() {
    // TODO: implement initState
    initialization();
    AccidentDetectionService().listenToAccelerometer(context);

    super.initState();
  }
  //
  // @override
  // Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
  //   super.didChangeAppLifecycleState(state);
  //
  //   // Handle lifecycle events for each Bloc
  //   switch (state) {
  //     case AppLifecycleState.resumed:
  //       AccidentDetectionService().listenToAccelerometer();
  //
  //       break;
  //     case AppLifecycleState.inactive:
  //       AccidentDetectionService().listenToAccelerometer();
  //
  //       break;
  //     case AppLifecycleState.paused:
  //       AccidentDetectionService().listenToAccelerometer();
  //
  //       break;
  //     case AppLifecycleState.detached:
  //       AccidentDetectionService().listenToAccelerometer();
  //
  //       break;
  //     case AppLifecycleState.hidden:
  //       AccidentDetectionService().listenToAccelerometer();
  //
  //     // TODO: Handle this case.
  //   }
  // }

  bool permissionGranted = false;

  double batteryPercentage = 100.0;
  String helmetName = 'Activo Helmet 13314580';
  String message = 'This is a test message!';
  List<String> recipents = ['03128779067'];
  Location location = Location();
  String address = '03128779067';
  var falseCase;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 0,
          child: Container(
            width: 100.w,
            height: 25.h,
            color: AppColors.test3,
            child: Column(
              children: [
                const SizedBox(
                  height: 15,
                ),
                InkWell(
                  onTap: () async {
                    // AccidentDetectionService().accidentAlert(context);
                  },
                  child: CircleAvatar(
                    backgroundColor: Colors.grey,
                    radius: 40,
                    child: Text(
                        context.read<BluetoothCubit>().email?.substring(0, 2) ??
                            'FA'),
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Text(context.read<BluetoothCubit>().email ?? 'User'),
                const SizedBox(
                  height: 2,
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: 20,
          bottom: Get.height * 0.55,
          child: Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Container(
              width: 90.w,
              height: 8.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withOpacity(0.2), // Shadow color with opacity
                    spreadRadius: 2, // How far the shadow spreads
                    blurRadius: 5, // Blur effect of the shadow
                    offset: const Offset(0,
                        4), // Position of the shadow (horizontal and vertical)
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () async {
                        // await context.read<BluetoothCubit>().getDevices();
                        // print('the length after getting is ${context.read<BluetoothCubit>().scannedDevices.length}');
                        // var temp = await context.read<BluetoothCubit>().search(helmetName);
                        // if (temp != null) {
                        //   await context.read<BluetoothCubit>().connect(temp);
                        // }
                      },
                      child: BlocBuilder<BluetoothCubit, AppBluetoothState>(
                        builder:
                            (BuildContext context, AppBluetoothState state) {
                          if (state is BluetoothConnectedState) {
                            return InkWell(
                              onTap: () async {
                                context
                                    .read<BluetoothCubit>()
                                    .disconnectReasonCode = 555;
                                await context
                                    .read<BluetoothCubit>()
                                    .disconnectDevice(context
                                        .read<BluetoothCubit>()
                                        .disconnectReasonCode);
                              },
                              child: const CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.redAccent,
                                child: Icon(
                                  size: 30,
                                  Icons.power_settings_new,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          } else if (state is BluetoothScannedState) {
                            return InkWell(
                              onTap: () {
                                context.read<BluetoothCubit>().getDevices();
                              },
                              child: const CircleAvatar(
                                radius: 20,
                                backgroundColor: AppColors.test2,
                                child: Icon(
                                  size: 30,
                                  Icons.refresh,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          } else {
                            return InkWell(
                              onTap: () {
                                context.read<BluetoothCubit>().getDevices();
                              },
                              child: const CircleAvatar(
                                radius: 20,
                                backgroundColor: AppColors.test2,
                                child: Icon(
                                  size: 30,
                                  Icons.refresh,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    const VerticalDivider(),
                    const SizedBox(
                      width: 20,
                    ),
                    const Text(
                      'Enable auto connect',
                      style: TextStyle(color: Colors.black38, fontSize: 16),
                    ),
                    const SizedBox(width: 20),
                    BlocConsumer<SwitchCubit, bool>(
                      listener: (context, state) {},
                      builder: (context, state) {
                        return Switch.adaptive(
                          inactiveTrackColor: Colors.white38,
                          activeTrackColor: AppColors.test4,
                          activeColor: Colors.white,
                          value: state,
                          onChanged: (value) {
                            context.read<BluetoothCubit>().autoConnected =
                                value;
                            context
                                .read<BluetoothCubit>()
                                .disconnectReasonCode = 0;
                            context.read<SwitchCubit>().updateValue(value);
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 37,
          top: Get.height * 0.30,
          // bottom: 30,
          child: Container(
              width: 80.w,
              height: 80.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withOpacity(0.2), // Shadow color with opacity
                    spreadRadius: 2, // How far the shadow spreads
                    blurRadius: 8, // Blur effect of the shadow
                    offset: const Offset(0,
                        4), // Position of the shadow (horizontal and vertical)
                  ),
                ],
              ),
              child: BlocConsumer<BluetoothCubit, AppBluetoothState>(
                listener: (context, bluetoothState) async {
                  if (bluetoothState is BluetoothStateOff) {
                    snackBar('Bluetooth is turned off', context);
                  } else if (bluetoothState is BluetoothStateOn) {
                    snackBar('Bluetooth is turned on', context);
                  } else if (bluetoothState is BluetoothFailedState) {
                    print('////////////////////');
                    noDeviceFoundDialog(bluetoothState);

                    await Future.delayed(const Duration(seconds: 5));
                    await context.read<BluetoothCubit>().getDevices();
                    // await context.read<BluetoothCubit>().getDevices();

                    await context.read<BluetoothCubit>().getDevices();
                  } else if (bluetoothState is AutoDisconnectedState) {
                    stopAlarmDialog();
                    print('get device is called before');
                    snackBar('Device Disconnected', context);
                  }
                  if (bluetoothState is BluetoothConnectingState) {
                    connectingDialog();
                  }
                },
                builder: (context, bluetoothState) {
                  return SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 3.h,
                        ),
                        Container(
                          width: 75.w,
                          height: 6.5.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(
                                    0.2), // Shadow color with opacity
                                spreadRadius: 2, // How far the shadow spreads
                                blurRadius: 5, // Blur effect of the shadow
                                offset: const Offset(0,
                                    4), // Position of the shadow (horizontal and vertical)
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const SizedBox(
                                width: 20,
                              ),
                              const Text(
                                'Enable Bluetooth',
                                style: TextStyle(
                                    color: Colors.black38, fontSize: 16),
                              ),
                              const SizedBox(width: 65),
                              BlocConsumer<BluetoothSwitch, bool>(
                                listener: (context, state) {},
                                builder: (context, state) {
                                  return Switch.adaptive(
                                    inactiveTrackColor: Colors.white38,
                                    activeTrackColor: AppColors.test4,
                                    activeColor: Colors.white,
                                    value: state,
                                    onChanged: (value) async {
                                      print('the initial value is $state');
                                      context
                                          .read<BluetoothSwitch>()
                                          .updateValue(value);
                                      if (state == false) {
                                        await context
                                            .read<BluetoothCubit>()
                                            .turnOn();
                                        await context
                                            .read<BluetoothCubit>()
                                            .getDevices();
                                      } else {
                                        await FlutterBluePlus.turnOff();
                                      }
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 3.h,
                        ),
                        bluetoothState is BluetoothScannedState
                            ? HelmetScanningScreen(
                                bluetoothState: bluetoothState)
                            : bluetoothState is BluetoothConnectedState
                                ? HelmetConnectedScreen(
                                    state: bluetoothState,
                                    deviceName: bluetoothState.deviceName)
                                : AppSpace.noSpace
                      ],
                    ),
                  );
                },
              )),
        ),
      ],
    );
  }

  Future<dynamic> connectingDialog() {
    return showAdaptiveDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return const PopScope(
          canPop: false,
          child: AlertDialog.adaptive(
            title: AppText(
              text: 'connecting..',
            ),
          ),
        );
      },
    );
  }

  Future<dynamic> noDeviceFoundDialog(BluetoothFailedState state) {
    return showAdaptiveDialog(
      context: context,
      builder: (context) {
        return AlertDialog.adaptive(
          title: Center(
            child: AppText(
              text: '${state.message}',
              weight: FontWeight.w500,
            ),
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  pop();
                },
                child: const Center(child: AppText(text: 'Close')),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<dynamic> stopAlarmDialog() {
    return showAdaptiveDialog(
      context: context,
      builder: (context) {
        return AlertDialog.adaptive(
          title: const Center(
            child: AppText(
              text: 'Helmet Disconnected',
              weight: FontWeight.w500,
            ),
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  await BlocProvider.of<BluetoothCubit>(context)
                      .audioPlayer
                      .stop();
                  pop();
                },
                child: const Center(child: AppText(text: 'Close')),
              ),
            ),
          ],
        );
      },
    );
  }

  dynamic dialog([String? title, VoidCallback? tap]) {
    return PopScope(
      canPop: false,
      child: AlertDialog.adaptive(
        title: Column(
          children: [
            AppText(
              text: title ?? 'Default Title', // Handle null title
              fontSize: 16,
            ),
            const SizedBox(
              height: 20,
            ),
            InkWell(
              onTap: tap ??
                  () {
                    pop(); // Call the provided tap or pop if none is given
                  },
              child: const Text(
                'Cancel',
                style: TextStyle(fontSize: 14),
              ),
            )
          ],
        ),
      ),
    );
  }
}
