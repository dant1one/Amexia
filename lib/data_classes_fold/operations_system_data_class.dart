import 'dart:convert';

List<OperationsSystemDataClass> operationsSystemDataClassListFromJson(String str) {
  final jsonData = json.decode(str);
  return List<OperationsSystemDataClass>.from(jsonData.map((x) => OperationsSystemDataClass.fromJson(x)));
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

  factory OperationsSystemDataClass.fromJson(Map<String, dynamic> json) => OperationsSystemDataClass(
    id: json["id"],
    time: DateTime.parse(json["time"]),
    trade: json["trade"],
    currency: json["currency"],
    amount: json["amount"],
    rate: json["rate"]?.toDouble(),
    total: json["total"],
  );

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
