import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:big_dater_project/models/price_date_model.dart';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:big_dater_project/services/prediction_service.dart';

// 상태 클래스
class PastDateState {
  final DateTimeRange dateRange;
  final int page;
  final int limit;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final List<Data> dataList;
  final bool hasReachedEnd;
  final Map<String, List<Data>> pastDataCache;

  PastDateState({
    required this.dateRange,
    required this.page,
    required this.limit,
    required this.isLoading,
    this.isLoadingMore = false,
    required this.error,
    required this.dataList,
    this.hasReachedEnd = false,
    required this.pastDataCache,
  });

  PastDateState copyWith({
    DateTimeRange? dateRange,
    int? page,
    int? limit,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    List<Data>? dataList,
    bool? hasReachedEnd,
    Map<String, List<Data>>? pastDataCache,
  }) {
    return PastDateState(
      dateRange: dateRange ?? this.dateRange,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      dataList: dataList ?? this.dataList,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      pastDataCache: pastDataCache ?? this.pastDataCache,
    );
  }
}

// Notifier
class PastDateNotifier extends StateNotifier<PastDateState> {
  final PredictionService _service;
  PastDateNotifier(this._service)
      : super(PastDateState(
          dateRange: DateTimeRange(
            start: DateTime(2023, 11, 28),
            end: DateTime(2024, 12, 31),
          ),
          page: 1,
          limit: 50,  // 한 번에 더 많은 데이터를 로드
          isLoading: false,
          error: null,
          dataList: [],
          pastDataCache: {},
        )) {
    fetchData();
  }

  String _cacheKey(DateTimeRange range, int page) {
    return '${range.start.toIso8601String()}_${range.end.toIso8601String()}_$page';
  }

  Future<void> fetchData() async {
    final key = _cacheKey(state.dateRange, state.page);
    if (state.pastDataCache.containsKey(key)) {
      final cachedData = state.pastDataCache[key]!;
      // 캐시된 데이터가 비어있으면 끝에 도달한 것으로 처리
      if (cachedData.isEmpty) {
        state = state.copyWith(
          hasReachedEnd: true,
          isLoading: false,
          isLoadingMore: false,
        );
        return;
      }
      
      state = state.copyWith(
        dataList: state.page == 1 
            ? cachedData 
            : [...state.dataList, ...cachedData],
        isLoading: false,
        isLoadingMore: false,
        error: null,
      );
      return;
    }
    
    if (state.page == 1) {
      state = state.copyWith(isLoading: true, error: null);
    } else {
      state = state.copyWith(isLoadingMore: true, error: null);
    }
    
    try {
      final response = await _service.fetchPriceDataRaw(
        state.dateRange.start,
        state.dateRange.end,
      );
      
      print('서버 응답: $response');
      
      final priceDateModel = PriceDateModel.fromJson(response);
      final newData = priceDateModel.data;
      
      // 데이터가 비어있거나 이전 페이지와 동일한 데이터가 있는지 확인
      final hasReachedEnd = newData.isEmpty || 
                           (state.dataList.isNotEmpty && 
                            newData.isNotEmpty && 
                            _containsDuplicates(state.dataList, newData));
      
      final newCache = Map<String, List<Data>>.from(state.pastDataCache);
      newCache[key] = newData;
      
      if (hasReachedEnd) {
        state = state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          hasReachedEnd: true,
          pastDataCache: newCache,
        );
        return;
      }
      
      state = state.copyWith(
        dataList: state.page == 1 
            ? newData 
            : [...state.dataList, ...newData],
        isLoading: false,
        isLoadingMore: false,
        error: null,
        hasReachedEnd: newData.length < state.limit,
        pastDataCache: newCache,
      );
      
      // 자동으로 더 많은 데이터 로드 (첫 페이지에서만)
      if (state.page == 1 && !hasReachedEnd && newData.length > 0 && newData.length >= state.limit) {
        loadMore();
      }
    } catch (e) {
      print('데이터 로드 오류: $e');
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }

  // 중복 데이터 확인 함수
  bool _containsDuplicates(List<Data> existingData, List<Data> newData) {
    for (final newItem in newData) {
      for (final existingItem in existingData) {
        if (newItem.date.isAtSameMomentAs(existingItem.date) && 
            newItem.close == existingItem.close) {
          return true;
        }
      }
    }
    return false;
  }

  void loadMore() {
    if (state.isLoading || state.isLoadingMore || state.hasReachedEnd) return;
    state = state.copyWith(page: state.page + 1);
    fetchData();
  }

  void onDateRangeChange(DateTimeRange? picked) {
    if (picked != null) {
      state = state.copyWith(dateRange: picked, page: 1, dataList: [], hasReachedEnd: false);
      fetchData();
    }
  }
}

final pastDateProvider = StateNotifierProvider<PastDateNotifier, PastDateState>((ref) {
  return PastDateNotifier(PredictionService());
});

class PastDateScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<PastDateScreen> createState() => _PastDateScreenState();
}

class _PastDateScreenState extends ConsumerState<PastDateScreen> {
  final ScrollController _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }
  
  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final notifier = ref.read(pastDateProvider.notifier);
      notifier.loadMore();
    }
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pastDateProvider);
    final notifier = ref.read(pastDateProvider.notifier);
    
    return Container(
      color: Colors.grey[100],
      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '비트코인 과거 데이터',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('기간', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () async {
                      final picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2023, 11, 28),
                        lastDate: DateTime(2024, 12, 31),
                        initialDateRange: state.dateRange,
                        locale: const Locale('ko'),
                      );
                      notifier.onDateRangeChange(picked);
                    },
                    child: Container(
                      width: 250,
                      height: 40,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 12.0),
                              child: Text(
                                '${DateFormat('yyyy.MM.dd').format(state.dateRange.start)} ~ ${DateFormat('yyyy.MM.dd').format(state.dateRange.end)}',
                                style: TextStyle(color: Colors.black, fontSize: 15),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Icon(Icons.arrow_drop_down, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 32),
          if (state.isLoading && state.dataList.isEmpty)
            Expanded(child: Center(child: CircularProgressIndicator())),
          if (state.error != null && state.dataList.isEmpty)
            Expanded(child: Center(child: Text(state.error!, style: TextStyle(color: Colors.red)))),
          if (!state.isLoading || state.dataList.isNotEmpty)
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 데이터 테이블
                  Expanded(
                    flex: 5,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: ListView(
                              controller: _scrollController,
                              children: [
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: DataTable(
                                    headingRowColor: MaterialStateProperty.all(Colors.grey[100]),
                                    columns: [
                                      DataColumn(label: Text('날짜', style: TextStyle(fontWeight: FontWeight.bold))),
                                      DataColumn(label: Text('종가', style: TextStyle(fontWeight: FontWeight.bold))),
                                      DataColumn(label: Text('시가', style: TextStyle(fontWeight: FontWeight.bold))),
                                      DataColumn(label: Text('고가', style: TextStyle(fontWeight: FontWeight.bold))),
                                      DataColumn(label: Text('저가', style: TextStyle(fontWeight: FontWeight.bold))),
                                      DataColumn(label: Text('거래량', style: TextStyle(fontWeight: FontWeight.bold))),
                                      DataColumn(label: Text('시가총액', style: TextStyle(fontWeight: FontWeight.bold))),
                                    ],
                                    rows: state.dataList.map((row) => DataRow(
                                      cells: [
                                        DataCell(Text(DateFormat('yyyy.MM.dd').format(row.date))),
                                        DataCell(Text(NumberFormat('#,###.0').format(row.close), style: TextStyle(color: Colors.red))),
                                        DataCell(Text(NumberFormat('#,###.0').format(row.open))),
                                        DataCell(Text(NumberFormat('#,###.0').format(row.high))),
                                        DataCell(Text(NumberFormat('#,###.0').format(row.low))),
                                        DataCell(Text(NumberFormat('#,###.0').format(row.volume))),
                                        DataCell(Text(NumberFormat('#,###').format(row.marketCap))),
                                      ],
                                    )).toList(),
                                    dataRowHeight: 32,
                                    headingRowHeight: 36,
                                    dividerThickness: 0.5,
                                    horizontalMargin: 12,
                                    columnSpacing: 24,
                                  ),
                                ),
                                if (state.isLoadingMore)
                                  Container(
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    alignment: Alignment.center,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                if (state.hasReachedEnd && state.dataList.isNotEmpty)
                                  Container(
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    alignment: Alignment.center,
                                    child: Text('데이터의 끝입니다.', style: TextStyle(color: Colors.grey)),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 32),
                  // 실제 차트 영역
                  Expanded(
                    flex: 3,
                    child: Container(
                      height: 400,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: _buildCandlestickChart(state.dataList),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCandlestickChart(List<Data> dataList) {
    if (dataList.isEmpty) {
      return Center(child: Text('데이터가 없습니다.'));
    }
    
    // 모든 데이터를 표시 (날짜 순서대로 정렬)
    final chartData = List<Data>.from(dataList)
      ..sort((a, b) => a.date.compareTo(b.date));
    
    // 종가(close) 값을 기준으로 그래프 표시
    final minY = chartData.map((e) => e.close).reduce(min);
    final maxY = chartData.map((e) => e.close).reduce(max);
    
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
    final xLabelInterval = (chartData.length / 5).ceil().toDouble();
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '비트코인 가격 추이',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            '${dateFormatter.format(chartData.first.date)} ~ ${dateFormatter.format(chartData.last.date)}',
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
                        final data = chartData[spot.x.toInt()];
                        return LineTooltipItem(
                          '${dateFormatter.format(data.date)}\n₩${numberFormatter.format(data.close)}',
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
                        if (idx < 0 || idx >= chartData.length || idx % xLabelInterval.toInt() != 0) 
                          return const SizedBox.shrink();
                        final date = chartData[idx].date;
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
                      for (int i = 0; i < chartData.length; i++)
                        FlSpot(i.toDouble(), chartData[i].close),
                    ],
                    isCurved: true,
                    curveSmoothness: 0.3,
                    color: Colors.red,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: chartData.length < 15,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: Colors.white,
                          strokeWidth: 2,
                          strokeColor: Colors.red,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.red.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}