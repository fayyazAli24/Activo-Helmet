// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
//
// class MyBluetoothDevice {
//   final String remoteId;
//   final String platformName;
//   final List<BluetoothService> services;
//
//   MyBluetoothDevice({
//     required this.remoteId,
//     required this.platformName,
//     required this.services,
//   });
//
//   factory MyBluetoothDevice.fromBluetoothDevice(BluetoothDevice device) {
//     return MyBluetoothDevice(
//       remoteId: device.remoteId.toString(),
//       platformName: device.platformName,
//       services: device.servicesList,
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'remoteId': remoteId,
//       'platformName': platformName,
//       'services': services.map((service) => service.toJson()).toList(),
//     };
//   }
// }
