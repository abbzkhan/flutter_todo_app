import 'package:flutter/material.dart';
import 'package:todo_app/homepage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Remove the debug banner
        debugShowCheckedModeBanner: false,
        title: 'Todo app',
        theme: ThemeData(
          primarySwatch: Colors.lime,
        ),
        home: const HomePage());
  }
}




