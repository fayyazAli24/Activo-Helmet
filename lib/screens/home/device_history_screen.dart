import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unilever_activo/bloc/cubits/device_history_cubit/device_history_cubit.dart';
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
          weight: FontWeight.w500,
        ),
      ),
      body: BlocConsumer<DeviceHistoryCubit, DeviceHistoryState>(
        builder: (context, state) {
          if (state is DeviceHistorySuccess) {
            return ListView.separated(
              itemCount: state.deviceData.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> device = state.deviceData[index];
                return SizedBox(
                  height: 100,
                  width: 100,
                  child: Card(
                    elevation: 10,
                    surfaceTintColor: Theme.of(context).cardTheme.surfaceTintColor,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              AppText(text: "Status"),
                              AppText(text: device['Is_Wear_Helmet'].toString()),
                            ],
                          ),
                        ],
                      ),
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
}
