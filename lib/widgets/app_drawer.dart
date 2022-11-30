import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:notification_board/providers/users.dart';
import 'package:notification_board/screens/edit_profile.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/user_notifications_screen.dart';
import '../providers/auth.dart';
import '../helpers/custom_route.dart';
import 'package:http/http.dart'as http;

class AppDrawer extends StatefulWidget {
  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  bool _isInit = true;
  bool _isLoading = true;
  SharedPreferences _storage;
  String _userID;
  var _authToken='';

  var _usersData;

  Future<void> _getUserData() async {
    final response = await http.get(Uri.parse('https://notice-board-app-2afdd-default-rtdb.firebaseio.com/usersData.json?auth=$_authToken',));
    _usersData = json.decode(response.body);
    Auth authProvider = Provider.of<Auth>(context,listen: false);
    authProvider.setUserProfileURL("${_usersData[_userID]['photoUrl']??""}");
    authProvider.setUserName("${_usersData[_userID]["userName"]??""}");

  }

  @override
    void didChangeDependencies() async {
      if(_isInit) {
        _authToken=Provider.of<Auth>(context).token;

        _storage = await SharedPreferences.getInstance();
        _userID = _storage.getString('comingID');
        await _getUserData();
        setState(() {
                  _isLoading = false;
                });

      }_isInit = false;
      super.didChangeDependencies();
    }

  @override
  Widget build(BuildContext context) {


    return _isLoading ? Drawer() : Drawer(
      child: ListView(
        children: <Widget>[
          Container(
            height: 200,
            child: DrawerHeader(
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(width: 5.0, color: Colors.grey),
                  right: BorderSide(width: 5.0, color: Colors.grey),
                  bottom: BorderSide(width: 5.0, color: Colors.grey),
                ),
                color: Theme.of(context).primaryColor,
              ),
              margin: EdgeInsets.all(10),
              //padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              padding: EdgeInsets.only(top: 20, left: 20,),
              child: _usersData[_userID]!=null? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  (_usersData[_userID]['photoUrl'] != '' ||  _usersData[_userID]['photoUrl']!=null )?
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
                  ):
                      Image.asset(
                   'assets/images/a.jpg',
                   // height: 40,
                   // width: 40,
                      ),
                  SizedBox(height: 10),
                  Text('Welcome Dear ${_usersData[_userID]['userName']}',
                      style: TextStyle(fontSize: 20, color: Colors.white)),
                  Text('${_usersData[_userID]['email']}',
                      style: TextStyle(fontSize: 15, color: Colors.white60)),
                ],
              ):SizedBox(),
            ),
          ),
          SizedBox(height: 10),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => EditProfileScreen()));
            },
            child: Row(
              children: <Widget>[
                SizedBox(width: 25),
                Icon(Icons.person, color: Colors.black54),
                SizedBox(width: 25),
                Text('My Profile',
                    style: TextStyle(
                      fontSize: 17,
                      //fontWeight: FontWeight.bold,
                    )),
              ],
            ),
          ),
          SizedBox(height: 15),
          GestureDetector(
            onTap: () {
              Navigator.of(context).pushReplacementNamed('/');
            },
            child: Row(
              children: <Widget>[
                SizedBox(width: 25),
                Icon(Icons.notifications_on, color: Colors.black54),
                SizedBox(width: 25),
                Text('Notices',
                    style: TextStyle(
                      fontSize: 17,
                    )),
              ],
            ),
          ),
          SizedBox(height: 15),
          GestureDetector(
            onTap: () {
              Navigator.of(context)
                  .pushReplacementNamed(UserNotificationsScreen.routeName);
            },
            child: Row(
              children: <Widget>[
                SizedBox(width: 25),
                Icon(Icons.notifications_rounded, color: Colors.black54),
                SizedBox(width: 25),
                Text('Manage Notices',
                    style: TextStyle(
                      fontSize: 17,
                    )),
              ],
            ),
          ),
          SizedBox(height: 15),
          GestureDetector(
            onTap: () {
              Auth authProvider = Provider.of<Auth>(context, listen: false);

              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/');
              authProvider.logout();
            },
            child: Row(
              children: <Widget>[
                SizedBox(width: 25),
                Icon(Icons.logout, color: Colors.black54),
                SizedBox(width: 25),
                Text('Logout',
                    style: TextStyle(
                      fontSize: 17,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
