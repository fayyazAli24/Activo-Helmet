import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    return BlocConsumer<HomeCubit, HomeState>(
      listener: (context, state) {},
      builder: (context, state) {
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
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
