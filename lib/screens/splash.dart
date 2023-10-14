import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unilever_activo/bloc/cubits/splash_cubits/splash_cubit.dart';

import 'package:unilever_activo/utils/assets.dart';
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
                    text: "Smart Helmet (Activo)",
                    color: Theme.of(context).textTheme.displayLarge?.color,
                    fontSize: 18,
                  ),
                ],
              ),
            ),
          );
        });
  }
}
