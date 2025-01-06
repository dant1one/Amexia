import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'routes.dart';
import 'package:amexia/data_classes_fold/users_system_data_class.dart';
import 'package:amexia/globals/urls_endpoints.dart' as endpoints;

class UsersScreen extends StatefulWidget {
  @override
  _UsersScreenState createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<UsersDataClass> users = [];

  bool dataGet = false;

  void _showAddUserDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Добавить пользователя'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  hintText: 'Имя пользователя',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: passwordController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Пароль',
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
                String username = nameController.text;
                String password = passwordController.text;
                if (username.isNotEmpty && password.isNotEmpty) {
                    addingUser(username, password);
                }
                else{
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Введите логин и пароль',
                          style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                          backgroundColor: Colors.purple,
                    )
                  );
                }
                nameController.clear();
                passwordController.clear();
                Navigator.pop(context);
              },
              child: Text('Добавить'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addUser(String username, String password) async {
    final dio = Dio();
    dio.options.responseType = ResponseType.plain;
    try {
      final response = await dio.post(
          endpoints.usersCreatePostEndpoint,
          data: {
            "username" : username,
            "password" : password
          }
      );
      if (response.statusCode == 201) {}
    }
    catch (e) {
      print(e);
    }
  }
  Future<void> addingUser(String username , String password) async{
    setState(() {
      dataGet = false;
    });
    await _addUser(username, password);
    await getUsers();
    setState(() {
      dataGet = true;
    });
  }

  Future<void> getUsers() async {
    final dio = Dio();
    dio.options.responseType = ResponseType.plain;
    try {
      final response = await dio.get(endpoints.usersGetEndpoint);
      if (response.statusCode == 200) {
        final result = usersDataClassFromJson(response.data.toString());
        setState(() {
          users = result;
        });
      }
    } catch (e) {
      print(e);
    }
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
        ],
      ),
    );
  }

  Widget _buildMainContent(double width) {
    return (dataGet)?
    Center(
      child: Padding(
        padding: const EdgeInsets.only(left:20, top:40, right: 20, bottom: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                width: width-40,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  border: Border.all(color: Colors.purple, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(
                          label: Text(
                            'Имя пользователя',
                            style: TextStyle(fontSize: 19),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Пароль',
                            style: TextStyle(fontSize: 19),
                          ),
                        ),
                      ],
                      rows: users.map((user) {
                        return DataRow(cells: [
                          DataCell(
                            Text(
                              user.username,
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                          DataCell(
                            Text(
                              user.password,
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ]);
                      }).toList(),
                    ),

                  ),
                )
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _showAddUserDialog();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text(
                'Add',
                style: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(height: 20)
          ],
        ),
      ),
    )
      :
    Center(
      child: CupertinoActivityIndicator(
        radius: 20,
        color: Colors.purple.shade500,
      ),
    )
    ;
  }

  Future<void> initVoid() async{
    await getUsers();
    setState(() {
      dataGet = true;
    });
  }

  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initVoid();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          'Amexia Users',
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
    );
  }
}
