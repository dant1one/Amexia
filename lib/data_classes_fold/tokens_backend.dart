import 'dart:convert';

TokensBackend tokensBackendFromJson(String str) => TokensBackend.fromJson(json.decode(str));

String tokensBackendToJson(TokensBackend data) => json.encode(data.toJson());

class TokensBackend {
  String refresh;
  String access;

  TokensBackend({
    required this.refresh,
    required this.access,
  });

  factory TokensBackend.fromJson(Map<String, dynamic> json) => TokensBackend(
    refresh: json["refresh"],
    access: json["access"],
  );

  Map<String, dynamic> toJson() => {
    "refresh": refresh,
    "access": access,
  };
}
