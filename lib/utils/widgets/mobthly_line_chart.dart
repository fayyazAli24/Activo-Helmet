import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../app_colors.dart';

class MonthlyLineChart extends StatefulWidget {
  final List? data;
  MonthlyLineChart({super.key, this.data});

  @override
  _MonthlyLineChartState createState() => _MonthlyLineChartState();
}

class _MonthlyLineChartState extends State<MonthlyLineChart> {
  List<_ChartData>? chartData;

  @override
  void initState() {
    super.initState();

    // If widget.data is provided, use it to populate chartData; otherwise, use default sample data
    print(' the data here is like this ${widget.data}');

    chartData = widget.data != null
        ? widget.data!
            .map((data) => _ChartData(DateFormat('M/d/yyyy h:mm:ss a').parse(data.date).day.toString(),
                int.parse(data.helmetViolation), int.parse(data.speedViolation)))
            .toList()
        : <_ChartData>[
            _ChartData('1', 0, 0),
            _ChartData('4', 0, 0),
            _ChartData('7', 0, 0),
            _ChartData('10', 0, 0),
            _ChartData('13', 0, 0),
            _ChartData('16', 0, 0),
            _ChartData('19', 0, 0),
            _ChartData('22', 0, 0),
            _ChartData('25', 0, 0),
            _ChartData('28', 0, 0),
          ];
    chartData = chartData!.reversed.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SfCartesianChart(
        plotAreaBorderWidth: 0,
        // Set the X-axis with labels for days
        primaryXAxis: const CategoryAxis(
          title: AxisTitle(
            text: 'Days', // Label for the X-axis
            textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          majorGridLines: MajorGridLines(width: 0),
          labelRotation: 0, // No rotation for better visibility
          interval: 1, // Show labels for every day
        ),
        // Set the Y-axis with labels for count
        primaryYAxis: const NumericAxis(
          title: AxisTitle(
            text: 'Count', // Label for the Y-axis
            textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          labelFormat: '{value}',
          axisLine: AxisLine(width: 0),
          majorTickLines: MajorTickLines(color: Colors.transparent),
        ),
        series: _getLineSeries(),
        tooltipBehavior: TooltipBehavior(enable: true),
      ),
    );
  }

  List<LineSeries<_ChartData, String>> _getLineSeries() {
    return <LineSeries<_ChartData, String>>[
      LineSeries<_ChartData, String>(
        dataSource: chartData!,
        xValueMapper: (_ChartData data, _) => data.day,
        yValueMapper: (_ChartData data, _) => data.speedViolation,
        name: 'Speed Violation',
        color: AppColors.test3,
        markerSettings: const MarkerSettings(isVisible: true),
      ),
      LineSeries<_ChartData, String>(
        dataSource: chartData!,
        xValueMapper: (_ChartData data, _) => data.day,
        yValueMapper: (_ChartData data, _) => data.speedViolation,
        name: 'Speed Violation',
        color: AppColors.test2,
        markerSettings: const MarkerSettings(isVisible: true),
      ),
    ];
  }
}

class _ChartData {
  _ChartData(this.day, this.helmetViolation, this.speedViolation);
  final String day; // Represents the day of the month (e.g., "1", "4")
  final int helmetViolation; // Represents helmet violation count
  final int speedViolation; // Represents speed violation count
}
