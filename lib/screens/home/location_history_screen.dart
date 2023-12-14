import 'package:flutter/material.dart';
import 'package:unilever_activo/utils/app_colors.dart';
import 'package:unilever_activo/utils/widgets/app_text.dart';

class LocationHistoryScreen extends StatefulWidget {
  const LocationHistoryScreen({super.key});

  @override
  State<LocationHistoryScreen> createState() => _LocationHistoryScreenState();
}

class _LocationHistoryScreenState extends State<LocationHistoryScreen> {
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
    );
  }
}
