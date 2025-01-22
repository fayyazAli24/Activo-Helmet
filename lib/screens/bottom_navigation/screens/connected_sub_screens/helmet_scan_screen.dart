
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unilever_activo/bloc/states/bluetooth_state/bluetooth_states.dart';

import '../../../../bloc/cubits/bluetooth_cubits/bluetooth_cubit.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/widgets/app_text.dart';

class HelmetScanningScreen extends StatelessWidget {
  BluetoothScannedState bluetoothState;
  HelmetScanningScreen({super.key, required this.bluetoothState});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      width: 300,
      child: ListView.builder(
        itemCount: bluetoothState.devices.length,
        itemBuilder: (context, index) {
          final item = bluetoothState.devices[index];

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Card(
              child: ListTile(
                onTap: () async {
                  await context.read<BluetoothCubit>().connect(item);
                },
                dense: true,
                leading: const Icon(
                  Icons.bluetooth,
                  color: AppColors.blueAccent,
                  size: 30,
                ),
                title: AppText(
                  text: item.platformName ?? '',
                  fontSize: 15,
                ),
                subtitle: AppText(
                  text: item.remoteId.toString(),
                  fontSize: 12,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
