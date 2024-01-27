import 'dart:async';
import 'dart:developer';

import 'package:alarm/alarm.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unilever_activo/app/app.dart';
import 'package:unilever_activo/bloc/cubits/alarm_dart_cubit.dart';
import 'package:unilever_activo/bloc/cubits/alarm_dart_state.dart';
import 'package:unilever_activo/bloc/cubits/bluetooth_cubits/bluetooth_cubit.dart';
import 'package:unilever_activo/bloc/cubits/location_cubits/location_cubit.dart';
import 'package:unilever_activo/bloc/states/bluetooth_state/bluetooth_states.dart';
import 'package:unilever_activo/domain/services/helmet_service.dart';
import 'package:unilever_activo/navigations/app_routes.dart';
import 'package:unilever_activo/navigations/navigation_helper.dart';
import 'package:unilever_activo/screens/home/bluetooh_screens/connected_device_screen.dart';
import 'package:unilever_activo/screens/home/bluetooh_screens/disconnected_screen.dart';
import 'package:unilever_activo/screens/home/bluetooh_screens/scan_device_screen.dart';
import 'package:unilever_activo/utils/app_colors.dart';
import 'package:unilever_activo/utils/widgets/app_button.dart';
import 'package:unilever_activo/utils/widgets/app_space.dart';
import 'package:unilever_activo/utils/widgets/app_text.dart';
import 'package:unilever_activo/utils/widgets/global_method.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController statusDescController = TextEditingController();
  String? selectedReason;
  Timer? timer;
  StreamSubscription<ConnectivityResult>? subscription;

  /// made by fayyaz for testing purpose
  // Future<void> initialization() async {
  //   try {
  //     if (!mounted) return;
  //
  //     final connection = await Connectivity().checkConnectivity();
  //     if (connection == ConnectivityResult.none) {
  //       print('internet issue');
  //       return;
  //     } else {
  //       List? res = await di
  //           .get<HelmetService>().syncUnsyncedData();
  //
  //       if (res != null) {
  //         snackBar('Data Synced Successfully', context,color: Colors.green,textColor: Colors.green);
  //       } else {
  //         print('empty');
  //         return;
  //
  //       }
  //     }
  //   }
  //   catch (e) {
  //     if (!mounted) return;
  //     print('ex: $e');
  //     return;
  //   }
  // }

  @override
  void initState() {
    final bluetoothCubit = context.read<BluetoothCubit>();
    bluetoothCubit.checkPermissions();
    bluetoothCubit.checkStatus();
    bluetoothCubit.listenState();



    // timer = Timer.periodic(const Duration(seconds: 15), (timer) async {
    //   await initialization();
    // });

    super.initState();
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
          if (bluetoothState.connection?.isConnected ?? false) {
            final isStopped = await Alarm.stop(1);
            if (isStopped) {
              await manageAlarmTimeAfterBluetooth();
              await setUpNotifications();
              context.read<AlarmCubit>().setAlarm(appAlarmTime);
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
                context.read<LocationCubit>().deviceName =
                    bluetoothState.deviceName;
              }
              locationOffDialog(context);
            }
          },
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: theme.appBarTheme.backgroundColor,
              leading: AppSpace.noSpace,
              leadingWidth: 0,
              title: const AppText(
                text: 'Smart Helmet (Activo)',
                fontSize: 18,
                color: AppColors.white,
                weight: FontWeight.w500,
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    optionsDialogBox();
                  },
                  icon: const Icon(
                    Icons.more_vert_rounded,
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
            body: SafeArea(
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
                        if (state is BluetoothStateOff) {
                          return BluetoothOffScreen(
                            size: size,
                          );
                        } else if (state is BluetoothConnectedState) {
                          return BluetoothConnectedScreen(
                            state: state,
                            deviceName: state.deviceName,
                            size: size,
                          );
                        }
                        return BluetoothScanDeviceScreen(
                          theme: theme,
                          size: size,
                        );
                      },
                      listener: (context, state) {
                        if (state is BluetoothStateOff) {
                          snackBar('Bluetooth is turned off', context);
                        } else if (state is BluetoothFailedState) {
                          noDeviceFoundDialog(state);
                        } else if (state is AutoDisconnectedState) {
                          stopAlarmDialog();
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
            ),
          ),
        );
      },
    );
  }

  Future<dynamic> optionsDialogBox() {
    return showAdaptiveDialog(
      barrierColor: AppColors.black.withOpacity(0.4),
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.only(left: 150),
          child: AlertDialog.adaptive(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            alignment: Alignment.topRight,
            titlePadding: EdgeInsets.zero,
            iconPadding: EdgeInsets.zero,
            actionsPadding: EdgeInsets.zero,
            buttonPadding: EdgeInsets.zero,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
            insetPadding: const EdgeInsets.only(
              right: 10,
              top: kToolbarHeight,
            ),
            content: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    pop();
                    pushNamed(AppRoutes.deviceHistory);
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: AppText(
                      text: 'Connection History',
                      fontSize: 16,
                      weight: FontWeight.w500,
                    ),
                  ),
                ),
                AppSpace.vrtSpace(10),
                InkWell(
                  onTap: () {
                    pop();
                    pushNamed(AppRoutes.locationHistory);
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: AppText(
                      text: 'Location History',
                      fontSize: 16,
                      weight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
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
        return StatefulBuilder(builder:
            (BuildContext context, Function(void Function()) setState) {
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
                    ...['Internet', 'User Disconnect', 'Helmet', 'Bluetooth']
                        .map(
                          (e) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              RadioListTile<String>(
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 4),
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
                      final device = await context
                          .read<BluetoothCubit>()
                          .checkSavedDevice();
                      await di.get<HelmetService>().disconnectingReason(
                          device?.name ?? '',
                          selectedReason ?? '',
                          statusDescController.text);
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
