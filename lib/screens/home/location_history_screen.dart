import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:unilever_activo/bloc/cubits/location_history_cubit/location_history_cubit.dart';
import 'package:unilever_activo/bloc/states/location_history_state/location_history_state.dart';
import 'package:unilever_activo/utils/app_colors.dart';
import 'package:unilever_activo/utils/widgets/app_loader.dart';
import 'package:unilever_activo/utils/widgets/app_space.dart';
import 'package:unilever_activo/utils/widgets/app_text.dart';

class LocationHistoryScreen extends StatefulWidget {
  const LocationHistoryScreen({super.key});

  @override
  State<LocationHistoryScreen> createState() => _LocationHistoryScreenState();
}

class _LocationHistoryScreenState extends State<LocationHistoryScreen> {
  Future<void> initialization() async {
    await context.read<LocationHistoryCubit>().getRecords();
  }

  @override
  void initState() {
    super.initState();
    initialization();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AppText(
          text: 'Location History',
          color: AppColors.white,
          weight: FontWeight.w500,
        ),
      ),
      body: BlocConsumer<LocationHistoryCubit, LocationHistoryState>(
        builder: (context, state) {
          if (state is LocationHistoryLoading) {
            return const AppLoader();
          } else if (state is LocationHistorySuccess) {
            return StreamBuilder(
              stream: context.read<LocationHistoryCubit>().getRecords().asStream(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                    itemCount: state.list.length,
                    itemBuilder: (context, index) {
                      var device = state.list[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(width: 0.8, color: AppColors.primaryColor),
                        ),
                        elevation: 2,
                        color: Theme.of(context).cardColor,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                flex: 5,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    buildCardRow(
                                        'Time', DateFormat('dd-MMM-yyyy:mm:ss').format(DateTime.parse(device['time']))),
                                    AppSpace.vrtSpace(5),
                                    buildCardRow('Latitude', device['lat'].toString()),
                                    AppSpace.vrtSpace(5),
                                    buildCardRow(
                                      'Longitude',
                                      device['long'].toString(),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: AppText(
                                  text: '${device['reason']}',
                                  weight: FontWeight.w500,
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) => AppSpace.vrtSpace(5),
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
              },
            );
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
      children: [
        Expanded(
          child: AppText(
            text: heading,
            weight: FontWeight.w500,
          ),
        ),
        Expanded(
          flex: 2,
          child: AppText(
            text: value,
            weight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }
}
