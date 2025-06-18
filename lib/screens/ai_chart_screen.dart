import 'package:flutter/material.dart';

class AiChartScreen extends StatelessWidget {
  const AiChartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[100],
      child: Center(
        child: Text(
          'AI 동향 예측 화면',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}