import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:candlesticks/candlesticks.dart';
import 'package:big_dater_project/models/price_date_model.dart';
import 'package:big_dater_project/utils/formatters.dart';
import 'package:fl_chart/fl_chart.dart';

class PriceChart extends StatefulWidget {
  final List<PriceDateModel> predictions;
  final bool isLoading;
  final DateTime startDate;
  final DateTime endDate;
  final Function() onDateRangeSelect;

  const PriceChart({
    Key? key,
    required this.predictions,
    required this.isLoading,
    required this.startDate,
    required this.endDate,
    required this.onDateRangeSelect,
  }) : super(key: key);

  @override
  State<PriceChart> createState() => _PriceChartState();
}

class _PriceChartState extends State<PriceChart> {
  bool _showCandleSticks = true;
  List<Candle> _candles = [];
  
  @override
  void initState() {
    super.initState();
    _updateCandleData();
  }
  
  @override
  void didUpdateWidget(PriceChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.predictions != widget.predictions) {
      _updateCandleData();
    }
  }
  
  void _updateCandleData() {
    if (widget.predictions.isEmpty) {
      _candles = [];
      return;
    }

    // 모든 PriceDateModel의 data(List<Data>)를 합쳐서 하나의 리스트로 만듦
    List<Data> allData = widget.predictions.expand((p) => p.data).toList();

    _candles = allData.map((d) {
      double openPrice = d.open;
      double closePrice = d.close;
      double highPrice = d.high;
      double lowPrice = d.low;
      double volume = d.volume;

      // NaN/Infinity/null 방지
      if (openPrice.isNaN || openPrice.isInfinite) openPrice = 0;
      if (closePrice.isNaN || closePrice.isInfinite) closePrice = 0;
      if (highPrice.isNaN || highPrice.isInfinite) highPrice = 0;
      if (lowPrice.isNaN || lowPrice.isInfinite) lowPrice = 0;
      if (volume.isNaN || volume.isInfinite) volume = 0;

      // high, low 보정
      highPrice = [highPrice, openPrice, closePrice].reduce((curr, next) => curr > next ? curr : next);
      lowPrice = [lowPrice, openPrice, closePrice].reduce((curr, next) => curr < next ? curr : next);

      // 모든 값이 0이거나, high==low==open==close면 Candle 생성하지 않음
      if ([openPrice, closePrice, highPrice, lowPrice].every((v) => v == 0) ||
          (openPrice == closePrice && closePrice == highPrice && highPrice == lowPrice)) {
        return null;
      }

      return Candle(
        date: d.date,
        high: highPrice,
        low: lowPrice,
        open: openPrice,
        close: closePrice,
        volume: volume,
      );
    }).where((candle) => candle != null).cast<Candle>().toList();

    // 날짜 순으로 정렬
    _candles.sort((a, b) => a.date.compareTo(b.date));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    
    if (widget.predictions.isEmpty) {
      return Center(child: Text('데이터가 없습니다. 날짜 범위를 선택해주세요.'));
    }

    // 모든 PriceDateModel의 data(List<Data>)를 합쳐서 하나의 리스트로 만듦
    List<Data> allData = widget.predictions.expand((p) => p.data).toList();
    
    // 차트 타입에 따라 캔들스틱 또는 라인 차트 표시
    return Column(
      children: [
        // 차트 타입 선택 버튼
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              _buildChartTypeButton('캔들', _showCandleSticks, () {
                setState(() => _showCandleSticks = true);
              }),
              SizedBox(width: 8),
              _buildChartTypeButton('라인', !_showCandleSticks, () {
                setState(() => _showCandleSticks = false);
              }),
              Spacer(),
              // 날짜 범위 표시
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 1,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      allData.isNotEmpty
                        ? '${Formatters.formatDate(allData.first.date)} ~ ${Formatters.formatDate(allData.last.date)}'
                        : '',
                      style: TextStyle(fontSize: 12),
                    ),
                    SizedBox(width: 8),
                    InkWell(
                      onTap: widget.onDateRangeSelect,
                      child: Icon(Icons.date_range, size: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // 차트 영역
        Expanded(
          child: _showCandleSticks 
            ? _buildCandleStickChart() 
            : _buildLineChart(allData),
        ),
      ],
    );
  }
  
  Widget _buildCandleStickChart() {
    if (_candles.isEmpty) {
      return Center(child: Text('데이터가 없습니다.'));
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Candlesticks(
        candles: _candles,
        onLoadMoreCandles: () async {
          // 추가 데이터 로드가 필요할 때 처리
          // 여기서는 실제 구현 없음
          return;
        },
      ),
    );
  }
  
  Widget _buildLineChart(List<Data> allData) {
    final spots = allData.map((d) {
      double y = d.close > 0 ? d.close : d.open;
      if (y.isNaN || y.isInfinite) y = 0;
      return FlSpot(
        d.date.millisecondsSinceEpoch.toDouble(),
        y,
      );
    }).toList();

    if (spots.isEmpty) {
      return Center(child: Text('데이터가 없습니다.'));
    }

    double minY = double.infinity;
    double maxY = -double.infinity;
    for (var spot in spots) {
      if (spot.y > maxY) maxY = spot.y;
      if (spot.y < minY) minY = spot.y;
    }
    if (minY == double.infinity || maxY == -double.infinity) {
      minY = 0;
      maxY = 1;
    }
    if (minY == maxY) {
      minY -= 1;
      maxY += 1;
    }
    final padding = (maxY - minY) * 0.05;
    minY -= padding;
    maxY += padding;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: LineChart(
        LineChartData(
          minX: spots.first.x,
          maxX: spots.last.x,
          minY: minY,
          maxY: maxY,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false, // 세로 그리드 제거
            horizontalInterval: 20000000, // 가로 그리드 간격 조정
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.shade100, // 그리드 색상 밝게
                strokeWidth: 0.8, // 그리드 두께 감소
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: _calculateDateInterval(allData), // 날짜 간격 최적화
                getTitlesWidget: (value, meta) {
                  final dateTime = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                  return Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: Text(
                      DateFormat('MM/dd').format(dateTime),
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 50,
                interval: 10000000, // 가격 간격 설정
                getTitlesWidget: (value, meta) {
                  return Text(
                    Formatters.formatCurrencyCompact(value),
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(
            show: false, // 테두리 제거
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.3, // 곡선 부드럽게
              color: Color(0xFF2A3990),
              barWidth: 3, // 선 두께 증가
              dotData: FlDotData(show: false), // 점 표시 안함
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF2A3990).withOpacity(0.3),
                    Color(0xFF2A3990).withOpacity(0.05),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (List<LineBarSpot> touchedSpots) {
                return touchedSpots.map((LineBarSpot touchedSpot) {
                  final date = DateTime.fromMillisecondsSinceEpoch(touchedSpot.x.toInt());
                  final price = touchedSpot.y;
                  return LineTooltipItem(
                    '${DateFormat('yyyy-MM-dd').format(date)}\n',
                    TextStyle(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                    children: [
                      TextSpan(
                        text: '${Formatters.formatCurrency(price)} KRW',
                        style: TextStyle(
                          color: Color(0xFF2A3990),
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildChartTypeButton(String text, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF2A3990) : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Color(0xFF2A3990)),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Color(0xFF2A3990),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
  
  // 데이터 포인트 최적화 함수
  List<PriceDateModel> _optimizePredictions() {
    // 사용하지 않으므로 빈 리스트 반환
    return [];
  }
  
  // x축 날짜 간격 계산 함수
  double _calculateDateInterval(List<Data> allData) {
    if (allData.isEmpty || allData.length < 2) {
      return 0;
    }
    
    // 데이터 범위의 기간 계산
    final firstDate = allData.first.date;
    final lastDate = allData.last.date;
    final daysDifference = lastDate.difference(firstDate).inDays;
    
    // 날짜 표시 간격 최적화
    if (daysDifference > 365) {
      return 30 * 24 * 60 * 60 * 1000; // 한 달 간격
    } else if (daysDifference > 180) {
      return 15 * 24 * 60 * 60 * 1000; // 15일 간격
    } else if (daysDifference > 60) {
      return 7 * 24 * 60 * 60 * 1000; // 일주일 간격
    } else if (daysDifference > 30) {
      return 3 * 24 * 60 * 60 * 1000; // 3일 간격
    } else {
      return 24 * 60 * 60 * 1000; // 1일 간격
    }
  }
} 