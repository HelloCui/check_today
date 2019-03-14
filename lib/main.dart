import 'package:flutter/material.dart';
import './pages/home.dart';
import './pages/login.dart';
import './common.dart';
import './global.dart';
import './model/dio.dart';


void main() async {
  Widget _defaultHome;
  $navigatorKey = new GlobalKey<NavigatorState>();

  await Common.syncToken();
  initDio();

  bool _logged = $refreshToken != '';

  if(_logged) {
    _defaultHome = new MyHomePage();
  } else {
    _defaultHome = new LoginPage();
  }

  runApp(new MaterialApp(
    title: 'Check Today',
    navigatorKey: $navigatorKey,
    home: _defaultHome,
    routes: {
      '/home': (context) => MyHomePage(),
      '/login': (context) => LoginPage()
    },
    theme: ThemeData(
      brightness: Brightness.light,
      primaryColor: Colors.black,
      errorColor: Colors.redAccent,
      accentColor: Colors.black,
      fontFamily: 'Montserrat',
      dividerColor: Colors.grey,
      iconTheme: IconThemeData(color: Colors.black),
      textTheme: TextTheme(
          button: TextStyle(color: Colors.black),
          caption: TextStyle(color: Colors.grey)
      ),
    ),
  ));
}
