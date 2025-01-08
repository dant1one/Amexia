import 'package:amexia/data_classes_fold/currecy_system_data_class.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'routes.dart';
import 'package:amexia/globals/urls_endpoints.dart' as endpoints;
import 'package:amexia/globals/global.dart' as globals;


class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController exchangeRateController = TextEditingController();
  final TextEditingController resultController = TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool dataGet = false;
  bool isbuy = false;
  bool issell = false;

  List<CurrencySystemDataClass> currencies = [];
  late String? _selectedCurrency;

  void _showClearOutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Очистить Базу данных?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Закрыть'),
            ),
            TextButton(
              onPressed: () {
                _clearoutdb();
                Navigator.pop(context);
              },
              child: Text('Очистить'),
            ),
          ],
        );
      },
    );
  }

  void _showLoginExitDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Закончить сессию?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Закрыть'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, AppRoutes.login);
              },
              child: Text('Выйти'),
            ),
          ],
        );
      },
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.purple,
        duration: Duration(seconds: 5),
      ),
    );
  }

  Future<void> _sendOperationToServer(String trade, String currency, int amount, double rate) async {
    final dio = Dio();
    dio.options.headers["Authorization"] = "Bearer ${globals.accessToken}";

    if (rate <= 0) {
      print("Ошибка: курс должен быть больше нуля");
    }

    try {
      final response = await dio.post(
        endpoints.exchangeCreatePostEndpoint,
        data: {
          'time': DateTime.now().toIso8601String(),
          'trade': trade,
          'currency': currency,
          'amount': amount,
          "rate": rate,
        },
      );

      if (response.statusCode == 201) {
        print('Операция добавлена успешно');
        setState(() {
          amountController.clear();
          exchangeRateController.clear();
          resultController.clear();
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _calculateResult() async {
    if (amountController.text.isNotEmpty && exchangeRateController.text.isNotEmpty) {
      final amount = double.tryParse(amountController.text);
      final exchangeRate = double.tryParse(exchangeRateController.text);

      if (amount != null && exchangeRate != null) {
        if (amount > 0 && exchangeRate > 0) {
          final total = amount * exchangeRate;
          setState(() {
            resultController.text = total.toStringAsFixed(2);
          });
        } else {
          setState(() {
            resultController.text = "";
          });
          _showMessage('Сумма и курс должны быть больше нуля!');
        }
      } else {
        setState(() {
          resultController.text = "";
        });
        _showMessage('Введите корректные данные!');
      }
    } else {
      setState(() {
        resultController.text = "";
      });
    }
  }

  void _addOperation() {
    if (amountController.text.isEmpty || exchangeRateController.text.isEmpty) {
      _showMessage('Введите корректные данные!');
      return;
    } else {
      final amount = double.tryParse(amountController.text);
      final result = double.tryParse(resultController.text);
      final exchangeRate = double.tryParse(exchangeRateController.text);

      if (amount == null || result == null || amount <= 0 || result <= 0 || exchangeRate == null || exchangeRate <= 0) {
        _showMessage('Сумма, результат и курс должны быть больше нуля!');
        return;
      } else {
        if (_selectedCurrency == null) {
          _showMessage('Выберите валюту!');
          return;
        } else {
          if (!isbuy && !issell) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Выберите операцию!'),
                backgroundColor: Colors.purple,
                duration: Duration(seconds: 5),
              ),
            );
          } else {
            if (isbuy) {
              _sendOperationToServer("buy", _selectedCurrency!, amount.toInt(), exchangeRate);
            }
            if (issell) {
              _sendOperationToServer("sell", _selectedCurrency!, amount.toInt(), exchangeRate);
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Операция успешно добавлена!'),
                backgroundColor: Colors.purple,
                duration: Duration(seconds: 5),
              ),
            );
          }
        }
      }
    }
  }


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
    } catch (e) {
      print(e);
    }
  }

  Future<void> _clearoutdb() async {
    final dio = Dio();
    dio.options.headers["Authorization"] = "Bearer ${globals.accessToken}";
    try {
      final response = await dio.post(
        endpoints.clearDataBasePostEndpoint,
      );
      if (response.statusCode == 200) {
        print('database cleared');
        setState(() {
          dataGet = false;
        });
        await getCurrency();
        setState(() {
          dataGet = true;
        });
      }
    } catch (e) {
      print('Ошибка сети: $e');
    }
  }

  Future<void> initVoid() async{
    await getCurrency();
    setState(() {
      if (currencies.isNotEmpty){
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
          borderRadius: BorderRadius.zero
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
//todo: прикол агая
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
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Выйти'),
            onTap: () {
              _showLoginExitDialog();
            },
          ),
          ListTile(
            leading: Icon(Icons.delete),
            title: Text('Очистить'),
            onTap: () {
              _showClearOutDialog();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return (dataGet)? Padding(
      padding: const EdgeInsets.only(left: 20, top: 60, right: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    issell = true;
                    isbuy = false;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: issell ? Colors.red : Colors.grey,
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
                    isbuy = true;
                    issell = false;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isbuy ? Colors.green: Colors.grey,
                  minimumSize: Size(150, 50),
                ),
                child: Text(
                  'BUY',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          (_selectedCurrency!=null)? DropdownButtonFormField<String>(
            value: _selectedCurrency,
            isExpanded: true,
            onChanged: (String? newValue) {
              setState(() {
                _selectedCurrency = newValue!;
              });
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
          ) : const SizedBox(),
          SizedBox(height: 16),
          TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Количество',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.grey[100],
            ),
            onChanged: (_) => _calculateResult(),
          ),
          SizedBox(height: 16),
          TextField(
            controller: exchangeRateController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Курс',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.grey[100],
            ),
            onChanged: (_) => _calculateResult(),
          ),
          SizedBox(height: 16),
          TextField(
            controller: resultController,
            readOnly: true,
            decoration: InputDecoration(
              hintText: 'Результат',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.grey[100],
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              _addOperation();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              minimumSize: Size(double.infinity, 50),
            ),
            child: Text(
              'Add',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, AppRoutes.exchange);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              minimumSize: Size(double.infinity, 50),
            ),
            child: Text(
              'Exchange',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ],
      ),
    )
        :
    Center(
      child: CupertinoActivityIndicator(
        color: Colors.purple.shade500,
        radius: 20,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
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
      body: _buildMainContent()
    );
  }
}

