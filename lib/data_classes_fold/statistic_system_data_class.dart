import 'dart:convert';

List<StatisticSystemDataClass> statisticSystemDataClassFromJson(String str) =>
    List<StatisticSystemDataClass>.from(json.decode(str).map((x) => StatisticSystemDataClass.fromJson(x)));

String statisticSystemDataClassToJson(List<StatisticSystemDataClass> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class StatisticSystemDataClass {
  String currency;
  int totalBuy;
  double avgBuy;
  int totalSell;
  double avgSell;
  double profit;

  StatisticSystemDataClass({
    required this.currency,
    required this.totalBuy,
    required this.avgBuy,
    required this.totalSell,
    required this.avgSell,
    required this.profit,
  });

  factory StatisticSystemDataClass.fromJson(Map<String, dynamic> json) =>
      StatisticSystemDataClass(
        currency: json["currency"],
        totalBuy: json["total_buy"],
        avgBuy: json["avg_buy"].toDouble(),  // Обработка значений как double
        totalSell: json["total_sell"],
        avgSell: json["avg_sell"].toDouble(),  // Обработка значений как double
        profit: json["profit"].toDouble(),    // Обработка значений как double
      );

  Map<String, dynamic> toJson() => {
    "currency": currency,
    "total_buy": totalBuy,
    "avg_buy": avgBuy,
    "total_sell": totalSell,
    "avg_sell": avgSell,
    "profit": profit,
  };
}
