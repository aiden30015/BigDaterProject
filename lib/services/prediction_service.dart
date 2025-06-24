import 'dart:convert';
import 'package:big_dater_project/models/price_date_model.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:big_dater_project/models/predict_model.dart';

class PredictionService {
  final Dio _dio = Dio();
  
  // 서버 기본 URL
  static const String baseUrl = 'http://127.0.0.1:8000';

  // LSTM 모델 예측 데이터 가져오기
  Future<List<Predictions>> fetchLstmPredictions() async {
    try {
      final response = await _dio.get('$baseUrl/predict');
      
      if (response.statusCode == 200) {
        print('LSTM 예측 응답: ${response.data}');
        
        if (response.data == null) {
          return [];
        }
        
        // API 응답 형식에 맞게 파싱
        final Map<String, dynamic> data = response.data;
        
        if (data.containsKey('predictions') && data['predictions'] is List) {
          List<dynamic> predictions = data['predictions'];
          return predictions.map<Predictions>((item) {
            return Predictions(
              date: DateTime.parse(item['date']),
              predicted_price: double.parse(item['predicted_price'].toString()),
            );
          }).toList();
        }
      }
    } catch (e) {
      print('LSTM 예측 데이터 가져오기 오류: $e');
    }
    return [];
  }

  // 예측 데이터 가져오기
  Future<List<Predictions>> fetchPredictions(DateTime startDate, DateTime endDate) async {
    try {
      // 서버에 날짜 범위 요청
      print('서버 요청: $baseUrl/predict?start_date=${startDate.toIso8601String().split('T')[0]}&end_date=${DateFormat('yyyy-MM-dd').format(endDate)}');
      
      final response = await _dio.get(
        '$baseUrl/predict',
        queryParameters: {
          'start_date': startDate.toIso8601String(),
          'end_date': endDate.toIso8601String(),
        },
      );

      if (response.statusCode == 200) {
        print('서버 응답 성공: ${response.data}');
        
        // 서버 응답이 비어있는 경우 빈 리스트 반환
        if (response.data == null) {
          print('응답 데이터가 null입니다.');
          return [];
        }
        
        // 새로운 API 응답 형식 처리
        if (response.data is Map<String, dynamic> && response.data.containsKey('timestamp')) {
          // 단일 예측 결과 객체인 경우
          return [Predictions.fromJson(response.data as Map<String, dynamic>)];
        } 
        // 기존 응답 형식 처리
        else if (response.data is List) {
          List<dynamic> data = response.data;
          return data.map<Predictions>((item) {
            try {
              // 새로운 형식인지 확인
              if (item is Map && item.containsKey('timestamp')) {
                return Predictions.fromJson(item as Map<String, dynamic>);
              }
              // 기존 형식 처리
              return Predictions.fromJson({
                'date': item['date'].toString(),
                'predicted_price': double.parse(item['predicted_price'].toString()),
              });
            } catch (e) {
              print('항목 변환 오류: $e');
              return Predictions(
                date: DateTime.now(),
                predicted_price: 0,
              );
            }
          }).toList();
        } else if (response.data is Map) {
          // 단일 객체인 경우
          try {
            Map<String, dynamic> mapData = Map<String, dynamic>.from(response.data);
            // 새로운 형식인지 확인
            if (mapData.containsKey('timestamp')) {
              return [Predictions.fromJson(mapData)];
            }
            // 기존 형식 처리
            return [
              Predictions.fromJson({
                'date': mapData['date'].toString(),
                'predicted_price': double.parse(mapData['predicted_price'].toString()),
              })
            ];
          } catch (e) {
            print('단일 객체 변환 오류: $e');
            return [];
          }
        } else if (response.data is String) {
          // 문자열인 경우 (JSON 문자열일 수 있음)
          try {
            var jsonData = jsonDecode(response.data);
            if (jsonData is List) {
              return jsonData.map<Predictions>((item) {
                // 새로운 형식인지 확인
                if (item is Map && item.containsKey('timestamp')) {
                  return Predictions.fromJson(Map<String, dynamic>.from(item));
                }
                // 기존 형식 처리
                return Predictions.fromJson({
                  'date': item['date'].toString(),
                  'predicted_price': double.parse(item['predicted_price'].toString()),
                });
              }).toList();
            } else if (jsonData is Map) {
              Map<String, dynamic> mapData = Map<String, dynamic>.from(jsonData);
              // 새로운 형식인지 확인
              if (mapData.containsKey('timestamp')) {
                return [Predictions.fromJson(mapData)];
              }
              // 기존 형식 처리
              return [
                Predictions.fromJson({
                  'date': mapData['date'].toString(),
                  'predicted_price': double.parse(mapData['predicted_price'].toString()),
                })
              ];
            }
          } catch (e) {
            print('JSON 파싱 오류: $e');
          }
          return [];
        }
      }
    } catch (e) {
      print('예측 데이터 가져오기 오류: $e');
      return [];
    }
    return [];
  }

  Future<Map<String, dynamic>> fetchPriceDataRaw(DateTime startDate, DateTime endDate, {int? limit, int? page}) async {
    final params = {
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
    };
    
    if (limit != null) {
      params['limit'] = limit.toString();
    }
    
    if (page != null) {
      params['page'] = page.toString();
    }
    
    final response = await _dio.get(
      '$baseUrl/data',
      queryParameters: params,
    );
    return response.data;
  }
}