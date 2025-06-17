// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'predict_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PredictModel _$PredictModelFromJson(Map<String, dynamic> json) => PredictModel(
  status: json['status'] as String,
  predictions: Predictions.fromJson(
    json['predictions'] as Map<String, dynamic>,
  ),
  count: (json['count'] as num).toInt(),
);

Map<String, dynamic> _$PredictModelToJson(PredictModel instance) =>
    <String, dynamic>{
      'status': instance.status,
      'predictions': instance.predictions,
      'count': instance.count,
    };

Predictions _$PredictionsFromJson(Map<String, dynamic> json) => Predictions(
  date: DateTime.parse(json['date'] as String),
  predicted_price: (json['predicted_price'] as num).toDouble(),
);

Map<String, dynamic> _$PredictionsToJson(Predictions instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'predicted_price': instance.predicted_price,
    };
