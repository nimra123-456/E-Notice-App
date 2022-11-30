import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(child: Text('Loading...'),),
        /*constraints: BoxConstraints.expand(),
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/images/spl.gif'), fit: BoxFit.cover),
        ),*/
        /*child: TextField(
          decoration: InputDecoration(fillColor: Colors.amber, filled: true),
        ),*/
      ),
    );
  }
}
