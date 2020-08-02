import 'package:chatnow/Screens/home.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyChat());
}


class MyChat extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChatNow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.blue,
        accentColor: Color(0xFFFE9EB),
      ),
      home: HomeScreen(),
    );
  }
}
