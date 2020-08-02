import 'package:chatnow/widgets/Category_Selector.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          title: Text("ChatNow", style: TextStyle(
            fontSize: 28.0,
            fontWeight: FontWeight.bold,
          ),),
          elevation: 0.0,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.search),
              iconSize: 30.0,
              color: Colors.white,
              onPressed: (){},
            ),
            IconButton(
              icon: Icon(Icons.more_vert),
              iconSize: 30.0,
              color: Colors.white,
              onPressed: (){},
            ),
          ],
        ),
        body: Column(
          children: <Widget>[
            CategorySelector(),
            Expanded(
              child: Container(
                height: 500,
                decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(30.0),
                      topLeft: Radius.circular(30.0),
                    )
                ),
              ),
            ),
//            Container(
//              margin: EdgeInsets.symmetric(horizontal: 18.0),
//              padding: EdgeInsets.symmetric(horizontal: 10.0),
//              decoration: BoxDecoration(
//                color: Colors.grey[100],
//                borderRadius: BorderRadius.circular(15.0),
//              ),
//              child: TextField(
//                decoration: InputDecoration(
//                  icon: Icon(Icons.search),
//                  hintText: 'search for friends',
//                  border: InputBorder.none,
//                ),
//              ),
//            ),
            SizedBox(height: 25.0),
          ],
        ),
      ),
    );
  }
}