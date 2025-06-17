import 'package:json_annotation/json_annotation.dart';

part 'predict_model.g.dart';

@JsonSerializable()
class PredictModel {
  final String status;
  final Predictions predictions;
  final int count;

  PredictModel({required this.status, required this.predictions, required this.count});

  factory PredictModel.fromJson(Map<String, dynamic> json) => _$PredictModelFromJson(json);

  Map<String, dynamic> toJson() => _$PredictModelToJson(this);
}

  @JsonSerializable()
  class Predictions {
    final DateTime date;
    final double predicted_price;

    Predictions({required this.date, required this.predicted_price});

    factory Predictions.fromJson(Map<String, dynamic> json) => _$PredictionsFromJson(json);

    Map<String, dynamic> toJson() => _$PredictionsToJson(this);
  }