import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:unilever_activo/utils/widgets/mobthly_line_chart.dart';
import '../../../app/app_keys.dart';
import '../../../domain/services/graph/graph_service.dart';
import '../../../domain/services/storage_services.dart';
import '../../../utils/app_colors.dart';

class Stats extends StatefulWidget {
  const Stats({Key? key}) : super(key: key);

  @override
  State<Stats> createState() => _StatsState();
}

class _StatsState extends State<Stats> {
  List<Color> gradientColors = [
    AppColors.contentColorCyan,
    AppColors.contentColorBlue,
  ];

  var data;
  bool showAvg = false;
  int touchedIndex = -1;
  bool isLoading = true; // Flag to indicate loading state

  Future<void> getGraphData() async {
    try {
      var id = await StorageService().read(lastDeviceKey);
      if (id != null) {
        var res = await GraphService().getData(id.toString());
        if (res != null) {
          setState(() {
            data = res;
            isLoading = false; // Data is now loaded
          });
          print("The data is $data");
        } else {
          setState(() {
            isLoading = false; // Even if null, stop loading spinner
          });
        }
      }
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching graph data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getGraphData();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          width: 95.w,
          height: 60.h,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: 92.w,
              height: 50.h,
              decoration: BoxDecoration(
                color: AppColors.test3,
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                  right: 25,
                  left: 8,
                  top: 24,
                  bottom: 12,
                ),
                child: isLoading
                    ? const Center(child: CircularProgressIndicator()) // Show a loading spinner
                    : MonthlyLineChart(
                        data: data, // Pass data once loaded
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }


}
