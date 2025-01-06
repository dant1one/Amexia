import 'dart:convert';

List<CurrencySystemDataClass> currencySystemDataClassFromJson(String str) => List<CurrencySystemDataClass>.from(json.decode(str).map((x) => CurrencySystemDataClass.fromJson(x)));

String currencySystemDataClassToJson(List<CurrencySystemDataClass> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CurrencySystemDataClass {
  int id;
  String currency;

  CurrencySystemDataClass({
    required this.id,
    required this.currency,
  });

  factory CurrencySystemDataClass.fromJson(Map<String, dynamic> json) => CurrencySystemDataClass(
    id: json["id"],
    currency: json["currency"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "currency": currency,
  };
}
