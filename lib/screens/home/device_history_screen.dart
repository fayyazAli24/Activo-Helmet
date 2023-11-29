import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:unilever_activo/bloc/cubits/device_history_cubit/device_history_cubit.dart';
import 'package:unilever_activo/domain/models/device_req_body_model.dart';
import 'package:unilever_activo/utils/app_colors.dart';
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
    BlocProvider.of<DeviceHistoryCubit>(context).devicesList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppText(
          text: "Device History",
          color: AppColors.white,
          weight: FontWeight.w500,
        ),
      ),
      body: BlocConsumer<DeviceHistoryCubit, DeviceHistoryState>(
        builder: (context, state) {
          if (state is DeviceHistorySuccess) {
            return ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              itemCount: state.deviceData.length,
              itemBuilder: (context, index) {
                DeviceReqBodyModel device = state.deviceData[index];
                return Card(
                  shadowColor: device.isWearHelmet == 0 ? AppColors.red : AppColors.green,
                  elevation: 10,
                  surfaceTintColor: Theme.of(context).cardTheme.surfaceTintColor,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildCardRow("Helmet ID", device.helmetId.toString()),
                        buildCardRow("Status", device.isWearHelmet == 0 ? "Not Weared" : "Weared"),
                        buildCardRow("Latitude", device.latitude.toString()),
                        buildCardRow("Longitude", device.longitude.toString()),
                        buildCardRow("speed", device.speed.toString()),
                        buildCardRow("API DateTime",
                            DateFormat('dd-MMM-yyyy:hh:mm').format(device.apiDateTime ?? DateTime.now())),
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) => AppSpace.vrtSpace(5),
            );
          } else if (state is DeviceHistoryLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryColor,
              ),
            );
          }
          return Center(
            child: AppText(
              text: "No Records Found",
              weight: FontWeight.w500,
            ),
          );
        },
        listener: (context, state) {},
      ),
    );
  }

  Row buildCardRow(String heading, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText(text: heading),
        AppText(text: value),
      ],
    );
  }
}
