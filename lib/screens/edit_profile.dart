import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:notification_board/providers/auth.dart';
import 'package:notification_board/screens/splash_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key key}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  bool _isInit = true;
  bool _isLoading = true;
  SharedPreferences _storage;
  String _userID;
  var _authToken = '';

  var _usersData;

  Future<void> _getUserData() async {
    print('Here');
    final response = await http.get(
        Uri.parse('https://notice-board-app-2afdd-default-rtdb.firebaseio.com/usersData.json?auth=$_authToken'),
    );
    print('Here');

    _usersData = json.decode(response.body);
    print(_usersData);
    print('Here');
  }

  @override
  void didChangeDependencies() async {
    if (_isInit) {
      _authToken = Provider.of<Auth>(context).token;

      _storage = await SharedPreferences.getInstance();
      _userID = _storage.getString('comingID');
      await _getUserData();
      setState(() {
        _isLoading = false;
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Profile'),
        centerTitle: true,
      ),
      body: _isLoading ? SplashScreen()
      : ListView(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                Stack(
                  children: [
                    (_usersData[_userID]['photoUrl'] != '' ||  _usersData[_userID]['photoUrl']!=null)?
                    Container(
                    margin: EdgeInsets.only(left: 30),
                    height: 100, width: 100,
                    child: CircleAvatar(
                      child: Container(
                         height: 110, width: 180,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.network(
                           _usersData[_userID]['photoUrl'],
                           fit: BoxFit.cover,
                           // height: 40,
                           // width: 40, 
                        ),
                        ),
                      ),
                    ),
                  )
                    :Container(
                      height: 110,
                      width: 180,
                      margin: EdgeInsets.only(bottom: 20.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        //color: Colors.red,
                        image: DecorationImage(
                          image: AssetImage('assets/images/profile2.png'),
                          //fit: BoxFit.cover
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 25),
                Container(
                  padding: EdgeInsets.only(left: 15,top: 10),
                  height: 60, 
                  width: 400,
                  //color: Colors.teal,
                  decoration: BoxDecoration(
                    //color: Colors.grey[350],
                    border: Border.all(color: Colors.yellow[100]),
                    borderRadius: BorderRadius.circular(5),),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('User Name', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.yellow)),
                        SizedBox(height: 6.5),
                        Text('${_usersData[_userID]['userName']}', style:TextStyle(color: Colors.yellow[100])),
                      ],
                    ),
                    ),
                
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.only(left: 15,top: 10),
                  height: 60, 
                  width: 400,
                  //color: Colors.teal,
                  decoration: BoxDecoration(
                    //color: Colors.grey[350],
                     border: Border.all(color: Colors.yellow[100]),
                    borderRadius: BorderRadius.circular(5),),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Email', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.yellow)),
                        SizedBox(height: 6.5),
                        Text('${_usersData[_userID]['email']}', style:TextStyle(color: Colors.yellow[100])),
                      ],
                    ),
                    ),
                SizedBox(height: 20),
                // Container(
                //   padding: EdgeInsets.only(left: 15,top: 10),
                //   height: 60, 
                //   width: 400,
                //   //color: Colors.teal,
                //   decoration: BoxDecoration(
                //     //color: Colors.grey[350],
                //     border: Border.all(color: Colors.yellow[100]),
                //     borderRadius: BorderRadius.circular(5),),
                //     child: Column(
                //       crossAxisAlignment: CrossAxisAlignment.start,
                //       children: [
                //         Text('Session', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.yellow)),
                //         SizedBox(height: 6.5),
                //         Text('${_usersData[_userID]['session']}', style:TextStyle(color: Colors.yellow[100])),
                //       ],
                //     ),
                //     ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}