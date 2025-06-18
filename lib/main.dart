import 'package:big_dater_project/screens/ai_chart_screen.dart';
import 'package:big_dater_project/screens/past_date_screen.dart';
import 'package:flutter/material.dart';
import 'package:big_dater_project/screens/prediction_chart_screen.dart';

void main() {
  runApp(CryptoApp());
}

class CryptoApp extends StatefulWidget {
  @override
  _CryptoAppState createState() => _CryptoAppState();
}

class _CryptoAppState extends State<CryptoApp> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF4A5DB8),
          elevation: 0,
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: '과거데이터'),
              Tab(text: '현재시세'),
              Tab(text: 'AI 동향 예측'),
            ],
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            PastDateScreen(),
            PredictionChartScreen(),
            AiChartScreen(),
          ],
        ),
      ),
    );
  }
}