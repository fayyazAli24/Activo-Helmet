import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:unilever_activo/bloc/cubits/device_history_cubit/device_history_cubit.dart';
import 'package:unilever_activo/bloc/states/device_history_state/device_history_state.dart';
import 'package:unilever_activo/utils/app_colors.dart';
import 'package:unilever_activo/utils/widgets/app_loader.dart';
import 'package:unilever_activo/utils/widgets/app_space.dart';
import 'package:unilever_activo/utils/widgets/app_text.dart';

class DeviceHistoryScreen extends StatefulWidget {
  const DeviceHistoryScreen({super.key});

  @override
  State<DeviceHistoryScreen> createState() => _DeviceHistoryScreenState();
}

class _DeviceHistoryScreenState extends State<DeviceHistoryScreen> {
  @override
  void initState() {
    context.read<DeviceHistoryCubit>().deviceHistoryList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AppText(
          text: 'Device History',
          color: AppColors.white,
          weight: FontWeight.w500,
        ),
      ),
      body: BlocConsumer<DeviceHistoryCubit, DeviceHistoryState>(
        builder: (context, state) {
          if (state is DeviceHistorySuccess) {
            return StreamBuilder(
                stream: context.read<DeviceHistoryCubit>().deviceHistoryList().asStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      itemCount: snapshot.data?.length ?? 0,
                      itemBuilder: (context, index) {
                        var device = snapshot.data![index];
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                                width: 0.8, color: device.synced == 1 ? AppColors.primaryColor : AppColors.red),
                          ),
                          shadowColor: device.synced == 1 ? AppColors.cyan : AppColors.red,
                          elevation: device.synced == 1 ? 20 : 10,
                          color: Theme.of(context).cardColor,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildCardRow('Helmet ID', device.helmetId.toString()),
                                buildCardRow('Status', device.isWearHelmet == 0 ? 'Not Weared' : 'Weared'),
                                buildCardRow('Latitude', device.latitude.toString()),
                                buildCardRow('Longitude', device.longitude.toString()),
                                buildCardRow('speed', device.speed.toString()),
                                buildCardRow(
                                  'Sync Status',
                                  device.synced == 1 ? 'Synced' : 'UnSynced',
                                  device.synced == 0 ? Colors.red : AppColors.green,
                                ),
                                buildCardRow('API DateTime',
                                    DateFormat('dd-MMM-yyyy:hh:mm:ss').format(device.apiDateTime ?? DateTime.now())),
                              ],
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (context, index) => AppSpace.vrtSpace(10),
                    );
                  } else if (snapshot.connectionState == ConnectionState.waiting) {
                    return const AppLoader();
                  }
                  return const Center(
                    child: AppText(
                      text: 'No Records Found',
                      weight: FontWeight.w500,
                    ),
                  );
                });
          } else if (state is DeviceHistoryLoading) {
            return const AppLoader();
          }
          return const Center(
            child: AppText(
              text: 'No Records Found',
              weight: FontWeight.w500,
            ),
          );
        },
        listener: (context, state) {},
      ),
    );
  }

  Row buildCardRow(String heading, String value, [Color? color]) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText(
          text: heading,
          weight: FontWeight.w500,
        ),
        AppText(
          text: value,
          weight: FontWeight.w500,
          color: color,
        ),
      ],
    );
  }
}
