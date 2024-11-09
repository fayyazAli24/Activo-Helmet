import 'dart:async';
import 'dart:developer';

import 'package:alarm/alarm.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location/location.dart';
import 'package:unilever_activo/bloc/cubits/alarm_dart_cubit.dart';
import 'package:unilever_activo/bloc/cubits/alarm_dart_state.dart';
import 'package:unilever_activo/bloc/cubits/bottom_navigation/bottom_navigation_cubit.dart';
import 'package:unilever_activo/domain/services/test.dart';
import 'package:unilever_activo/utils/widgets/custom_app_bar.dart';

import '../../app/app.dart';
import '../../bloc/cubits/bluetooth_cubits/bluetooth_cubit.dart';
import '../../bloc/cubits/location_cubits/location_cubit.dart';
import '../../bloc/cubits/switch_cubit/switch_cubit.dart';
import '../../bloc/states/bluetooth_state/bluetooth_states.dart';
import '../../bloc/states/bottom_navigation/bottom_navigation_state.dart';
import '../../domain/services/helmet_service.dart';
import '../../navigations/navigation_helper.dart';
import '../../utils/app_colors.dart';
import '../../utils/widgets/app_button.dart';
import '../../utils/widgets/app_space.dart';
import '../../utils/widgets/app_text.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<void> onInit() async {
    final bluetoothCubit = context.read<BluetoothCubit>();
    await bluetoothCubit.checkPermissions();
    bluetoothCubit.listenState();

    context.read<BluetoothCubit>().autoConnected = await context.read<SwitchCubit>().initialValue();
    print('in init of scan ${context.read<BluetoothCubit>().autoConnected}');

    /// to manage counter
    TimerTest.manageCounter(context);
  }

  @override
  void initState() {
    super.initState();
    onInit();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    TimerTest.counter?.cancel();
    TimerTest.connectedTime = DateTime.now();
    super.dispose();
  }

  final _formKey = GlobalKey<FormState>();
  Location location = Location();
  TextEditingController statusDescController = TextEditingController();
  String? selectedReason;
  Timer? timer;
  StreamSubscription<ConnectivityResult>? subscription;

  String? device;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BottomNavigationCubit, BottomNavigationState>(
      builder: (context, bottomNavigationstate) {
        final bottomNavigationCubit = context.read<BottomNavigationCubit>();
        return BlocConsumer<AlarmCubit, AlarmState>(
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
          builder: (context, state) {
            return BlocListener<LocationCubit, LocationStatus>(
                listener: (context, locationState) {
                  if (locationState is LocationOff) {
                    final bluetoothState = context.read<BluetoothCubit>().state;
                    if (bluetoothState is BluetoothConnectedState) {
                      context.read<BluetoothCubit>().disconnectReasonCode = 111;
                      context
                          .read<BluetoothCubit>()
                          .disconnectDevice(context.read<BluetoothCubit>().disconnectReasonCode);
                    }
                    locationOffDialog(context);
                  }
                },
                child: Scaffold(
                    backgroundColor: Colors.white,
                    appBar: CustomAppBar(
                      title: 'Smart Helmet (Activo)',
                      onOptionsPressed: () {
                        optionsDialogBox(context);
                      },
                    ),
                    body: bottomNavigationCubit.pages[bottomNavigationCubit.pageIndex],
                    bottomNavigationBar: Container(
                        height: 60,
                        decoration: const BoxDecoration(
                          color: AppColors.test3,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            // HelmetConnected (index 0)
                            IconButton(
                              enableFeedback: false,
                              onPressed: () {
                                bottomNavigationCubit.setIndex(0); // HelmetConnected index
                              },
                              icon: bottomNavigationstate is HelmetConnectedState
                                  ? const Icon(
                                      Icons.directions_bike_rounded,
                                      color: Colors.blueAccent,
                                      size: 35,
                                    )
                                  : const Icon(
                                      Icons.directions_bike_rounded,
                                      color: Colors.white,
                                      size: 35,
                                    ),
                            ),
                            // Stats (index 1)
                            IconButton(
                              enableFeedback: false,
                              onPressed: () {
                                bottomNavigationCubit.setIndex(1); // Stats index
                              },
                              icon: bottomNavigationstate is StatsState
                                  ? const Icon(
                                      Icons.bar_chart_rounded,
                                      color: Colors.blueAccent,
                                      size: 35,
                                    )
                                  : const Icon(
                                      Icons.bar_chart_rounded,
                                      color: Colors.white,
                                      size: 35,
                                    ),
                            ),
                            // SOS (index 2)
                            IconButton(
                              enableFeedback: false,
                              onPressed: () {
                                bottomNavigationCubit.setIndex(2); // SOS index
                              },
                              icon: bottomNavigationstate is SOSState
                                  ? const Icon(
                                      Icons.warning_amber_rounded,
                                      color: Colors.blueAccent,
                                      size: 35,
                                    )
                                  : const Icon(
                                      Icons.warning_amber_outlined,
                                      color: Colors.white,
                                      size: 35,
                                    ),
                            ),
                            // ManageProfile (index 3)
                            IconButton(
                              enableFeedback: false,
                              onPressed: () {
                                bottomNavigationCubit.setIndex(3); // ManageProfile index
                              },
                              icon: bottomNavigationstate is ManageProfileState
                                  ? const Icon(
                                      Icons.person,
                                      color: Colors.blueAccent,
                                      size: 35,
                                    )
                                  : const Icon(
                                      Icons.person_outline,
                                      color: Colors.white,
                                      size: 35,
                                    ),
                            ),
                          ],
                        ))));
          },
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
          return AlertDialog(
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

  Future<void> manageAlarm() async {
    context.read<AlarmCubit>().stopAlarm();
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

  Future<dynamic> locationOffDialog(BuildContext context) {
    print('from home screen');
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
}
