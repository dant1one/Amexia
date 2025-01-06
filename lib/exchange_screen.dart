import 'package:amexia/data_classes_fold/operations_system_data_class.dart';
import 'package:amexia/data_classes_fold/currecy_system_data_class.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:amexia/globals/urls_endpoints.dart' as endpoints;
import 'package:amexia/globals/global.dart' as globals;

class ExchangeScreen extends StatefulWidget {
  @override
  _ExchangeScreenState createState() => _ExchangeScreenState();
}

class ExchangeDataSource extends DataTableSource {
  final List<OperationsSystemDataClass> exchanges;

  ExchangeDataSource(this.exchanges);

  @override
  DataRow getRow(int index) {
    final exchange = exchanges[index];

    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(exchange.time.toIso8601String())),
        DataCell(Text(exchange.trade)),
        DataCell(Text(exchange.currency)),
        DataCell(Text(exchange.amount.toString())),
        DataCell(Text(exchange.rate.toString())),
        DataCell(Text(exchange.total.toString())),
      ],
    );
  }

  @override
  int get rowCount => exchanges.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}

class _ExchangeScreenState extends State<ExchangeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool dataGet = false;
  String selected_operation = "";

  List<CurrencySystemDataClass> currencies = [];
  late String? _selectedCurrency;
  List<OperationsSystemDataClass> exchanges = [];

  Future<void> getCurrency() async {
    final dio = Dio();
    dio.options.responseType = ResponseType.plain;
    dio.options.headers["Authorization"] = "Bearer ${globals.accessToken}";
    try {
      final response = await dio.get(endpoints.currencyGetEndpoint);
      if (response.statusCode == 200) {
        final result = currencySystemDataClassFromJson(response.data.toString());
        setState(() {
          currencies = result;
        });
      }
    }
    catch (e) {
      print(e);
    }
  }

  Future<void> _getexchanges() async {
    final dio = Dio();
    dio.options.responseType = ResponseType.plain;
    dio.options.headers["Authorization"] = "Bearer ${globals.accessToken}";
    try {
      final response = await dio.get(endpoints.exchangeGetEndpoint);

      if (response.statusCode == 200) {
        final result = operationsSystemDataClassListFromJson(response.data.toString());
        result.sort((a, b) => b.time.compareTo(a.time));
        setState(() {
          exchanges = result;
        });
      }
    }
    catch (e) {
      print(e);
    }
  }

  void updateExchanges() async {
    await _getexchanges();

    setState(() {
        exchanges = exchanges.where((exchange) => exchange.currency == _selectedCurrency).toList();

      if (selected_operation.isNotEmpty) {
        exchanges.sort((a, b) {
          if (selected_operation == "sell") {
            if (a.trade != b.trade) {
              return a.trade == "sell" ? -1 : 1;
            }
          } else if (selected_operation == "buy") {
            if (a.trade != b.trade) {
              return a.trade == "buy" ? -1 : 1;
            }
          }
          return a.time.compareTo(b.time);
        });
      }
    });
  }

  void sortbytrade(String trade) {
    setState(() {
      selected_operation = trade;
    });
    updateExchanges();
  }

  void sortbycurrency(String? currency) {
    setState(() {
      _selectedCurrency = currency;
    });
    updateExchanges();
  }

  Future<void> initVoid() async {
    await _getexchanges();
    await getCurrency();
    setState(() {
      if (currencies.isNotEmpty) {
        _selectedCurrency = currencies[0].currency;
      }
      dataGet = true;
    });
  }

  @override
  void initState() {
    super.initState();
    initVoid();
  }

  Widget _buildBurgerMenu() {
    return Drawer(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
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
              Navigator.pushReplacementNamed(context, '/home');
            },
          ),
          ListTile(
            leading: Icon(Icons.attach_money),
            title: Text('Валюты'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/currency');
            },
          ),
          ListTile(
            leading: Icon(Icons.analytics),
            title: Text('Отчет'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/otchet');
            },
          ),
          ListTile(
            leading: Icon(Icons.account_balance_wallet),
            title: Text('Статистика'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/statistic');
            },
          ),
          ListTile(
            leading: Icon(Icons.people),
            title: Text('Пользователи'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/users');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return (dataGet)? Padding(
      padding: const EdgeInsets.only(left: 20, top: 40, right: 20, bottom: 20),
      child: Column(
        children: [
          (_selectedCurrency != null) ? DropdownButtonFormField<String>(
            value: _selectedCurrency,
            isExpanded: true,
            onChanged: (String? newValue) {
              setState(() {
                _selectedCurrency = newValue!;
              });
              sortbycurrency(newValue);
            },
            items: currencies.map<DropdownMenuItem<String>>((CurrencySystemDataClass currency) {
              return DropdownMenuItem<String>(
                value: currency.currency,
                child: Text(currency.currency),
              );
            }).toList(),
            decoration: InputDecoration(
              labelText: 'Выберите валюту',
            ),
          ) : SizedBox(),

          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selected_operation = "sell";
                  });
                  sortbytrade("sell");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: selected_operation == "sell" ? Colors.red : Colors.grey,
                  minimumSize: Size(150, 50),
                ),
                child: Text(
                  'SELL',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selected_operation = "buy";
                  });
                  sortbytrade("buy");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: selected_operation == "buy" ? Colors.green : Colors.grey,
                  minimumSize: Size(150, 50),
                ),
                child: Text(
                  'BUY',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          SizedBox(height: 36),
          Expanded(
            child: SingleChildScrollView(
              child: PaginatedDataTable(
                header: Text('Данные обмена', style: TextStyle(fontSize: 24)),
                columns: const [
                  DataColumn(
                    label: Text(
                      'Время',
                      style: TextStyle(fontSize: 19),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Обмен',
                      style: TextStyle(fontSize: 19),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Валюта',
                      style: TextStyle(fontSize: 19),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Сумма',
                      style: TextStyle(fontSize: 19),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Курс',
                      style: TextStyle(fontSize: 19),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Итого',
                      style: TextStyle(fontSize: 19),
                    ),
                  ),
                ],
                source: ExchangeDataSource(exchanges),
                rowsPerPage: 5,
              ),
            ),
          )
        ],
      ),
    ) : Center(child: CupertinoActivityIndicator(
      color: Colors.purple.shade500,
      radius: 20
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          'Amexia Exchange',
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
      body: _buildMainContent(),
    );
  }
}
