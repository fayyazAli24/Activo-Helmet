import 'dart:async';
import 'dart:developer';

import 'package:alarm/alarm.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location/location.dart';
import 'package:unilever_activo/app/app.dart';
import 'package:unilever_activo/bloc/cubits/alarm_dart_cubit.dart';
import 'package:unilever_activo/bloc/cubits/alarm_dart_state.dart';
import 'package:unilever_activo/bloc/cubits/bluetooth_cubits/bluetooth_cubit.dart';
import 'package:unilever_activo/bloc/cubits/location_cubits/location_cubit.dart';
import 'package:unilever_activo/bloc/states/bluetooth_state/bluetooth_states.dart';
import 'package:unilever_activo/domain/services/helmet_service.dart';
import 'package:unilever_activo/navigations/navigation_helper.dart';
import 'package:unilever_activo/screens/home/bluetooh_screens/connected_device_screen.dart';
import 'package:unilever_activo/screens/home/bluetooh_screens/disconnected_screen.dart';
import 'package:unilever_activo/screens/home/bluetooh_screens/scan_device_screen.dart';
import 'package:unilever_activo/utils/widgets/app_button.dart';
import 'package:unilever_activo/utils/widgets/app_space.dart';
import 'package:unilever_activo/utils/widgets/app_text.dart';
import 'package:unilever_activo/utils/widgets/global_method.dart';

import '../../utils/widgets/custom_app_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  Location location = Location();
  TextEditingController statusDescController = TextEditingController();
  String? selectedReason;
  Timer? timer;
  StreamSubscription<ConnectivityResult>? subscription;
  String? device;

  @override
  void initState() {
    onInit();
  }

  Future<void> onInit() async {
    final bluetoothCubit = context.read<BluetoothCubit>();
    await bluetoothCubit.checkPermissions();
    bluetoothCubit.listenState();
  }

  @override
  void dispose() {
    statusDescController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    return BlocConsumer<AlarmCubit, AlarmState>(
      // do stuff here based on BlocA's state
      listener: (context, state) async {
        if (state is AlarmRingingState) {
          print('state $state');
          final bluetoothState = context.read<BluetoothCubit>();

          /// changed this line

          if (bluetoothState.connectedDevice?.isConnected ?? false) {
            final isStopped = await Alarm.stop(1);
            if (isStopped) {
              manageAlarmTimeAfterBluetooth();
              await manageAlarmTimeAfterBluetooth();
              await setUpNotifications();
              // context.read<AlarmCubit>().setAlarm(appAlarmTime);
              print('alarm stopped');
            }
          } else {
            disconnectedDialog();
            print('alarm stopped');
          }
        }
      },

      // return widget here based on BlocA's state
      builder: (context, state) {
        return BlocListener<LocationCubit, LocationStatus>(
          listener: (context, locationState) {
            if (locationState is LocationOff) {
              final bluetoothState = context.read<BluetoothCubit>().state;
              if (bluetoothState is BluetoothConnectedState) {
                context.read<BluetoothCubit>().disconnectReasonCode = 111;
                context.read<BluetoothCubit>().disconnectDevice(context.read<BluetoothCubit>().disconnectReasonCode);
              }
              locationOffDialog(context);
            }
          },
          child: Scaffold(
            appBar: CustomAppBar(
              title: 'Smart Helmet (Activo)',
              onOptionsPressed: () {
                optionsDialogBox(context);
              },
            ),
            body: SafeArea(
                child: PopScope(
              canPop: false,
              onPopInvoked: (bool didPop) async {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text(
                        'Are you sure you want to exit',
                        style: TextStyle(fontSize: 17),
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            height: 5,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: 3,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 150),
                                  child: InkWell(
                                    onTap: () async {
                                      Navigator.of(context).pop(); // Close the dialog box

                                      context.read<BluetoothCubit>().disconnectReasonCode = 666;
                                      await context
                                          .read<BluetoothCubit>()
                                          .disconnectDevice(context.read<BluetoothCubit>().disconnectReasonCode);

                                      Future.delayed(Duration.zero, () => SystemNavigator.pop());
                                    },
                                    child: const Text(
                                      'Yes',
                                      style: TextStyle(color: Colors.teal, fontSize: 14),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 25.0),
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.of(context).pop(); // Close the dialog box
                                    },
                                    child: const Text(
                                      'No',
                                      style: TextStyle(color: Colors.teal, fontSize: 14),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                    );
                  },
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.background,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  children: [
                    AppSpace.vrtSpace(10),
                    BlocConsumer<BluetoothCubit, AppBluetoothState>(
                      builder: (context, state) {
                        log('state $state');
                        if (state is BluetoothStateOff) {
                          print('this state is true');
                          return BluetoothOffScreen(
                            size: size,
                          );
                        } else if (state is BluetoothConnectedState) {
                          return BluetoothConnectedScreen(
                            state: state,
                            deviceName: state.deviceName,
                            size: size,
                          );
                        } else {
                          return BluetoothScanDeviceScreen(
                            theme: theme,
                            size: size,
                          );
                        }
                      },
                      listener: (context, state) async {
                        if (state is BluetoothScannedState) {
                          // print('starting the scan in home screen');
                          // context.read<BluetoothCubit>().getDevices();
                        }
                        if (state is BluetoothStateOff) {
                          snackBar('Bluetooth is turned off', context);
                        } else if (state is BluetoothStateOn) {
                          snackBar('Bluetooth is turned on', context);
                        } else if (state is BluetoothFailedState) {
                          noDeviceFoundDialog(state);

                          await context.read<BluetoothCubit>().getDevices();
                        } else if (state is AutoDisconnectedState) {
                          stopAlarmDialog();
                          print('get device is called before');
                          snackBar('Device Disconnected', context);
                        }
                        if (state is BluetoothConnectingState) {
                          connectingDialog();
                        }
                      },
                    ),
                  ],
                ),
              ),
            )),
          ),
        );
      },
    );
  }

  Future<dynamic> disconnectedDialog() {
    return showAdaptiveDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (BuildContext context, Function(void Function()) setState) {
          return AlertDialog.adaptive(
            scrollable: true,
            content: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const AppText(
                      text: 'Status Description',
                      weight: FontWeight.w500,
                    ),
                    AppSpace.vrtSpace(5),
                    StatusDescTextField(),
                    AppSpace.vrtSpace(5),
                    ...['Internet', 'User Disconnect', 'Helmet', 'Bluetooth', 'Other']
                        .map(
                          (e) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              RadioListTile<String>(
                                contentPadding: const EdgeInsets.symmetric(vertical: 4),
                                dense: true,
                                value: e,
                                title: AppText(
                                  text: e,
                                ),
                                groupValue: selectedReason,
                                onChanged: (value) {
                                  setState(() {
                                    selectedReason = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        )
                        .toList()
                  ],
                ),
              ),
            ),
            actions: [
              AppButton(
                child: const AppText(
                  text: 'Submit',
                ),
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    try {
                      if (selectedReason == null) {
                        return invalidDialog();
                      }
                      final device = await context.read<BluetoothCubit>().checkSavedDevice();

                      await di
                          .get<HelmetService>()
                          .disconnectingReason(device ?? '', selectedReason ?? '', statusDescController.text);

                      manageAlarm();
                      selectedReason = null;
                      statusDescController.clear();
                      pop();
                      log('popped popped');
                    } catch (e) {
                      log('alarm Exc: $e ');
                      pop();
                    }
                  }
                },
              )
            ],
            title: const Center(
              child: AppText(
                text: 'Helmet Disconnected!',
                weight: FontWeight.w500,
                fontSize: 18,
              ),
            ),
          );
        });
      },
    );
  }

  TextFormField StatusDescTextField() {
    return TextFormField(
      decoration: const InputDecoration(hintText: 'Description'),
      controller: statusDescController,
      validator: (value) {
        return value == null || value.isEmpty ? "Field can't be empty" : null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
      onTapOutside: (event) {
        final focus = FocusScope.of(context);
        focus.unfocus();
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
                  await BlocProvider.of<BluetoothCubit>(context).audioPlayer.stop();
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

  Future<dynamic> invalidDialog() {
    return showAdaptiveDialog(
      context: context,
      builder: (context) {
        return AlertDialog.adaptive(
          title: const Center(
            child: AppText(
              text: 'Please select a reason',
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

  Future<void> manageAlarm() async {
    context.read<AlarmCubit>().stopAlarm();
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

  Future<dynamic> locationOffDialog(BuildContext context) {
    print("from home screen");
    return showAdaptiveDialog(
      context: context,
      builder: (context) {
        return AlertDialog.adaptive(
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            ElevatedButton(
              onPressed: () {
                pop();
              },
              child: const AppText(text: 'Close'),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<LocationCubit>().openSettings();
              },
              child: const AppText(text: 'Settings'),
            ),
          ],
          title: const AppText(
            text: 'Location is closed please open settings to turn on location',
          ),
        );
      },
    );
  }
}
