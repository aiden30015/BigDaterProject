import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:big_dater_project/models/predict_model.dart';

class PredictionService {
  final Dio _dio = Dio();
  
  // 서버 기본 URL
  static const String baseUrl = 'http://127.0.0.1:8000';

  // 예측 데이터 가져오기
  Future<List<Predictions>> fetchPredictions(DateTime startDate, DateTime endDate) async {
    try {
      // 서버에 날짜 범위 요청
      print('서버 요청: $baseUrl/predict?start_date=${startDate.toIso8601String().split('T')[0]}&end_date=${DateFormat('yyyy-MM-dd').format(endDate)}');
      
      final response = await _dio.get(
        '$baseUrl/predict',
        queryParameters: {
          'start_date': startDate.toIso8601String().split('T')[0], // YYYY-MM-DD 형식으로 변환
          'end_date': DateFormat('yyyy-MM-dd').format(endDate),
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
        } else {
          print('예상치 못한 응답 형식: ${response.data.runtimeType}');
          // 임시 데이터 생성 (테스트용)
          return _generateSampleData(startDate, endDate);
        }
      } else {
        print('서버 응답 오류: ${response.statusCode}');
        // 임시 데이터 생성 (테스트용)
        return _generateSampleData(startDate, endDate);
      }
    } on DioException catch (e) {
      print('DioException: ${e.message}');
      if (e.response != null) {
        print('Response data: ${e.response!.data}');
      }
      // 임시 데이터 생성 (테스트용)
      return _generateSampleData(startDate, endDate);
    } catch (e) {
      print('General Error: $e');
      // 임시 데이터 생성 (테스트용)
      return _generateSampleData(startDate, endDate);
    }
  }

  // 테스트용 샘플 데이터 생성 함수
    List<Predictions> _generateSampleData(DateTime startDate, DateTime endDate) {
    List<Predictions> sampleData = [];
    
    // 시작일부터 종료일까지 날짜별 데이터 생성
    DateTime currentDate = startDate;
    int dayCount = 0;
    
    while (currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
      // 125,000,000에서 시작하여 점진적으로 증가 (약간의 랜덤성 추가)
      double basePrice = 125000000 + (dayCount * 100000);
      double randomFactor = (dayCount % 2 == 0) ? 1.0 + (dayCount * 0.001) : 1.0 - (dayCount * 0.0005);
      double price = basePrice * randomFactor;
      
      // 새로운 필드 추가
      double open = price * 0.98;
      double high = price * 1.05;
      double low = price * 0.95;
      double close = price;
      double volume = 50000000000 + (dayCount * 1000000000);
      double marketCap = 2500000000000 + (dayCount * 10000000000);
      
      sampleData.add(Predictions(
        date: currentDate,
        predicted_price: price,
      ));
      
      // 다음날로 이동
      currentDate = currentDate.add(Duration(days: 1));
      dayCount++;
    }
    
    return sampleData;
  }
} 