import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:unilever_activo/bloc/cubits/splash_cubits/splash_cubit.dart';
import 'package:unilever_activo/navigations/navigation_helper.dart';
import 'package:unilever_activo/utils/app_colors.dart';
import 'package:unilever_activo/utils/assets.dart';
import 'package:unilever_activo/utils/widgets/app_button.dart';
import 'package:unilever_activo/utils/widgets/app_space.dart';
import 'package:unilever_activo/utils/widgets/app_text.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      try {
        await internetOffDialog();
        await locationPermissionDialog().then(
          (value) => BlocProvider.of<SplashCubit>(context).initState(),
        );
      } catch (e) {
        log('$e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocConsumer<SplashCubit, int?>(
      listener: (context, state) {},
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          body: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Image.asset(
                    AssetsPath.appLogo,
                    // height: size.height * 0.5,
                    width: size.width * 0.4,
                  ),
                ),
                AppSpace.vrtSpace(15),
                AppText(
                  text: 'Smart Helmet (Activo)',
                  color: Theme.of(context).textTheme.displayLarge?.color,
                  fontSize: 18,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> locationPermissionDialog() async {
    if (await Permission.locationWhenInUse.isGranted) return;

    await showAdaptiveDialog(
      context: context,
      builder: (context) {
        return AlertDialog.adaptive(
          title: const AppText(
            text: 'Unilever Activo needs to access your location only to maintain the safety of riders. Would you like '
                'to '
                'proceed?',
            weight: FontWeight.w500,
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            const AppButton(
              backgroundColor: AppColors.red,
              onPressed: pop,
              child: AppText(
                text: 'NO',
                color: AppColors.white,
              ),
            ),
            AppButton(
              backgroundColor: AppColors.green,
              onPressed: () async {
                await [
                  Permission.locationWhenInUse,
                ].request().then((value) => pop());
              },
              child: const AppText(
                text: 'Allow',
                color: AppColors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  Future<dynamic> internetOffDialog() async {
    final connection = await Connectivity().checkConnectivity();
    if (connection == ConnectivityResult.none) {
      return showAdaptiveDialog(
        context: context,
        builder: (context) {
          return AlertDialog.adaptive(
            actionsAlignment: MainAxisAlignment.spaceEvenly,
            actions: [
              ElevatedButton(
                onPressed: () {
                  pop();
                },
                child: const AppText(text: 'Close'),
              ),
            ],
            title: const AppText(
              text: 'Internet is off. Please connect to a Network.',
              weight: FontWeight.w500,
              textAlign: TextAlign.center,
            ),
          );
        },
      );
    } else {
      return;
    }
  }
}
