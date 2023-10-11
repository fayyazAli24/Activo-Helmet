import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:unilever_activo/bloc_cubits/bluetooth_cubit.dart';
import 'package:unilever_activo/bloc_cubits/home_cubit.dart';
import 'package:unilever_activo/bloc_cubits/theme_cubit.dart';

import 'package:unilever_activo/utils/app_colors.dart';
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

    return BlocConsumer<BluetoothCubit, AppBluetoothState>(
      listener: (context, state) {
        final cubit = context.read<BluetoothCubit>();
        if (state == AppBluetoothState.scanning) {
          cubit.snackBar("Scanning devices", context);
        } else if (state == AppBluetoothState.scanned) {
          cubit.snackBar("Scanned", context);
        }
      },
      builder: (context, state) {
        List list = [];

        final cubit = context.read<BluetoothCubit>();
        if (cubit.devices.any((element) => element.device.platformName.isNotEmpty)) {
          list = context.read<BluetoothCubit>().devices;
        }
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
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        cubit.startScan();
                      },
                      child: const SizedBox(
                        height: 50,
                        width: 50,
                        child: Icon(Icons.refresh),
                      ),
                    ),
                  ),
                  if (context.read<BluetoothCubit>().devices.isEmpty)
                    const Center(
                      child: AppText(
                        text: "No Devices Found",
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          final item = cubit.devices[index];

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Card(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      // Image.asset(  ),
                                      Column(
                                        children: [
                                          AppText(
                                            text: item.device.platformName ?? "",
                                            fontSize: 15,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
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
