import 'dart:async';
import 'package:flutter/material.dart';
import 'package:manga_reader/Model/DBProvider.dart';
import 'package:manga_reader/Pages/HomePage.dart';

void main() {
  initApp().then((_) {
    runApp(App());
  });
}

Future<void> initApp() async {
  await DBProvider.dbManager.initDatabase();
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Manga Reader',
      theme: ThemeData(
          brightness: Brightness.dark,
          accentColor: Color(0xFFCDDC39),
          splashColor: Color(0xFFCDDC39),
          scaffoldBackgroundColor: Color(0xFF455A64),
          backgroundColor: Color(0xFF607D8B),
          primaryColor: Color(0xFFA4B02D),
          disabledColor: Color(0xFFBDBDBD)),
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
      },
    );
  }
}
