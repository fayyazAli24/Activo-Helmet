// To parse this JSON data, do
//
//     final deviceReqBodyModel = deviceReqBodyModelFromJson(jsonString);

import 'dart:convert';

DeviceReqBodyModel deviceReqBodyModelFromJson(String str) => DeviceReqBodyModel.fromJson(json.decode(str));

String deviceReqBodyModelToJson(DeviceReqBodyModel data) => json.encode(data.toJson());

class DeviceReqBodyModel {
  String? helmetId;
  String? userId;
  DateTime? apiDateTime;
  double? latitude;
  double? longitude;
  int? isWearHelmet;
  int? isWrongWay;
  DateTime? savedTime;
  double? speed;
  int? synced;
  String? vehicleType;
  String? createdBy;
  String? updatedBy;

  DeviceReqBodyModel({
    this.helmetId,
    this.userId,
    this.apiDateTime,
    this.latitude,
    this.longitude,
    this.synced,
    this.isWearHelmet,
    this.isWrongWay,
    this.speed,
    this.savedTime,
    this.vehicleType,
    this.createdBy,
    this.updatedBy,
  });

  factory DeviceReqBodyModel.fromJson(Map<String, dynamic> json) => DeviceReqBodyModel(
        helmetId: json['Helmet_ID'],
        userId: json['User_Id'],
        apiDateTime: json['API_DateTime'] == null ? null : DateTime.parse(json['API_DateTime']),
        latitude: json['Latitude']?.toDouble(),
        longitude: json['Longitude']?.toDouble(),
        synced: json['synced'],
        isWearHelmet: json['Is_Wear_Helmet'],
        isWrongWay: json['Is_Wrong_Way'],
        savedTime: DateTime.parse(json['savedTime']),
        speed: json['speed'],
        vehicleType: json['VehicleType'],
        createdBy: json['Created_By'],
        updatedBy: json['Updated_By'],
      );

  Map<String, dynamic> toJson() => {
        'Helmet_ID': helmetId,
        'User_Id': userId,
        'API_DateTime': apiDateTime?.toIso8601String(),
        'Latitude': latitude,
        'Longitude': longitude,
        'Is_Wear_Helmet': isWearHelmet,
        'savedTime': savedTime?.toIso8601String(),
        'Is_Wrong_Way': isWrongWay,
        'speed': speed,
        'synced': synced,
        'VehicleType': vehicleType,
        'Created_By': createdBy,
        'Updated_By': updatedBy,
      };
}
