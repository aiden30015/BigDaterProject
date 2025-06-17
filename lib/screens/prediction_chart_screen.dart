import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class PredictionChartScreen extends StatefulWidget {
  @override
  _PredictionChartScreenState createState() => _PredictionChartScreenState();
}

class _PredictionChartScreenState extends State<PredictionChartScreen> {
  String selectedPeriod = '일간';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Color(0xFF4A5DB8),
        elevation: 0,
        title: Row(
          spacing: 30,
          children: [
            Text(
              'UPJUEN',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
            ),
            _buildTopMenuItem('과거데이터'),
            _buildTopMenuItem('현재시세'),
            _buildTopMenuItem('AI 동향 예측'),
          ],
        ),
      ),
      body: Row(
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
                  _buildChartHeader(),
                  Expanded(child: _buildCandlestickChart()),
                  _buildVolumeChart(),
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
                _buildDetailInfoPanel(),
                SizedBox(height: 16),
                _buildTechnicalAnalysisPanel(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopMenuItem(String title) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.white,
        fontSize: 16,
      ),
    );
  }

  Widget _buildChartHeader() {
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
              _buildPeriodDropdown(),
              Spacer(),
              _buildResetButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4),
      ),
      child: DropdownButton<String>(
        value: selectedPeriod,
        underline: SizedBox(),
        items: ['일간', '주간', '월간'].map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            selectedPeriod = newValue!;
          });
        },
      ),
    );
  }

  Widget _buildResetButton() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '초기화',
        style: TextStyle(fontSize: 12),
      ),
    );
  }


  Widget _buildPriceItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildCandlestickChart() {
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
                  switch (value.toInt()) {
                    case 0:
                      return Text('2:00', style: TextStyle(fontSize: 10));
                    case 1:
                      return Text('18:00', style: TextStyle(fontSize: 10));
                    case 2:
                      return Text('4/21', style: TextStyle(fontSize: 10));
                    case 3:
                      return Text('6:00', style: TextStyle(fontSize: 10));
                    case 4:
                      return Text('12:00', style: TextStyle(fontSize: 10));
                    case 5:
                      return Text('18:00', style: TextStyle(fontSize: 10));
                    case 6:
                      return Text('4/22', style: TextStyle(fontSize: 10));
                    case 7:
                      return Text('6:00', style: TextStyle(fontSize: 10));
                    default:
                      return Text('');
                  }
                },
              ),
            ),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            // 가격 라인 (빨간색)
            LineChartBarData(
              spots: [
                FlSpot(0, 1),
                FlSpot(1, 0.8),
                FlSpot(2, 0.6),
                FlSpot(3, 1.2),
                FlSpot(4, 2.5),
                FlSpot(5, 2.2),
                FlSpot(6, 2.4),
                FlSpot(7, 2.6),
              ],
              isCurved: false,
              color: Colors.red,
              barWidth: 2,
              dotData: FlDotData(show: false),
            ),
            // 이동평균선 (녹색)
            LineChartBarData(
              spots: [
                FlSpot(0, 0.5),
                FlSpot(1, 0.7),
                FlSpot(2, 0.9),
                FlSpot(3, 1.1),
                FlSpot(4, 1.4),
                FlSpot(5, 1.7),
                FlSpot(6, 2.0),
                FlSpot(7, 2.3),
              ],
              isCurved: true,
              color: Colors.green,
              barWidth: 2,
              dotData: FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVolumeChart() {
    return Container(
      height: 100,
      padding: EdgeInsets.all(16),
      child: BarChart(
        BarChartData(
          titlesData: FlTitlesData(
            show: false,
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(20, (index) {
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: (index % 3 + 1).toDouble(),
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

  Widget _buildDetailInfoPanel() {
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
                    Text('최초발행', style: TextStyle(fontSize: 12)),
                    Text('2009.01', style: TextStyle(fontSize: 12)),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('총 발행한도', style: TextStyle(fontSize: 12)),
                    Text('21,000,000', style: TextStyle(fontSize: 12)),
                  ],
                ),
                SizedBox(height: 16),
                Text(
                  '디지털 자산 소개',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  '비트코인은 나카모토 사토시(가명)가 개발한 기호로 기반으로 하여 개발된 디지털 자산입니다.\n'
                  '기존 화폐와 달리 정부, 중앙은행 등의 금융기관의 개입없이 '
                  '개인들이 온라인 상에서 직접적으로 거래할 수 있습니다.\n'
                  '전 세계 수십만 대의 컴퓨터에 의해 실시간으로 거래내역이 '
                  '검증되고 기록되는 블록체인 기술로 구현됩니다.',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
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