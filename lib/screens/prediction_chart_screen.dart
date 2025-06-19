import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:big_dater_project/providers/prediction_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:big_dater_project/models/price_date_model.dart';

class PredictionChartScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(predictionProvider);
    final notifier = ref.read(predictionProvider.notifier);
    final dataList = state.priceDateModel?.data ?? [];

    if (state.isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    if (state.error != null) {
      return Center(child: Text(state.error!));
    }
    return Container(
      color: Colors.grey[100],
      child: Row(
        children: [
          // 왼쪽 메인 차트 영역
          Expanded(
            flex: 3,
            child: Container(
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildChartHeader(context, notifier, state),
                  Expanded(child: _buildCandlestickChart(dataList)),
                  _buildVolumeChart(dataList),
                ],
              ),
            ),
          ),
          // 오른쪽 정보 패널
          Container(
            width: 300,
            margin: EdgeInsets.only(top: 16, right: 16, bottom: 16),
            child: Column(
              children: [
                _buildDetailInfoPanel(dataList),
                SizedBox(height: 16),
                _buildTechnicalAnalysisPanel(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartHeader(BuildContext context, PredictionNotifier notifier, PredictionState state) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '기간',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 16),
              // 기간 드롭다운은 생략 또는 필요시 구현
              SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () async {
                  final now = DateTime.now();
                  final picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(now.year - 5),
                    lastDate: now,
                    initialDateRange: state.dateRange,
                    locale: const Locale('ko'),
                  );
                  if (picked != null) {
                    notifier.updateDateRange(picked);
                  }
                },
                icon: Icon(Icons.date_range, size: 18),
                label: Text(
                  state.dateRange == null
                    ? '날짜 선택'
                    : '${DateFormat('yyyy.MM.dd').format(state.dateRange.start)} ~ ${DateFormat('yyyy.MM.dd').format(state.dateRange.end)}',
                  style: TextStyle(fontSize: 13),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2A3990),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  textStyle: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Spacer(),
              // 초기화 버튼
              InkWell(
                onTap: () {
                  notifier.updateDateRange(DateTimeRange(
                    start: DateTime(2023, 11, 28),
                    end: DateTime(2024, 12, 31),
                  ));
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '초기화',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCandlestickChart(List<Data> dataList) {
    if (dataList.isEmpty) {
      return Center(child: Text('데이터가 없습니다.'));
    }
    return Container(
      height: 300,
      padding: EdgeInsets.all(16),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  int idx = value.toInt();
                  if (idx < 0 || idx >= dataList.length) return Text('');
                  final date = dataList[idx].date;
                  return Text(DateFormat('MM/dd').format(date), style: TextStyle(fontSize: 10));
                },
              ),
            ),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            // 예측 가격 라인
            LineChartBarData(
              spots: [
                for (int i = 0; i < dataList.length; i++)
                  FlSpot(i.toDouble(), dataList[i].open),
              ],
              isCurved: false,
              color: Colors.red,
              barWidth: 2,
              dotData: FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVolumeChart(List<Data> dataList) {
    return Container(
      height: 100,
      padding: EdgeInsets.all(16),
      child: BarChart(
        BarChartData(
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(dataList.length, (index) {
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: (dataList[index].open % 3) + 1,
                  color: index % 2 == 0 ? Colors.red : Colors.blue,
                  width: 4,
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildDetailInfoPanel(List<Data> dataList) {
    final latest = dataList.isNotEmpty ? dataList.last : null;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFF4A5DB8),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Text(
              '세부정보',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('날짜', style: TextStyle(fontSize: 12)),
                    Text(latest != null ? DateFormat('yyyy.MM.dd').format(latest.date) : '-', style: TextStyle(fontSize: 12)),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('시가', style: TextStyle(fontSize: 12)),
                    Text(latest != null ? latest.open.toStringAsFixed(0) : '-', style: TextStyle(fontSize: 12)),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('고가', style: TextStyle(fontSize: 12)),
                    Text(latest != null ? latest.high.toStringAsFixed(0) : '-', style: TextStyle(fontSize: 12)),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('저가', style: TextStyle(fontSize: 12)),
                    Text(latest != null ? latest.low.toStringAsFixed(0) : '-', style: TextStyle(fontSize: 12)),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('종가', style: TextStyle(fontSize: 12)),
                    Text(latest != null ? latest.close.toStringAsFixed(0) : '-', style: TextStyle(fontSize: 12)),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('거래량', style: TextStyle(fontSize: 12)),
                    Text(latest != null ? latest.volume.toStringAsFixed(0) : '-', style: TextStyle(fontSize: 12)),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('시가총액', style: TextStyle(fontSize: 12)),
                    Text(latest != null ? latest.marketCap.toStringAsFixed(0) : '-', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechnicalAnalysisPanel() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFF4A5DB8),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Text(
              '기술적 분석',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '1. 비트코인의 단순 이동평균(SMA) 지표에 따르면, 단기 선이 '
                  '장기 선을 상향 돌파하는 골든 크로스가 형성되어 있습니다. '
                  '이는 긍정적 신호로 해석할 수 있습니다.',
                  style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                ),
                SizedBox(height: 12),
                Text(
                  '2. RSI 지표가 50선을 상회하며 상승하는 모습을 보여주고 있어 '
                  '상승 모멘텀이 강화되고 있는 것으로 판단됩니다. '
                  '하지만 70선 상향 돌파 시 과매수 구간으로의 진입을 주의해야 합니다. '
                  '비트코인은 주간 봉에서 이동평균선 상단에서 지지받는 모습이 뚜렷하게 '
                  '나타나고 있어 중기적 상승 흐름이 이어질 것으로 판단됩니다.',
                  style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}