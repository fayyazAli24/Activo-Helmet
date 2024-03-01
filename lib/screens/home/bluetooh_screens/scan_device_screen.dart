import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:unilever_activo/bloc/cubits/bluetooth_cubits/bluetooth_cubit.dart';
import 'package:unilever_activo/bloc/cubits/switch_cubit/switch_cubit.dart';
import 'package:unilever_activo/bloc/states/bluetooth_state/bluetooth_states.dart';
import 'package:unilever_activo/utils/app_colors.dart';
import 'package:unilever_activo/utils/assets.dart';
import 'package:unilever_activo/utils/widgets/app_space.dart';
import 'package:unilever_activo/utils/widgets/app_text.dart';

class BluetoothScanDeviceScreen extends StatelessWidget {
  const BluetoothScanDeviceScreen({
    super.key,
    required this.theme,
    required this.size,
  });

  final ThemeData theme;

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
                text: 'Auto connect with last paired',
                color: theme.textTheme.bodyLarge?.color,
              ),
              BlocConsumer<SwitchCubit, bool>(
                listener: (context, state) {},
                builder: (context, state) {
                  // context.read<BluetoothCubit>().autoConnected = state;
                  return Switch.adaptive(
                    trackColor: theme.switchTheme.trackColor,
                    activeTrackColor: AppColors.white,
                    activeColor: AppColors.black,
                    value: state,
                    onChanged: (value) {
                      context.read<BluetoothCubit>().autoConnected = value;
                      print('the state of auto connect is ${context.read<BluetoothCubit>().autoConnected}');
                      context.read<BluetoothCubit>().disconnectReasonCode = 0;
                      context.read<SwitchCubit>().updateValue(value);
                      print(context.read<BluetoothCubit>().autoConnected);
                    },
                  );
                },
              ),
            ],
          ),
          InkWell(
            onTap: () async {
              await context.read<BluetoothCubit>().getDevices();
            },
            child: Lottie.asset(
              AssetsPath.bluetoothLoading,
              frameRate: FrameRate.max,
              animate: context.read<BluetoothCubit>().isDiscovering,
              fit: BoxFit.fill,
              height: size.height * 0.2,
            ),
          ),
          if (context.read<BluetoothCubit>().isDiscovering)
            const AppText(
              text: 'Scanning for bluetooth Devices',
              weight: FontWeight.w500,
            )
          else
            const AppText(
              text: 'Tap to Scan',
              weight: FontWeight.w500,
            ),
          BlocConsumer<BluetoothCubit, AppBluetoothState>(
            listener: (context, state) {},
            builder: (context, state) {
              if (state is BluetoothScannedState) {
                return Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: state.devices.length,
                    itemBuilder: (context, index) {
                      final item = state.devices[index];

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Card(
                          child: ListTile(
                            onTap: () async {
                              await context.read<BluetoothCubit>().connect(item);
                              // context.read<BluetoothCubit>().device = item;
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
              return AppSpace.noSpace;
            },
          ),
          AppSpace.vrtSpace(10),
        ],
      ),
    );
  }
}
