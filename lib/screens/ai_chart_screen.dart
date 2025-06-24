import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:big_dater_project/models/predict_model.dart';
import 'package:big_dater_project/providers/prediction_provider.dart';
import 'package:big_dater_project/widgets/price_chart.dart';
import 'package:intl/intl.dart';

class AiChartScreen extends ConsumerStatefulWidget {
  const AiChartScreen({super.key});

  @override
  ConsumerState<AiChartScreen> createState() => _AiChartScreenState();
}

class _AiChartScreenState extends ConsumerState<AiChartScreen> {
  @override
  void initState() {
    super.initState();
    // 초기 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPredictionData();
    });
  }

  void _loadPredictionData() {
    final notifier = ref.read(predictionProvider.notifier);
    notifier.fetchLstmPredictions();
  }

  @override
  Widget build(BuildContext context) {
    final predictionState = ref.watch(predictionProvider);
    
    // 예측 방향 계산 (상승/하락)
    String trendDirection = '유지';
    Color trendColor = Colors.grey;
    IconData trendIcon = Icons.trending_flat;
    
    if (predictionState.predictions.length >= 2) {
      final firstPrice = predictionState.predictions.first.predicted_price;
      final lastPrice = predictionState.predictions.last.predicted_price;
      
      if (lastPrice > firstPrice) {
        trendDirection = '상승세';
        trendColor = Colors.red;
        trendIcon = Icons.trending_up;
      } else if (lastPrice < firstPrice) {
        trendDirection = '하락세';
        trendColor = Colors.blue;
        trendIcon = Icons.trending_down;
      }
    }
    
    // 예측 정확도 (고정값)
    const accuracy = '94.8%';
    
    return Container(
      color: Colors.grey[100],
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더 영역
          Row(
            children: [
              Text(
                'AI 비트코인 가격 예측',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 24),
          
          // 정보 카드
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '예측 기간',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        predictionState.dateRange != null
                          ? '${predictionState.dateRange.duration.inDays}일'
                          : '0일',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '예측 방향',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(trendIcon, color: trendColor),
                          SizedBox(width: 4),
                          Text(
                            trendDirection,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: trendColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),
          
          // 차트 영역
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: predictionState.isLoading
                ? Center(child: CircularProgressIndicator())
                : predictionState.predictions.isEmpty
                  ? Center(child: Text('예측 데이터가 없습니다.\n다른 날짜 범위를 선택해주세요.', textAlign: TextAlign.center))
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: PriceChart(
                        date: predictionState.dateRange.start,
                        predictions: predictionState.predictions,
                        isLoading: predictionState.isLoading, 
                        onDateRangeSelect: () {},
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}