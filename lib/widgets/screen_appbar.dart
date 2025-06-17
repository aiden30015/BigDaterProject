import 'package:flutter/material.dart';

class ScreenAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
        backgroundColor: Color(0xFF4A5DB8),
        elevation: 0,
        title: Row(
          spacing: 30,
          children: [
            Text(
              'UPJUEON',
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

}