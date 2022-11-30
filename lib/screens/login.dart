import 'dart:convert';
import 'dart:ffi';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:notification_board/constants.dart';
import 'package:notification_board/main.dart';
import 'package:notification_board/models/http_exception.dart';
import 'package:notification_board/providers/auth.dart';
import 'package:notification_board/screens/signup.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LogInScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(0, 0, 0, 0).withOpacity(1.0),
                  Color.fromRGBO(128, 128, 128, 1).withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0, 1],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: Container(
                      margin: EdgeInsets.only(bottom: 20.0),
                      padding:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 94.0),
                      transform: Matrix4.rotationZ(-8 * pi / 180)
                        ..translate(-10.0),
                      // ..translate(-10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.deepOrange.shade900,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 8,
                            color: Colors.black26,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      child: Text(
                        'Notices',
                        style: TextStyle(
                          color:
                              Theme.of(context).accentTextTheme.headline6.color,
                          fontSize: 50,
                          fontFamily: 'Anton',
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: deviceSize.width > 600 ? 2 : 1,
                    child: LogInCard(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LogInCard extends StatefulWidget {
  const LogInCard({Key key}) : super(key: key);

  @override
  _LogInCardState createState() => _LogInCardState();
}

class _LogInCardState extends State<LogInCard> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  var _isLoading = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool showPassword = true;

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('An Error Occurred!'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }


  @override void initState(){
    super.initState();
    configureFirebase();
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 8.0,
      child: Container(
        height: 250,
        width: deviceSize.width * 0.75,
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(
                      labelText: 'E-Mail',
                      suffixIcon: Icon(Icons.email_rounded)),
                  keyboardType: TextInputType.emailAddress,
                  controller: _emailController,
                  validator: (value) {
                    if (value.isEmpty || !value.contains('@')) {
                      return 'Invalid email!';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: '******',
                      suffixIcon: GestureDetector(
                        onTap: () {
                          setState(() {
                            showPassword = !showPassword;
                          });
                        },
                        child: showPassword == true
                            ? Icon(Icons.visibility_off)
                            : Icon(Icons.remove_red_eye),
                      )),
                  obscureText: showPassword,
                  controller: _passwordController,
                  validator: (value) {
                    if (value.isEmpty || value.length < 5) {
                      return 'Password is too short!';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 05),
                _isLoading?
                SizedBox()
                    : GestureDetector(
                  onTap: ()async{
                      FirebaseAuth.instance.sendPasswordResetEmail(email:"$ADMIN_USER_EMAIL",);
                      _showErrorDialog("Reset password link has been sent on $ADMIN_USER_EMAIL");
                  },
                  child: Container(margin: EdgeInsets.only(left: 135,top: 5),
                      child: Text('Forgot Password?')),
                ),
                SizedBox(height: 12),
                if (_isLoading)
                  CircularProgressIndicator()
                else
                  ElevatedButton(
                    child: Text('LOG IN'),
                    onPressed: () async {
                      if (!_formKey.currentState.validate()) {
                        // Invalid!
                        return;
                      }else if(_emailController.text.trim()!="$ADMIN_USER_EMAIL"){
                       String errorMessage = 'Could not find an admin with that email.';
                        _showErrorDialog(errorMessage);
                        return;
                      }
                      setState(() {
                        _isLoading = true;
                      });

                      try {
                        final authProvider =
                            Provider.of<Auth>(context, listen: false);
                        await authProvider.login(_emailController.text, _passwordController.text);
                        UserCredential credentials = await FirebaseAuth.instance.signInWithEmailAndPassword(email: _emailController.text, password: _passwordController.text);
                        print("credentials-->${credentials.user}");
                        RefreshFCMTokenInDB(authProvider.token);
                      } catch (error) {
                        var errorMessage = 'Authentication failed';
                        if (error.toString().contains('EMAIL_EXISTS')) {
                          errorMessage =
                          'This email address is already in use.';
                        } else if (error.toString().contains('INVALID_EMAIL')) {
                          errorMessage = 'This is not a valid email address';
                        } else if (error.toString().contains('WEAK_PASSWORD')) {
                          errorMessage = 'This password is too weak.';
                        } else if (error.toString().contains(
                            'EMAIL_NOT_FOUND')) {
                          errorMessage =
                          'Could not find a user with that email.';
                        } else if (error.toString().contains(
                            'INVALID_PASSWORD')) {
                          errorMessage = 'Invalid password.';
                        } else
                          errorMessage =
                          'Could not authenticate you. Please try again later.';
                        _showErrorDialog(errorMessage);
                      }
                      if(this.mounted){
                      setState(() {
                        _isLoading = false;
                      });
                      }
                    }, //_submit,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
                      primary: Theme.of(context).primaryColor,
                      onPrimary:
                          Theme.of(context).primaryTextTheme.button.color,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String FCM_TOKEN = "";
  // Configuration of FCM
  configureFirebase()async{
    FirebaseMessaging.instance.getToken().then((value) {
      print("FCM Token:-> $value");
      FCM_TOKEN = value;
    });
  }
  RefreshFCMTokenInDB(String Token)async{
    // final response = await http.get('https://notice-board-app-2afdd-default-rtdb.firebaseio.com/usersData.json?auth=$Token');
    // final extractedData = json.decode(response.body) as Map<String, dynamic>;
    // Refresh FCM
    SharedPreferences _storage = await SharedPreferences.getInstance();
    String _userID = _storage.getString('comingID');
    final response1 = await http.patch(Uri.parse('https://notice-board-app-2afdd-default-rtdb.firebaseio.com/usersData/${_userID}.json?auth=$Token'),
        body: json.encode({
          // 'email': extractedData[_userID]["email"],
          // 'userName': extractedData[_userID]["userName"],
          // 'session': extractedData[_userID]["session"],
          // 'photoUrl': extractedData[_userID]["photoUrl"],
          "fcmToken":FCM_TOKEN,
        })
    );
  }
}