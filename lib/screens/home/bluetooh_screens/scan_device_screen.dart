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

import '../../../bloc/cubits/location_cubits/location_cubit.dart';

class BluetoothScanDeviceScreen extends StatefulWidget {
  const BluetoothScanDeviceScreen({
    super.key,
    required this.theme,
    required this.size,
  });

  final ThemeData theme;

  final Size size;

  @override
  State<BluetoothScanDeviceScreen> createState() => _BluetoothScanDeviceScreenState();
}

class _BluetoothScanDeviceScreenState extends State<BluetoothScanDeviceScreen> {
  Future<void> initialization() async {
    context.read<BluetoothCubit>().autoConnected = await context.read<SwitchCubit>().initialValue();
  }

  @override
  void initState() {
    initialization();
    super.initState();
  }

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
                color: widget.theme.textTheme.bodyLarge?.color,
              ),
              BlocConsumer<SwitchCubit, bool>(
                listener: (context, state) {},
                builder: (context, state) {
                  return Switch.adaptive(
                    trackColor: widget.theme.switchTheme.trackColor,
                    activeTrackColor: AppColors.white,
                    activeColor: AppColors.black,
                    value: state,
                    onChanged: (value) {
                      context.read<BluetoothCubit>().autoConnected = value;
                      // print('the state of auto connect is ${context.read<BluetoothCubit>().autoConnected}');
                      context.read<BluetoothCubit>().disconnectReasonCode = 0;
                      context.read<SwitchCubit>().updateValue(value);
                      // print(context.read<BluetoothCubit>().autoConnected);
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
              height: widget.size.height * 0.2,
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
            listener: (context, bluetoothState) {},
            builder: (context, bluetoothState) {
              if (bluetoothState is BluetoothScannedState) {
                return BlocBuilder<LocationCubit, LocationStatus>(
                  builder: (context, locationState) {
                    return Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: bluetoothState.devices.length,
                        itemBuilder: (context, index) {
                          final item = bluetoothState.devices[index];

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Card(
                              child: ListTile(
                                onTap: () async {
                                  // Check if the location is off
                                  if (locationState is LocationOff) {
                                    // Show pop-up dialog if location is off
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return const AlertDialog(
                                          title: Text('Location is Off'),
                                          content: Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text('Please turn on your location to connect to the device.'),
                                          ),
                                        );
                                      },
                                    );
                                  } else if (locationState is LocationOn) {
                                    // Proceed with Bluetooth connection if location is on
                                    await context.read<BluetoothCubit>().connect(item);
                                  }
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
                  },
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

  Widget buttons(String text) {
    return Container(
      child: Center(
        child: Text(text),
      ),
    );
  }
}
