import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:notification_board/main.dart';
import 'package:notification_board/screens/notificationn_detail_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart'as http;
import '../providers/auth.dart';
import '../widgets/app_drawer.dart';
import '../widgets/notifications_grid.dart';
import '../providers/notifications.dart';

enum FilterOptions {
  Favorites,
  All,
}

class NotificationsOverviewScreen extends StatefulWidget {
  @override
  _NotificationsOverviewScreenState createState() =>
      _NotificationsOverviewScreenState();
}

class _NotificationsOverviewScreenState
    extends State<NotificationsOverviewScreen> {
  Future<void> _refreshNotifications(BuildContext context) async {
    final response1 = await http.get(Uri.parse('https://notice-board-app-2afdd-default-rtdb.firebaseio.com/usersData.json',));
    var _usersData = json.decode(response1.body);
    SharedPreferences _storage = await SharedPreferences.getInstance();
    String _userID = _storage.getString('comingID');
    Auth authProvider = Provider.of<Auth>(context,listen: false);
    authProvider.setUserProfileURL("${_usersData[_userID]['photoUrl']??""}");
    authProvider.setUserName("${_usersData[_userID]["userName"]??""}");
    await Provider.of<Notifications>(context, listen: false).fetchAndSetNotifications();

  }

  var _showOnlyFavorites = false;
  var _isInit = true;
  var _isLoading = false;

  @override
  void initState() {
    configureFirebase();
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });

      await Provider.of<Notifications>(context)
          .fetchAndSetNotifications()
          .then((_) {
            if(mounted)
            setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[850],
      appBar: AppBar(
        title: Text('MyNotices'),
        actions: <Widget>[
          PopupMenuButton(
            onSelected: (FilterOptions selectedValue) {
              setState(() {
                if (selectedValue == FilterOptions.Favorites) {
                  _showOnlyFavorites = true;
                } else {
                  _showOnlyFavorites = false;
                }
              });
            },
            icon: Icon(
              Icons.more_vert,
            ),
            itemBuilder: (_) => [
              PopupMenuItem(
                child: Text('Only Favorites'),
                value: FilterOptions.Favorites,
              ),
              PopupMenuItem(
                child: Text('Show All'),
                value: FilterOptions.All,
              ),
            ],
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: () => _refreshNotifications(context),
              child: NotificationsGrid(_showOnlyFavorites),
            ),
    );
  }
  configureFirebase(){
    FirebaseMessaging.instance.getToken().then((value) => print("FRM Toek-->$value"));
    FirebaseMessaging.onMessage.listen((event) {
      Fluttertoast.showToast(msg: 'New Notification is received');
      print("New Message:-> ${event.data}");
    });
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      Fluttertoast.showToast(msg: 'New Notification is received');
      print("New Message onMessageOpenedApp:-> $event");
    });
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }
}
