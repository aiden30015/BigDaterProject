import 'package:flutter/material.dart';
import 'package:big_dater_project/screens/prediction_chart_screen.dart';

void main() {
  runApp(CryptoApp());
}

class CryptoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UPJUEN 암호화폐 거래소',
      theme: ThemeData(
        primaryColor: Color(0xFF2A3990),
        fontFamily: 'Jalnan',
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF2A3990),
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF2A3990),
            foregroundColor: Colors.white,
          ),
        ),
      ),
      home: PredictionChartScreen(),
    );
  }
}