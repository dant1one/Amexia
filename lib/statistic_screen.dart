import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:amexia/data_classes_fold/statistic_system_data_class.dart';
import 'package:amexia/globals/urls_endpoints.dart' as endpoints;
import 'package:amexia/globals/global.dart' as globals;

class StatisticScreen extends StatefulWidget {
  @override
  _StatisticScreenState createState() => _StatisticScreenState();
}

class StatisticDataSource extends DataTableSource {
  final List<StatisticSystemDataClass> statistics;

  StatisticDataSource(this.statistics);

  @override
  DataRow getRow(int index) {
    final statistic = statistics[index];

    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(statistic.currency)),
        DataCell(Text(statistic.totalBuy.toString())),
        DataCell(Text(statistic.avgBuy.toString())),
        DataCell(Text(statistic.totalSell.toString())),
        DataCell(Text(statistic.avgSell.toString())),
        DataCell(Text(statistic.profit.toString())),

    ]);
  }

  @override
  int get rowCount => statistics.length;

  @override
  int get selectedRowCount => 0;

  @override
  bool get isRowCountApproximate => false;
}

class _StatisticScreenState extends State<StatisticScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool dataGet = false;

  List<StatisticSystemDataClass> statistics = [];

  Future<void> _getstatistic() async {
    final dio = Dio();
    dio.options.responseType = ResponseType.plain;
    dio.options.headers["Authorization"] = "Bearer ${globals.accessToken}";

    try {
      final response = await dio.get(endpoints.statisticGetendpoint);
      print(response);
      if (response.statusCode == 200) {
        final result = statisticSystemDataClassFromJson(response.data.toString());
        setState(() {
          statistics = result;
          dataGet = true;
        });
      }
    } catch (e) {
      print(e);
      }
    }


  @override
  void initState() {
    super.initState();
    _getstatistic();
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
      padding: const EdgeInsets.only(left: 20, top: 30, right: 20, bottom: 30),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: PaginatedDataTable(
                header: Text('Статистика', style: TextStyle(fontSize: 32)),
                columns: const [
                  DataColumn(
                    label: Text(
                      'Валюта',
                      style: TextStyle(fontSize: 19),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Итого: Покупка',
                      style: TextStyle(fontSize: 19),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Всреднем: Покупка',
                      style: TextStyle(fontSize: 19),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Итого: Продажа',
                      style: TextStyle(fontSize: 19),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Всреднем: Продажа',
                      style: TextStyle(fontSize: 19),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Профит',
                      style: TextStyle(fontSize: 19),
                    ),
                  ),
                ],
                source: StatisticDataSource(statistics),
                rowsPerPage: 9,
              ),
            ),
          ),
        ],
      ),
    ) : Center(child: CupertinoActivityIndicator(
      radius: 20,
      color: Colors.purple.shade500,
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          'Amexia Statistic',
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

