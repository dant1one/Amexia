import 'package:amexia/data_classes_fold/tokens_backend.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'routes.dart';
import 'package:amexia/globals/urls_endpoints.dart' as endpoints;
import 'package:amexia/globals/global.dart' as globals;

class LoginScreen extends StatefulWidget {
  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> login(String username , String password) async {
    final dio = Dio();
    try{
      final response = await dio.post(endpoints.loginPostEndpoint , data: {
        "username" : username,
        "password" : password
      });
      if(response.statusCode == 200){
        final result = tokensBackendFromJson(response.toString());
        globals.accessToken = result.access;
        globals.refreshToken = result.refresh;
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    }
    catch(e){
      print(e);
    }
  }

  Widget loginTextField() {
    return TextField(
      controller: _usernameController,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(labelText: "User"),
    );
  }

  Widget passwordTextField() {
    return TextField(
      controller: _passwordController,
      obscureText: true,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(labelText: "Password"),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: Text(
          'Amexia',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Image.asset(
              'assets/images/logo.png',
              height: 100,
              width: 100,
            ),
            SizedBox(height: 20),
            Text(
              'Login',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
            SizedBox(height: 20),
            loginTextField(),
            passwordTextField(),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String username = _usernameController.text;
                String password = _passwordController.text;
                if (username.isNotEmpty && password.isNotEmpty) {
                  await login(username, password);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Введите логин и пароль',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      backgroundColor: Colors.purple,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text(
                'Login',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            SizedBox(height: 50),
            Text(
              'daniyal & co',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
      );
  }
}
