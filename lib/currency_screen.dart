import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'routes.dart';
import 'package:amexia/data_classes_fold/currecy_system_data_class.dart';
import 'package:amexia/globals/urls_endpoints.dart' as endpoints;
import 'package:amexia/globals/global.dart' as globals;


class CurrencyScreen extends StatefulWidget {
  @override
  _CurrencyScreenState createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends State<CurrencyScreen> {
  final TextEditingController currencyController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<CurrencySystemDataClass> currencies = [];
  bool dataGet = false;

  void _showAddCurrencyDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Добавить валюту'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currencyController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  hintText: 'Название валюты',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Закрыть'),
            ),
            TextButton(
              onPressed: () {
                String currency = currencyController.text;
                if (currency.isNotEmpty) {
                  setState(() {
                    _addCurrency(currency);
                  });
                  currencyController.clear();
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Введите название валюты',
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.purple,
                    ),
                  );
                  Navigator.pop(context);
                }
              },
              child: Text('Добавить'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addCurrency(String currency) async {
    final dio = Dio();
    dio.options.responseType = ResponseType.plain;
    dio.options.headers["Authorization"] = "Bearer ${globals.accessToken}";
    try {
      final response = await dio.post(
        endpoints.currenciesCreatePostEndpoint,
        data: {
          "currency": currency,
        },
      );
      if (response.statusCode == 201) {
        await getCurrency();
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> getCurrency() async {
    final dio = Dio();
    dio.options.responseType = ResponseType.plain;
    dio.options.headers["Authorization"] = "Bearer ${globals.accessToken}";
    try {
      final response = await dio.get(endpoints.currencyGetEndpoint);
      print(response);
      if (response.statusCode == 200) {
        final result = currencySystemDataClassFromJson(response.data.toString());
        setState(() {
          currencies = result;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> addingCurrency(String currency) async {
    setState(() {
      dataGet = false;
    });
    await _addCurrency(currency);
    await getCurrency();
    setState(() {
      dataGet = true;
    });
  }

  Future<void> initVoid() async {
    await getCurrency();
    setState(() {
      dataGet = true;
    });
  }

  @override
  void dispose() {
    currencyController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initVoid();
  }

  Widget _buildBurgerMenu() {
    return Drawer(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.purple),
            child: Text(
              'Меню',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: Icon(Icons.currency_exchange),
            title: Text('Обмен'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, AppRoutes.home);
            },
          ),
          ListTile(
            leading: Icon(Icons.attach_money),
            title: Text('Валюты'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, AppRoutes.currency);
            },
          ),
          ListTile(
            leading: Icon(Icons.analytics),
            title: Text('Отчет'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, AppRoutes.otchet);
            },
          ),
          ListTile(
            leading: Icon(Icons.account_balance_wallet),
            title: Text('Статистика'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, AppRoutes.statistic);
            },
          ),
          ListTile(
            leading: Icon(Icons.people),
            title: Text('Пользователи'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, AppRoutes.users);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(double width) {
    return dataGet
        ? Center(
      child: Padding(
        padding: const EdgeInsets.only(left: 20, top: 40, right: 20, bottom: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                width: width,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  border: Border.all(color: Colors.purple, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DataTable(
                    columns: [
                      DataColumn(label: Text('Название валюты', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: currencies.map((currency) {
                      return DataRow(
                        cells: [
                          DataCell(Text(currency.currency)),
                        ],
                      );
                    }).toList(),
                  ),
                ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _showAddCurrencyDialog();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text(
                'Добавить валюту',
                style: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(height: 20),
          ],
        )
      )
    )
        :
    Center(
      child: CupertinoActivityIndicator(
        radius: 20,
        color: Colors.purple.shade500,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          'Amexia Currencies',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.purple,
        leading: IconButton(
          icon: Icon(Icons.menu),
          color: Colors.white,
          onPressed: () => _scaffoldKey.currentState!.openDrawer(),
        ),
      ),
      drawer: _buildBurgerMenu(),
      body: _buildMainContent(width),
      resizeToAvoidBottomInset: false,
    );
  }
}
