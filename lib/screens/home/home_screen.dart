import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:lottie/lottie.dart';

import 'package:unilever_activo/bloc_cubits/bluetooth_cubit.dart';

import 'package:unilever_activo/utils/app_colors.dart';
import 'package:unilever_activo/utils/assets.dart';
import 'package:unilever_activo/utils/widgets/app_space.dart';
import 'package:unilever_activo/utils/widgets/app_text.dart';

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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 2,
                    child: AppText(
                      text: "Auto connect with last paired",
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  Expanded(
                    flex: 0,
                    child: Switch.adaptive(
                      value: false,
                      onChanged: (value) {},
                    ),
                  ),
                ],
              ),
              AppSpace.vrtSpace(10),
              BlocConsumer<BluetoothCubit, AppBluetoothState>(
                builder: (context, state) {
                  print("${state}");
                  final newCubit = context.read<BluetoothCubit>();

                  if (state == AppBluetoothState.off) {
                    return Lottie.asset(
                      AssetsPath.powerOn,
                      frameRate: FrameRate.max,
                      fit: BoxFit.fill,
                      height: size.height * 0.2,
                    );
                  } else if (state == AppBluetoothState.connected ||
                      state == AppBluetoothState.deviceDataUpdated ||
                      state == AppBluetoothState.newDeviceData) {
                    final batterPer = (newCubit.batteryPercentage ?? 0) / 100;
                    return Column(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            await newCubit.disconnect();
                          },
                          child: Lottie.asset(
                            AssetsPath.powerOff,
                            frameRate: FrameRate.max,
                            fit: BoxFit.fill,
                            height: size.height * 0.2,
                          ),
                        ),
                        Container(
                          width: size.width * 0.3,
                          height: 30,
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.white),
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: FractionallySizedBox(
                            widthFactor: batterPer,
                            alignment: Alignment.centerLeft,
                            child: Container(
                              decoration: BoxDecoration(
                                color: batterPer <= 0.2 ? Colors.red : Colors.green,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Center(
                                child: AppText(
                                  text: "${newCubit.batteryPercentage ?? "0"}%",
                                  color: AppColors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                        AppSpace.vrtSpace(10),
                        AppText(
                          text: newCubit.isWore > 0 ? "Not Weared" : "Weared",
                          color: AppColors.white,
                        ),
                      ],
                    );
                  }
                  return Expanded(
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () async {},
                          child: Lottie.asset(
                            AssetsPath.bluetoothLoading,
                            frameRate: FrameRate.max,
                            fit: BoxFit.fill,
                            height: size.height * 0.2,
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: newCubit.devices.length,
                            itemBuilder: (context, index) {
                              final item = newCubit.devices[index];
                              log(item.device.name ?? "");
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2),
                                child: Card(
                                  child: ListTile(
                                    onTap: () async {
                                      await newCubit.connect(item.device);
                                    },
                                    dense: true,
                                    leading: const Icon(
                                      Icons.bluetooth,
                                      color: AppColors.blueAccent,
                                      size: 30,
                                    ),
                                    title: AppText(
                                      text: item.device.name ?? "",
                                      fontSize: 15,
                                    ),
                                    subtitle: AppText(
                                      text: item.device.address,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        AppSpace.vrtSpace(10),
                      ],
                    ),
                  );
                },
                listener: (context, state) {
                  final cubit = context.read<BluetoothCubit>();
                  if (state == AppBluetoothState.off) {
                    cubit.snackBar("Bluetooth is turned off", context);
                  } else if (state == AppBluetoothState.error) {
                    cubit.snackBar("Can't Connect", context);
                  } else if (state == AppBluetoothState.connecting) {
                    cubit.snackBar("Connecting to ${cubit.deviceName}", context);
                  } else if (state == AppBluetoothState.connected) {
                    cubit.snackBar("Connected to ${cubit.deviceName}  ", context);
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
  }
}
