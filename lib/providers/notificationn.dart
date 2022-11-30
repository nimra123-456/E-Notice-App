import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Notificationn with ChangeNotifier {
  String id;
  String title;
  String description;
  String timestamp;
  String noticetype;
  String session;
  String imageUrl;
  bool isFavorite;

  Notificationn({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.timestamp,
    @required this.noticetype,
    @required this.session,
    @required this.imageUrl,
    this.isFavorite = false,
  });

  Notificationn.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    title = json["title"];
    description = json["description"];
    timestamp = json["timestamp"];
    noticetype = json["noticetype"];
    session = json["session"];
    imageUrl = json["imageUrl"];
  }

   Map<String, dynamic> toJson() {
     final Map<String, dynamic> data = new Map<String, dynamic>();
     data["id"] = this.id;
     data["title"] = this.title;
     data["description"] = this.description;
     data["timestamp"] = this.timestamp;
     data["noticetype"] = this.noticetype;
     data["session"] = this.session;
     data["imageUrl"] = this.imageUrl;
     return data;

  }



  void _setFavValue(bool newValue) {
    isFavorite = newValue;
    notifyListeners();
  }

   Future<void> toggleFavoriteStatus(String token, String userId,String noticeId) async {
     final oldStatus = isFavorite;
     isFavorite = !isFavorite;
     notifyListeners();
     final url =
         'https://notice-board-app-2afdd-default-rtdb.firebaseio.com/userFavorites/$userId/$noticeId.json?auth=$token';
     try {
       final response = await http.put(
           Uri.parse(url),
         body: json.encode(
           isFavorite,
         ),
       );
       if (response.statusCode >= 400) {
         _setFavValue(oldStatus);
       }
     } catch (error) {
       _setFavValue(oldStatus);
     }
   }
}
