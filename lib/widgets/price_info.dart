import 'package:flutter/material.dart';
import 'package:big_dater_project/utils/formatters.dart';

class PriceInfo extends StatelessWidget {
  final double currentPrice;
  final double priceChange;
  final double percentChange;
  final String coinSymbol;

  const PriceInfo({
    Key? key,
    required this.currentPrice,
    required this.priceChange,
    required this.percentChange,
    required this.coinSymbol,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // currentPrice가 0이면 아무것도 렌더링하지 않음
    if (currentPrice == 0) {
      return SizedBox.shrink();
    }
    final isPriceUp = priceChange >= 0;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          backgroundColor: Colors.amber,
          child: Text('₿', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          radius: 16,
        ),
        SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('비트코인', 
              style: TextStyle(
                fontSize: 20, 
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              )
            ),
            Text(coinSymbol, 
              style: TextStyle(
                color: Colors.grey, 
                fontSize: 14,
                letterSpacing: -0.2,
              )
            ),
          ],
        ),
        Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${Formatters.formatCurrency(currentPrice)} KRW',
              style: TextStyle(
                fontSize: 22, 
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            Row(
              children: [
                Icon(
                  isPriceUp ? Icons.arrow_upward : Icons.arrow_downward,
                  color: isPriceUp ? Colors.red : Colors.blue,
                  size: 16,
                ),
                Text(
                  '${isPriceUp ? "+" : ""}${percentChange}% ${Formatters.formatCurrency(priceChange)}',
                  style: TextStyle(
                    color: isPriceUp ? Colors.red : Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

// 시세 정보 위젯
class MarketInfo extends StatelessWidget {
  final double highPrice;
  final double lowPrice;
  final String volume24h;
  final String marketCap;

  const MarketInfo({
    Key? key,
    required this.highPrice,
    required this.lowPrice,
    required this.volume24h,
    required this.marketCap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('시세', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 16),
        
        // 고가/저가
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('고가', style: TextStyle(color: Colors.grey)),
            Text(
              '${Formatters.formatCurrency(highPrice)}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('저가', style: TextStyle(color: Colors.grey)),
            Text(
              '${Formatters.formatCurrency(lowPrice)}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        
        Divider(height: 32),
        
        // 거래량
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('거래량(24H)', style: TextStyle(color: Colors.grey)),
            Text(
              volume24h,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('거래대금(24H)', style: TextStyle(color: Colors.grey)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  marketCap,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'BTC',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

// 코인 세부 정보 위젯
class CoinDetailInfo extends StatelessWidget {
  const CoinDetailInfo({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 세부정보 섹션
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '세부정보',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('최초발행', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  Text('2009.01', style: TextStyle(fontSize: 12)),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('총 발행한도', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  Text('21,000,000', style: TextStyle(fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
        
        SizedBox(height: 16),
        
        // 디지털 자산 설명
        Text(
          '디지털 자산 소개',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          '비트코인은 나카모토 사토시가 개발한 블록체인 기술을 기반으로 개발한 최초의 디지털 자산입니다.',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
        ),
      ],
    );
  }
} 