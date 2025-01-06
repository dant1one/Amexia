import 'package:flutter/material.dart';
import 'routes.dart';

class OtchetScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text("Отчет"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, AppRoutes.home);
          },
          child: Text("PoP"),
        ),
      ),
    );
  }
}
