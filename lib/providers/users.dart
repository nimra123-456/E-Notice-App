import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:notification_board/providers/auth.dart';
import 'package:notification_board/providers/user.dart';
import 'package:provider/provider.dart';

class UsersData with ChangeNotifier {
  List<User> _userData;
  BuildContext context;
  UsersData({this.context});

  get userData {
    return [..._userData];
  }

  Future<void> fetchAndSetNotifications() async {
    final userData = Provider.of<Auth>(context);
    final userId = userData.userId;
    final authToken = userData.token;

    //final filterString = filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    var url =
        'https://notice-board-app-2afdd-default-rtdb.firebaseio.com/userData.json?auth=$authToken';
    try {
      final response = await http.get(Uri.parse(url));
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }
      //url = 'https://notice-board-app-2afdd-default-rtdb.firebaseio.com/userFavorites/$userId.json?auth=$authToken';
      //final favoriteResponse = await http.get(url);
      //final favoriteData = json.decode(favoriteResponse.body);
      final List<User> loadedUsers = [];
      extractedData.forEach((userId, userData) {
        loadedUsers.add(User(
          userId: userId,
          email: userData['email'],
          session: userData['session'], 
          photoUrl: userData['photoUrl'],
          userName: userData['userName'],
        ));
      });
      _userData = loadedUsers;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }
}
