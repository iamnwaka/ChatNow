import 'package:flutter/material.dart';

void main() {
  runApp(MyChat());
}

class MyChat extends StatefulWidget {
  @override
  _MyChatState createState() => _MyChatState();
}

class _MyChatState extends State<MyChat> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("ChatNow", style: TextStyle(
            fontSize: 28.0,
            fontWeight: FontWeight.bold,
          ),),
          elevation: 0.0,
          actions: <Widget>[
             IconButton(
                 icon: Icon(Icons.more_vert),
               iconSize: 30.0,
               color: Colors.white,
               onPressed: (){},
             )
          ],
        ),
      ),
    );
  }
}
