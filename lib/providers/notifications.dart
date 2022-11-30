import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:notification_board/constants.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/http_exception.dart';
import 'notificationn.dart';
import 'auth.dart';

class Notifications with ChangeNotifier {
  List<Notificationn> _items = [
  ];
  // var _showFavoritesOnly = false;
  String authToken;
  String userId;
  void addNewNotification(Notificationn notification){
    _items.add(notification);
    notifyListeners();
  }
  void deleteScheduleNotification(String notificationId){
    _items.removeWhere((element) => element.id==notificationId);
    notifyListeners();
  }

  void recieveToken(Auth auth, List<Notificationn> items){
    authToken = auth.token;
    userId = auth.userId;
    _items = items;
  }

  List<Notificationn> get items {
    return [..._items];
  }

  List<Notificationn> get favoriteItems {
    return _items.where((noticeItem) => noticeItem.isFavorite).toList();
  }

  Notificationn findById(String id) {
    return _items.firstWhere((notice) => notice.id == id);
  }

  // void showFavoritesOnly() {
  //   _showFavoritesOnly = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavoritesOnly = false;
  //   notifyListeners();
  // }

  Future<void> fetchAndSetNotifications() async {
    var url =
        'https://notice-board-app-2afdd-default-rtdb.firebaseio.com/notifications.json?auth=$authToken';
    try {
      final response = await http.get(Uri.parse(url));
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }
      url = 'https://notice-board-app-2afdd-default-rtdb.firebaseio.com/userFavorites/$userId.json?auth=$authToken';
      final favoriteResponse = await http.get(Uri.parse(url));
      final favoriteData = json.decode(favoriteResponse.body);
      final List<Notificationn> loadedNotifications = [];
      extractedData.forEach((noticeId, noticeData) {
        if(noticeData["isDeleted"]!="1")
        loadedNotifications.add(Notificationn(
          id: noticeId,
          title: noticeData['title'],
          description: noticeData['description'],
          //price: noticeData['price'],
          timestamp: noticeData['timeStamp'],
          session: noticeData['session'],
          noticetype: noticeData['noticetype'],
          isFavorite:
              favoriteData == null ? false : favoriteData[noticeId] ?? false,
          imageUrl: noticeData['imageUrl'],
        ));
      });
      _items = loadedNotifications;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }
  
  Future<void> deleteNotificationn(String id) async {
    final url =
        'https://notice-board-app-2afdd-default-rtdb.firebaseio.com/notifications/$id.json?auth=$authToken';
    final existingNotificationnIndex = _items.indexWhere((notice) => notice.id == id);
    Notificationn existingNotificationn = _items[existingNotificationnIndex];
    _items.removeAt(existingNotificationnIndex);
    notifyListeners();
    final response = await http.patch(
        Uri.parse(url),
      body: json.encode({
        "isDeleted" : "1",
      })
    );
    if (response.statusCode >= 400) {
      _items.insert(existingNotificationnIndex, existingNotificationn);
      notifyListeners();
      throw HttpException('Could not delete product.');
    }
    existingNotificationn = null;
  }



}
