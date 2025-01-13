// To parse this JSON data, do
//
//     final graphDataModel = graphDataModelFromJson(jsonString);

import 'dart:convert';

List<GraphDataModel> graphDataModelFromJson(String str) =>
    List<GraphDataModel>.from(json.decode(str).map((x) => GraphDataModel.fromJson(x)));

String graphDataModelToJson(List<GraphDataModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GraphDataModel {
  String date;
  String helmetViolation;
  String speedViolation;

  GraphDataModel({
    required this.date,
    required this.helmetViolation,
    required this.speedViolation,
  });

  factory GraphDataModel.fromJson(Map<String, dynamic> json) => GraphDataModel(
        date: json["date"],
        helmetViolation: json["helmetViolation"],
        speedViolation: json["speedViolation"],
      );

  Map<String, dynamic> toJson() => {
        "date": date,
        "helmetViolation": helmetViolation,
        "speedViolation": speedViolation,
      };
}
