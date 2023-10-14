import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:unilever_activo/bloc/cubits/bluetooth_cubits/bluetooth_cubit.dart';
import 'package:unilever_activo/bloc/cubits/location_cubits/location_cubit.dart';
import 'package:unilever_activo/screens/home/bluetooh_screens/connected_device_screen.dart';
import 'package:unilever_activo/screens/home/bluetooh_screens/disconnected_screen.dart';
import 'package:unilever_activo/screens/home/bluetooh_screens/scan_device_screen.dart';
import 'package:unilever_activo/utils/app_colors.dart';
import 'package:unilever_activo/utils/assets.dart';
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);

    return BlocConsumer<LocationCubit, LocationStatus>(
      listener: (context, state) {
        final locationCubit = context.read<LocationCubit>();

        if (state == LocationStatus.off) {
          showAdaptiveDialog(
            context: context,
            builder: (context) {
              return AlertDialog.adaptive(
                actionsAlignment: MainAxisAlignment.spaceEvenly,
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      locationCubit.resetState();
                    },
                    child: const AppText(text: "Close"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      locationCubit.openSettings();
                    },
                    child: const AppText(text: "Settings"),
                  ),
                ],
                title: const AppText(
                  text: "Location is closed please open settings to turn on location",
                ),
              );
            },
          );
        }
        // else if (state == LocationStatus.on) {
        //   snackBar("Location is turned On", context, color: Colors.green, textColor: AppColors.white);
        // }
      },
      builder: (context, state) {
        print(state.toString());
        return Scaffold(
          appBar: AppBar(
            backgroundColor: theme.appBarTheme.backgroundColor,
            leading: AppSpace.noSpace,
            leadingWidth: 0,
            title: const AppText(
              text: "Smart Helmet (Activo)",
              fontSize: 18,
              color: AppColors.white,
              weight: FontWeight.w500,
            ),
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
                      print("${state}");
                      final newCubit = context.read<BluetoothCubit>();

                      if (state == AppBluetoothState.off) {
                        return BluetoothOffScreen(
                          size: size,
                        );
                      } else if (state == AppBluetoothState.connected ||
                          state == AppBluetoothState.deviceDataUpdated ||
                          state == AppBluetoothState.newDeviceData) {
                        final batterPer = (newCubit.batteryPercentage ?? 0) / 100;
                        return BluetoothConnectedScreen(
                          newCubit: newCubit,
                          size: size,
                          batterPer: batterPer,
                        );
                      }
                      return BluetoothScanDeviceScreen(
                        theme: theme,
                        newCubit: newCubit,
                        size: size,
                      );
                    },
                    listener: (context, state) {
                      final cubit = context.read<BluetoothCubit>();
                      if (state == AppBluetoothState.off) {
                        snackBar("Bluetooth is turned off", context);
                      } else if (state == AppBluetoothState.error) {
                        snackBar("Can't Connect", context);
                      } else if (state == AppBluetoothState.connecting) {
                        snackBar("Connecting to ${cubit.deviceName}", context);
                      } else if (state == AppBluetoothState.connected) {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        snackBar("Connected to ${cubit.deviceName}  ", context);
                      }
                      if (state == AppBluetoothState.connecting) {
                        showAdaptiveDialog(
                          context: context,
                          builder: (context) {
                            return const AlertDialog.adaptive(
                              title: AppText(
                                text: "connecting..",
                              ),
                            );
                          },
                        );
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
}
