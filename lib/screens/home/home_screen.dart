import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unilever_activo/bloc/cubits/bluetooth_cubits/bluetooth_cubit.dart';
import 'package:unilever_activo/bloc/cubits/location_cubits/location_cubit.dart';
import 'package:unilever_activo/bloc/states/bluetooth_state/bluetooth_states.dart';
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
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);

    return BlocConsumer<LocationCubit, LocationStatus>(
      listener: (context, state) {
        if (state is LocationOff) {
          locationOffDialog(context);
        }
      },
      builder: (context, state) {
        return Scaffold(
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
                onPressed: () => pushNamed(AppRoutes.deviceHistory),
                icon: const Icon(
                  Icons.history,
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
                          deviceName: state.name,
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
                        showAdaptiveDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog.adaptive(
                              actions: [
                                AppButton(
                                  onPressed: () async {
                                    await BlocProvider.of<BluetoothCubit>(context).audioPlayer.stop();
                                    pop();
                                  },
                                )
                              ],
                              title: const AppText(
                                text: 'Helmet Disconnected',
                              ),
                            );
                          },
                        );

                        snackBar('Device Disconnected', context);
                      }
                      if (state is BluetoothConnectingState) {
                        connectingDialog(context);
                      }
                    },
                  ),
                ],
              ),
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

  Future<dynamic> connectingDialog(BuildContext context) {
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
