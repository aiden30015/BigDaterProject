import 'package:json_annotation/json_annotation.dart';

part 'price_date_model.g.dart';

@JsonSerializable()
class PriceDateModel {
  final String status;
  final Data data;
  final int count; 

  PriceDateModel({required this.status, required this.data, required this.count});

  factory PriceDateModel.fromJson(Map<String, dynamic> json) => _$PriceDateModelFromJson(json);

  Map<String, dynamic> toJson() => _$PriceDateModelToJson(this);

}

@JsonSerializable()
class Data {
  final DateTime date;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;
  final double marketCap;

  Data({required this.date, required this.open, required this.high, required this.low, required this.close, required this.volume, required this.marketCap});

  factory Data.fromJson(Map<String, dynamic> json) => _$DataFromJson(json);

  Map<String, dynamic> toJson() => _$DataToJson(this);
}