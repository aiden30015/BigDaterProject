// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'price_date_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PriceDateModel _$PriceDateModelFromJson(Map<String, dynamic> json) =>
    PriceDateModel(
      status: json['status'] as String,
      data: (json['data'] as List<dynamic>)
          .map((e) => Data.fromJson(e as Map<String, dynamic>))
          .toList(),
      count: (json['count'] as num).toInt(),
    );

Map<String, dynamic> _$PriceDateModelToJson(PriceDateModel instance) =>
    <String, dynamic>{
      'status': instance.status,
      'data': instance.data,
      'count': instance.count,
    };

Data _$DataFromJson(Map<String, dynamic> json) => Data(
  date: DateTime.parse(json['date']),
  open: (json['open'] ?? 0).toDouble(),
  high: (json['high'] ?? 0).toDouble(),
  low: (json['low'] ?? 0).toDouble(),
  close: (json['close'] ?? 0).toDouble(),
  volume: (json['volume'] ?? 0).toDouble(),
  marketCap: (json['market_cap'] ?? 0).toDouble(),
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
