import 'dart:convert';

List<OperationsSystemDataClass> operationsSystemDataClassListFromJson(String str) {
  final jsonData = json.decode(str);
  return List<OperationsSystemDataClass>.from(
      jsonData.map((x) => OperationsSystemDataClass.fromJson(x))
  );
}

String operationsSystemDataClassToJson(OperationsSystemDataClass data) => json.encode(data.toJson());

class OperationsSystemDataClass {
  int id;
  DateTime time;
  String trade;
  String currency;
  double amount;
  double rate;
  double total;

  OperationsSystemDataClass({
    required this.id,
    required this.time,
    required this.trade,
    required this.currency,
    required this.amount,
    required this.rate,
    required this.total,
  });

  factory OperationsSystemDataClass.fromJson(Map<String, dynamic> json) {
    return OperationsSystemDataClass(
      id: json["id"],
      time: DateTime.tryParse(json["time"]) ?? DateTime.now(),
      trade: json["trade"] ?? '',
      currency: json["currency"] ?? '',
      amount: (json["amount"] is num) ? json["amount"].toDouble() : 0.0,
      rate: (json["rate"] is num) ? json["rate"].toDouble() : 0.0,
      total: (json["total"] is num) ? json["total"].toDouble() : 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "time": time.toIso8601String(),
    "trade": trade,
    "currency": currency,
    "amount": amount,
    "rate": rate,
    "total": total,
  };
}
