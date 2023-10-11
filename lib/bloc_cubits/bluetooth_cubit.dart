import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:unilever_activo/utils/widgets/app_text.dart';

enum AppBluetoothState { scanning, scanned, on, off, disconnected, connected, error }

class BluetoothCubit extends Cubit<AppBluetoothState> {
  BluetoothCubit() : super(AppBluetoothState.scanning) {
    checkBluetoothStatus();
    startScan();
  }
  Set<BluetoothDevice> seen = {};

  List<ScanResult> devices = [];

  bool scanning = false;
  checkBluetoothStatus() {
    FlutterBluePlus.adapterState.listen((event) async {
      if (event == BluetoothAdapterState.off) {
        if (Platform.isAndroid) {
          await FlutterBluePlus.turnOn();
          emit(AppBluetoothState.on);
        }
      }
    });
  }

  startScan() async {
    scanning = FlutterBluePlus.isScanningNow;

    if (scanning) {
      await FlutterBluePlus.stopScan();
    }

    devices = [];

    await FlutterBluePlus.startScan(
      timeout: const Duration(seconds: 4),
      removeIfGone: const Duration(seconds: 1),
    );
    emit(AppBluetoothState.scanning);

    await getDevices();
  }

  getDevices() async {
    var subscription = FlutterBluePlus.scanResults.listen((results) {
      devices = results;
    });

    emit(AppBluetoothState.scanned);
  }

  snackBar(String msg, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        content: AppText(
          text: msg,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
    );
  }
}
