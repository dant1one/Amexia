import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'users_screen.dart';
import 'exchange_screen.dart';//кнопка события
import 'currency_screen.dart';
import 'statistic_screen.dart';
//todo: прикол агая
import 'otchet_screen.dart';


class AppRoutes {
  static const String login = '/login';
  static const String home = '/home';
  static const String users = '/users';
  static const String exchange = '/exchange';//кнопка события
  static const String currency = '/currency';
  static const String statistic = '/statistic';
  //todo: прикол агая
  static const String otchet = '/otchet';

  static Map<String, WidgetBuilder> routes = {
    login: (context) => LoginScreen(),
    home: (context) => HomeScreen(),
    users: (context) => UsersScreen(),
    exchange: (context) => ExchangeScreen(),//кнопка события
    currency: (context) => CurrencyScreen(),
    statistic: (context) => StatisticScreen(),
    //todo: прикол агая
    otchet: (context) => OtchetScreen(),

  };
}
