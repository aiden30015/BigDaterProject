import 'package:intl/intl.dart';

class Formatters {
  // 날짜 포맷 함수
  static String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }
  
  // 통화 포맷 함수 (전체 표시)
  static String formatCurrency(double value) {
    return NumberFormat('#,###', 'ko_KR').format(value);
  }
  
  // 통화 포맷 함수 (간소화)
  static String formatCurrencyCompact(double value) {
    if (value >= 1000000000) {
      return NumberFormat('#,###.##', 'ko_KR').format(value / 1000000000) + 'B';
    } else if (value >= 1000000) {
      return NumberFormat('#,###.##', 'ko_KR').format(value / 1000000) + 'M';
    } else if (value >= 1000) {
      return NumberFormat('#,###.##', 'ko_KR').format(value / 1000) + 'K';
    } else {
      return NumberFormat('#,###.##', 'ko_KR').format(value);
    }
  }
  
  // 백분율 포맷 함수
  static String formatPercent(double value) {
    return NumberFormat('+#,##0.00;-#,##0.00', 'ko_KR').format(value) + '%';
  }
  
  // 짧은 날짜 형식 (예: 01/01)
  static String formatShortDate(DateTime date) {
    final formatter = DateFormat('MM/dd');
    return formatter.format(date);
  }
} 