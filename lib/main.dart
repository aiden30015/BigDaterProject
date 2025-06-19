import 'package:big_dater_project/screens/ai_chart_screen.dart';
import 'package:big_dater_project/screens/past_date_screen.dart';
import 'package:flutter/material.dart';
import 'package:big_dater_project/screens/prediction_chart_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(
    ProviderScope(
      child: CryptoApp(),
    ),
  );
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
      title: 'UPJUEON 암호화폐 거래소',
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
      locale: const Locale('ko'),
      supportedLocales: const [
        Locale('en'),
        Locale('ko'),
      ],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF2A3990),
          elevation: 0,
          titleSpacing: 0,
          title: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 24.0),
                child: Text(
                  'UPJUEON',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    fontSize: 32,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              Expanded(
                child: TabBar(
                  controller: _tabController,
                  tabs: [
                    Tab(text: '과거데이터'),
                    Tab(text: '현재시세'),
                    Tab(text: 'AI 동향 예측'),
                  ],
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.transparent,
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  unselectedLabelStyle: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
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