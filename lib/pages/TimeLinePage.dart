import 'package:chatnow/widgets/HeaderWidget.dart';
import 'package:chatnow/widgets/ProgressWidget.dart';
import 'package:flutter/material.dart';

class TimeLinePage extends StatefulWidget {
  @override
  _TimeLinePageState createState() => _TimeLinePageState();
}
 
class _TimeLinePageState extends State<TimeLinePage> {
  @override
  Widget build(context) {
    return Scaffold(
      appBar: header(context: context, isAppTitle: true,),
      body: circularProgress(),
    );
  }
}
