import 'package:big_dater_project/services/prediction_service.dart';
import 'package:big_dater_project/models/price_date_model.dart';
import 'package:big_dater_project/models/predict_model.dart';
import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';

class PredictionState {
  final PriceDateModel? priceDateModel;
  final bool isLoading;
  final String? error;
  final DateTimeRange dateRange;
  final List<Predictions> predictions;

  PredictionState({
    this.priceDateModel,
    required this.isLoading,
    required this.dateRange,
    this.error,
    this.predictions = const [],
  });

  PredictionState copyWith({
    PriceDateModel? priceDateModel,
    bool? isLoading,
    String? error,
    DateTimeRange? dateRange,
    List<Predictions>? predictions,
  }) {
    return PredictionState(
      priceDateModel: priceDateModel ?? this.priceDateModel,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      dateRange: dateRange ?? this.dateRange,
      predictions: predictions ?? this.predictions,
    );
  }
}

class PredictionNotifier extends StateNotifier<PredictionState> {
  final PredictionService _service;

  PredictionNotifier(this._service)
      : super(PredictionState(
          priceDateModel: null,
          isLoading: true,
          dateRange: DateTimeRange(
            start: DateTime(2023, 11, 28),
            end: DateTime(2024, 12, 31),
          ),
        )) {
    fetchLstmPredictions();
  }

  Future<void> fetch() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _service.fetchPriceDataRaw(state.dateRange.start, state.dateRange.end);
      final priceDateModel = PriceDateModel.fromJson(response);
      state = state.copyWith(
        priceDateModel: priceDateModel,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> fetchPredictions(DateTime startDate, DateTime endDate) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final predictions = await _service.fetchPredictions(startDate, endDate);
      state = state.copyWith(
        predictions: predictions,
        dateRange: DateTimeRange(start: startDate, end: endDate),
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> fetchLstmPredictions() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final predictions = await _service.fetchLstmPredictions();
      
      if (predictions.isNotEmpty) {
        final startDate = predictions.first.date;
        final endDate = predictions.last.date;
        
        state = state.copyWith(
          predictions: predictions,
          dateRange: DateTimeRange(start: startDate, end: endDate),
          isLoading: false,
          error: null,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: "예측 데이터를 가져올 수 없습니다.",
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void updateDateRange(DateTimeRange newRange) {
    state = state.copyWith(dateRange: newRange);
    fetch();
  }
}

final predictionProvider = StateNotifierProvider<PredictionNotifier, PredictionState>((ref) {
  return PredictionNotifier(PredictionService());
}); 