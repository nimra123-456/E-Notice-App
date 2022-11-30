import 'dart:convert';
import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:notification_board/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;
  Timer _authTimer;
  String _loginUserName;
  String _loginUserProfileURL;

  void setUserName(String name){
    _loginUserName = name;
    notifyListeners();
  }
  void setUserProfileURL(String url) {
    _loginUserProfileURL = url;
    notifyListeners();
  }


    String get userName {
    return _loginUserName;
  }

  String get userProfileURL {
    return _loginUserProfileURL;
  }

  bool get isAuth {
    return token != null;
  }

  String get token {
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  String get userId {
    return _userId;
  }

  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    final url =
        'https://www.googleapis.com/identitytoolkit/v3/relyingparty/$urlSegment?key=AIzaSyAN3mFC8ywUomJFrj25VsRZtvVl7o4yXgE';
    try {
      final response = await http.post(
        Uri.parse(url),
        body: json.encode(
          {
            'email': email,
            'password': password,
            'returnSecureToken': true,
          },
        ),
      );
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw responseData['error']['errors'][0]['message'];
      }
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(
            responseData['expiresIn'],
          ),
        ),
      );
      // _autoLogout();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode(
        {
          'token': _token,
          'userId': _userId,
          'expiryDate': _expiryDate.toIso8601String(),
        },
      );
      prefs.setString('userData', userData);
      final response1 = await http.get(Uri.parse('https://notice-board-app-2afdd-default-rtdb.firebaseio.com/usersData.json?auth=$_token'));
      final extractedUserData = json.decode(response1.body) as Map<String, dynamic>;
      SharedPreferences _storage = await SharedPreferences.getInstance();
      extractedUserData. forEach((key, value) {
        if(value["email"].trim()==email.trim()){
          setUserProfileURL(value["photoUrl"]);
          setUserName(ADMIN_USER_NAME);
          _storage.setString("comingID", key);
          notifyListeners();
        }
      });
    } catch (error) {
      throw error;
    }
  }

  Future<void> login(String email, String password,) async {
    return _authenticate(email, password, 'verifyPassword');
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedUserData = json.decode(prefs.getString('userData')) as Map<String, Object>;

    final expiryDate = DateTime.parse(extractedUserData['expiryDate']);

    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }
    _token = extractedUserData['token'];
    _userId = extractedUserData['userId'];
    _expiryDate = expiryDate;
    notifyListeners();
    // _autoLogout();
    return true;
  }

  Future<void> logout() async {
    SharedPreferences _storage = await SharedPreferences.getInstance();
    String _userID = _storage.getString('comingID');
    await EmptyFCMTokenInDB(_token,_userID);
    _token = null;
    _userId = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    String userID = prefs.getString('comingID');
    // prefs.remove('userData');
    prefs.clear();

    prefs.setString('comingID', userID);
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }

  EmptyFCMTokenInDB(String Token,String _userID)async{
    final response1 = await http.patch(Uri.parse('https://notice-board-app-2afdd-default-rtdb.firebaseio.com/usersData/${_userID}.json?auth=$Token'),
        body: json.encode({
          // 'email': extractedData[_userID]["email"],
          // 'userName': extractedData[_userID]["userName"],
          // 'photoUrl': extractedData[_userID]["photoUrl"],
          "fcmToken":'',
        })
    );
  }
}