import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unilever_activo/bloc/cubits/bottom_navigation/bottom_navigation_cubit.dart';

import '../../bloc/states/bottom_navigation/bottom_navigation_state.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BottomNavigationCubit, BottomNavigationState>(
      builder: (context, state) {
        final bottomNavigationCubit = context.read<BottomNavigationCubit>();
        return Scaffold(
            backgroundColor: const Color(0xffC4DFCB),
            appBar: AppBar(
              leading: Icon(
                Icons.menu,
                color: Theme.of(context).primaryColor,
              ),
              title: Text(
                'Geeks For Geeks',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 25,
                  fontWeight: FontWeight.w600,
                ),
              ),
              centerTitle: true,
              backgroundColor: Colors.white,
            ),
            body: bottomNavigationCubit.pages[bottomNavigationCubit.pageIndex],
            bottomNavigationBar: Container(
              height: 60,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    enableFeedback: false,
                    onPressed: () {
                      bottomNavigationCubit.setIndex(0);
                    },
                    icon: state is ManageProfileState
                        ? const Icon(
                            Icons.home_filled,
                            color: Colors.white,
                            size: 35,
                          )
                        : const Icon(
                            Icons.home_outlined,
                            color: Colors.white,
                            size: 35,
                          ),
                  ),
                  IconButton(
                    enableFeedback: false,
                    onPressed: () {
                      bottomNavigationCubit.setIndex(1);
                    },
                    icon: state is HelmetConnectedState
                        ? const Icon(
                            Icons.work_rounded,
                            color: Colors.white,
                            size: 35,
                          )
                        : const Icon(
                            Icons.work_outline_outlined,
                            color: Colors.white,
                            size: 35,
                          ),
                  ),
                  IconButton(
                    enableFeedback: false,
                    onPressed: () {
                      bottomNavigationCubit.setIndex(2);
                    },
                    icon: state is StatsState
                        ? const Icon(
                            Icons.widgets_rounded,
                            color: Colors.white,
                            size: 35,
                          )
                        : const Icon(
                            Icons.widgets_outlined,
                            color: Colors.white,
                            size: 35,
                          ),
                  ),
                  IconButton(
                    enableFeedback: false,
                    onPressed: () {
                      bottomNavigationCubit.setIndex(3);
                    },
                    icon: state is SOSState
                        ? const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 35,
                          )
                        : const Icon(
                            Icons.person_outline,
                            color: Colors.white,
                            size: 35,
                          ),
                  ),
                ],
              ),
            ));
      },
    );
  }

  Container buildMyNavBar(BuildContext context, BottomNavigationCubit cubit, BottomNavigationState state) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            enableFeedback: false,
            onPressed: () {
              cubit.setIndex(0);
            },
            icon: state is ManageProfileState
                ? const Icon(
                    Icons.home_filled,
                    color: Colors.white,
                    size: 35,
                  )
                : const Icon(
                    Icons.home_outlined,
                    color: Colors.white,
                    size: 35,
                  ),
          ),
          IconButton(
            enableFeedback: false,
            onPressed: () {
              cubit.setIndex(1);
            },
            icon: state is HelmetConnectedState
                ? const Icon(
                    Icons.work_rounded,
                    color: Colors.white,
                    size: 35,
                  )
                : const Icon(
                    Icons.work_outline_outlined,
                    color: Colors.white,
                    size: 35,
                  ),
          ),
          IconButton(
            enableFeedback: false,
            onPressed: () {
              cubit.setIndex(2);
            },
            icon: state is StatsState
                ? const Icon(
                    Icons.widgets_rounded,
                    color: Colors.white,
                    size: 35,
                  )
                : const Icon(
                    Icons.widgets_outlined,
                    color: Colors.white,
                    size: 35,
                  ),
          ),
          IconButton(
            enableFeedback: false,
            onPressed: () {
              cubit.setIndex(3);
            },
            icon: state is SOSState
                ? const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 35,
                  )
                : const Icon(
                    Icons.person_outline,
                    color: Colors.white,
                    size: 35,
                  ),
          ),
        ],
      ),
    );
  }
}

class ManageProfile extends StatelessWidget {
  const ManageProfile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xffC4DFCB),
      child: Center(
        child: Text(
          'Page Number 1',
          style: TextStyle(
            color: Colors.green[900],
            fontSize: 45,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class HelmetConnected extends StatelessWidget {
  const HelmetConnected({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xffC4DFCB),
      child: Center(
        child: Text(
          "Page Number 2",
          style: TextStyle(
            color: Colors.green[900],
            fontSize: 45,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class Stats extends StatelessWidget {
  const Stats({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xffC4DFCB),
      child: Center(
        child: Text(
          'Page Number 3',
          style: TextStyle(
            color: Colors.green[900],
            fontSize: 45,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class SOS extends StatelessWidget {
  const SOS({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xffC4DFCB),
      child: Center(
        child: Text(
          'Page Number 4',
          style: TextStyle(
            color: Colors.green[900],
            fontSize: 45,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
