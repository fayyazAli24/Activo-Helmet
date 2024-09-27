import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:unilever_activo/bloc/cubits/switch_cubit/bluetooth_switch.dart';

import '../../../bloc/cubits/bluetooth_cubits/bluetooth_cubit.dart';
import '../../../bloc/cubits/location_cubits/location_cubit.dart';
import '../../../bloc/cubits/switch_cubit/switch_cubit.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/widgets/app_text.dart';

class HelmetConnected extends StatefulWidget {
  HelmetConnected({Key? key}) : super(key: key);

  @override
  State<HelmetConnected> createState() => _HelmetConnectedState();
}

class _HelmetConnectedState extends State<HelmetConnected> {
  double batteryPercentage = 100.0;
  String helmetName = 'Activo Helmet 13314580';

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 0,
          child: Container(
            width: 100.w,
            height: 25.h,
            color: AppColors.test4,
            child: const Column(
              children: [
                SizedBox(
                  height: 15,
                ),
                CircleAvatar(
                  backgroundColor: Colors.grey,
                  radius: 40,
                  child: Text("FA"),
                ),
                SizedBox(
                  height: 15,
                ),
                Text("Fayyaz Ali"),
                SizedBox(
                  height: 2,
                ),
                Text("+924343434343"),
              ],
            ),
          ),
        ),
        Positioned(
          left: 32,
          bottom: Get.height * 0.53,
          child: Container(
            width: 85.w,
            height: 8.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2), // Shadow color with opacity
                  spreadRadius: 2, // How far the shadow spreads
                  blurRadius: 5, // Blur effect of the shadow
                  offset: const Offset(0, 4), // Position of the shadow (horizontal and vertical)
                ),
              ],
            ),
            child: Row(
              children: [
                Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: InkWell(
                      onTap: () async {
                        await context.read<BluetoothCubit>().getDevices();
                        print('the length after getting is ${context.read<BluetoothCubit>().scannedDevices.length}');
                        var temp = await context.read<BluetoothCubit>().search(helmetName);
                        if (temp != null) {
                          await context.read<BluetoothCubit>().connect(temp);
                        }
                      },
                      child: const CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.redAccent,
                        child: Icon(
                          size: 30,
                          Icons.power_settings_new,
                          color: Colors.white,
                        ),
                      ),
                    )),
                const VerticalDivider(),
                const SizedBox(
                  width: 20,
                ),
                const Text(
                  "Enable auto connect",
                  style: TextStyle(color: Colors.black38, fontSize: 16),
                ),
                const SizedBox(width: 20),
                BlocConsumer<SwitchCubit, bool>(
                  listener: (context, state) {},
                  builder: (context, state) {
                    return Switch.adaptive(
                      inactiveTrackColor: Colors.white38,
                      activeTrackColor: AppColors.test4,
                      activeColor: Colors.white,
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
          ),
        ),
        Positioned(
          left: 37,
          top: Get.height * 0.30,
          bottom: 30,
          child: Container(
            width: 80.w,
            height: 80.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2), // Shadow color with opacity
                  spreadRadius: 2, // How far the shadow spreads
                  blurRadius: 8, // Blur effect of the shadow
                  offset: const Offset(0, 4), // Position of the shadow (horizontal and vertical)
                ),
              ],
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  SizedBox(
                    height: 3.h,
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 12.0, bottom: 5),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        'Connected to Activo 1324562',
                        style: TextStyle(color: Colors.black, fontSize: 16),
                      ),
                    ),
                  ),
                  const Divider(),
                  SizedBox(
                    height: 2.5.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 17.w,
                            height: 4.h,
                            decoration: BoxDecoration(
                              color: batteryPercentage / 100 <= 0.2 ? Colors.red : AppColors.test2,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.center,
                              child: AppText(
                                text: '${batteryPercentage.toInt()}%',
                                color: AppColors.white,
                                fontSize: 12,
                                textAlign: TextAlign.center,
                                weight: FontWeight.w500,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 1.h,
                          ),
                          Text(
                            "Battery",
                            style: TextStyle(color: Colors.grey.shade700),
                          )
                        ],
                      ),
                      Column(
                        children: [
                          Icon(
                            Icons.headphones,
                            color: Colors.grey.shade700,
                            size: 40,
                          ),
                          SizedBox(
                            height: 1.h,
                          ),
                          Text(
                            "Worn",
                            style: TextStyle(color: Colors.grey.shade700),
                          )
                        ],
                      ),
                      Column(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: Colors.grey.shade700,
                            size: 40,
                          ),
                          SizedBox(
                            height: 1.h,
                          ),
                          BlocBuilder<LocationCubit, LocationStatus>(
                            builder: (context, locationState) {
                              if (locationState is LocationOff) {
                                return Text(
                                  "Location off",
                                  style: TextStyle(color: Colors.grey.shade700),
                                );
                              } else {
                                return Text(
                                  "Location ON",
                                  style: TextStyle(color: Colors.grey.shade700),
                                );
                              }
                            },
                          )
                        ],
                      )
                    ],
                  ),
                  SizedBox(
                    height: 2.5.h,
                  ),
                  const Divider(),
                  SizedBox(
                    height: 2.5.h,
                  ),
                  Container(
                    width: 75.w,
                    height: 6.5.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2), // Shadow color with opacity
                          spreadRadius: 2, // How far the shadow spreads
                          blurRadius: 5, // Blur effect of the shadow
                          offset: const Offset(0, 4), // Position of the shadow (horizontal and vertical)
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 20,
                        ),
                        const Text(
                          'Enable Bluetooth',
                          style: TextStyle(color: Colors.black38, fontSize: 16),
                        ),
                        const SizedBox(width: 65),
                        BlocConsumer<BluetoothSwitch, bool>(
                          listener: (context, state) {},
                          builder: (context, state) {
                            return Switch.adaptive(
                              inactiveTrackColor: Colors.white38,
                              activeTrackColor: AppColors.test4,
                              activeColor: Colors.white,
                              value: state,
                              onChanged: (value) async {
                                print("jjjjjjjjjjjj $state");
                                context.read<BluetoothSwitch>().updateValue(value);

                                if (state == false) {
                                  await context.read<BluetoothCubit>().turnOn();
                                  await context.read<BluetoothCubit>().getDevices();
                                } else {
                                  await FlutterBluePlus.turnOff();
                                }
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
