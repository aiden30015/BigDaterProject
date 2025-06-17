// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'price_date_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PriceDateModel _$PriceDateModelFromJson(Map<String, dynamic> json) =>
    PriceDateModel(
      status: json['status'] as String,
      data: Data.fromJson(json['data'] as Map<String, dynamic>),
      count: (json['count'] as num).toInt(),
    );

Map<String, dynamic> _$PriceDateModelToJson(PriceDateModel instance) =>
    <String, dynamic>{
      'status': instance.status,
      'data': instance.data,
      'count': instance.count,
    };

Data _$DataFromJson(Map<String, dynamic> json) => Data(
  date: DateTime.parse(json['date'] as String),
  open: (json['open'] as num).toDouble(),
  high: (json['high'] as num).toDouble(),
  low: (json['low'] as num).toDouble(),
  close: (json['close'] as num).toDouble(),
  volume: (json['volume'] as num).toDouble(),
  marketCap: (json['marketCap'] as num).toDouble(),
);

Map<String, dynamic> _$DataToJson(Data instance) => <String, dynamic>{
  'date': instance.date.toIso8601String(),
  'open': instance.open,
  'high': instance.high,
  'low': instance.low,
  'close': instance.close,
  'volume': instance.volume,
  'marketCap': instance.marketCap,
};
