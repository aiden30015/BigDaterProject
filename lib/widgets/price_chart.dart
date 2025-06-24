import 'package:big_dater_project/models/predict_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:big_dater_project/models/price_date_model.dart';
import 'package:big_dater_project/utils/formatters.dart';
import 'dart:math';

class PriceChart extends StatefulWidget {
  final List<Predictions> predictions;
  final bool isLoading;
  final DateTime date;
  final Function() onDateRangeSelect;

  const PriceChart({
    Key? key,
    required this.predictions,
    required this.isLoading,
    required this.date,
    required this.onDateRangeSelect,
  }) : super(key: key);

  @override
  State<PriceChart> createState() => _PriceChartState();
}

class _PriceChartState extends State<PriceChart> {
  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    
    if (widget.predictions.isEmpty) {
      return Center(child: Text('데이터가 없습니다. 날짜 범위를 선택해주세요.'));
    }

    return _buildChart();
  }
  
  Widget _buildChart() {
    try {
      // 무한값이나 NaN 값을 필터링하여 유효한 데이터만 사용
      final validPredictions = widget.predictions.where(
        (p) => p.predicted_price != null && 
               !p.predicted_price.isNaN && 
               !p.predicted_price.isInfinite && 
               p.predicted_price != 0
      ).toList();
      
      if (validPredictions.isEmpty) {
        return Center(child: Text('유효한 데이터가 없습니다.'));
      }
      
      // 날짜 순서대로 정렬
      validPredictions.sort((a, b) => a.date.compareTo(b.date));
      
      // 최소/최대값 계산
      final minY = validPredictions.map((e) => e.predicted_price).reduce(min);
      final maxY = validPredictions.map((e) => e.predicted_price).reduce(max);
      
      // 적절한 범위 설정 (최소값과 최대값 사이에 약간의 여유 공간 추가)
      final range = maxY - minY;
      final padding = range * 0.05; // 5% 여유 공간
      final adjustedMinY = minY - padding;
      final adjustedMaxY = maxY + padding;
      
      // Y축 간격 계산
      final interval = range > 0 ? (range / 5).ceilToDouble() : 1;
      
      // 날짜 포맷터
      final dateFormatter = DateFormat('MM/dd');
      
      // 숫자 포맷터
      final numberFormatter = NumberFormat('#,###');
      
      // 그래프 X축 라벨 간격 계산 (데이터 양에 따라 조정)
      final xLabelInterval = (validPredictions.length / 5).ceil().toDouble();
      
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '비트코인 가격 예측',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '${dateFormatter.format(validPredictions.first.date)}(${validPredictions.first.date.year}) ~ ${dateFormatter.format(validPredictions.last.date)}(${validPredictions.last.date.year})',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            SizedBox(height: 16),
            Expanded(
              child: LineChart(
                LineChartData(
                  minY: adjustedMinY,
                  maxY: adjustedMaxY,
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final index = spot.x.toInt();
                          if (index < 0 || index >= validPredictions.length) {
                            return LineTooltipItem(
                              '오류',
                              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            );
                          }
                          final data = validPredictions[index];
                          return LineTooltipItem(
                            '${dateFormatter.format(data.date)}\n₩${numberFormatter.format(data.predicted_price)}',
                            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          );
                        }).toList();
                      },
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: interval.toDouble(),
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withOpacity(0.2),
                        strokeWidth: 1,
                      );
                    },
                    getDrawingVerticalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withOpacity(0.2),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: xLabelInterval,
                        getTitlesWidget: (value, meta) {
                          int idx = value.toInt();
                          if (idx < 0 || idx >= validPredictions.length || idx % xLabelInterval.toInt() != 0) 
                            return const SizedBox.shrink();
                          final date = validPredictions[idx].date;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              dateFormatter.format(date),
                              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: interval.toDouble(),
                        reservedSize: 60,
                        getTitlesWidget: (value, meta) {
                          if (value < adjustedMinY || value > adjustedMaxY) return const SizedBox.shrink();
                          return Text(
                            numberFormatter.format(value),
                            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                          );
                        },
                      ),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.withOpacity(0.4)),
                      left: BorderSide(color: Colors.grey.withOpacity(0.4)),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        for (int i = 0; i < validPredictions.length; i++)
                          FlSpot(i.toDouble(), validPredictions[i].predicted_price),
                      ],
                      isCurved: true,
                      curveSmoothness: 0.3,
                      color: Color(0xFF2A3990),
                      barWidth: 3,
                      dotData: FlDotData(
                        show: validPredictions.length < 15,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: Colors.white,
                            strokeWidth: 2,
                            strokeColor: Color(0xFF2A3990),
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Color(0xFF2A3990).withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      print('차트 생성 중 오류 발생: $e');
      return Center(child: Text('차트를 표시할 수 없습니다.'));
    }
  }
} 