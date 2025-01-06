// To parse this JSON data, do
//
//     final usersDataClass = usersDataClassFromJson(jsonString);

import 'dart:convert';

List<UsersDataClass> usersDataClassFromJson(String str) => List<UsersDataClass>.from(json.decode(str).map((x) => UsersDataClass.fromJson(x)));

String usersDataClassToJson(List<UsersDataClass> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class UsersDataClass {
  String username;
  String password;

  UsersDataClass({
    required this.username,
    required this.password,
  });

  factory UsersDataClass.fromJson(Map<String, dynamic> json) => UsersDataClass(
    username: json["username"],
    password: json["password"],
  );

  Map<String, dynamic> toJson() => {
    "username": username,
    "password": password,
  };
}
