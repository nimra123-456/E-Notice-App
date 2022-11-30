import 'package:flutter/foundation.dart';

class User with ChangeNotifier {
  final String userId;
  final String userName;
  final String email;
  final String session;
  final String photoUrl;
  

  User({
    @required this.userId,
    @required this.userName,
    @required this.email,
    @required this.session,
    @required this.photoUrl,
  });
}


