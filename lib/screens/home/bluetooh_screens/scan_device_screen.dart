import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:unilever_activo/bloc/cubits/bluetooth_cubits/bluetooth_cubit.dart';
import 'package:unilever_activo/utils/app_colors.dart';
import 'package:unilever_activo/utils/assets.dart';
import 'package:unilever_activo/utils/widgets/app_space.dart';
import 'package:unilever_activo/utils/widgets/app_text.dart';

class BluetoothScanDeviceScreen extends StatelessWidget {
  const BluetoothScanDeviceScreen({
    super.key,
    required this.theme,
    required this.newCubit,
    required this.size,
  });

  final ThemeData theme;
  final BluetoothCubit newCubit;
  final Size size;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                text: "Auto connect with last paired",
                color: theme.textTheme.bodyLarge?.color,
              ),
              Switch.adaptive(
                value: newCubit.autoConnected,
                onChanged: (value) {
                  newCubit.autoConnect(value);
                },
              ),
            ],
          ),
          InkWell(
            onTap: () async {
              newCubit.getDevices();
            },
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
  }
}
