// import 'dart:convert';
// import 'dart:io';
//
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:notification_board/main.dart';
// import 'package:notification_board/providers/auth.dart';
// import 'package:notification_board/providers/user.dart';
// import 'package:notification_board/screens/login.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:notification_board/models/http_exception.dart';
//
// class SignUpScreen extends StatefulWidget {
//   //static const routeName = '/auth';
//
//   @override
//   _SignUpScreenState createState() => _SignUpScreenState();
// }
//
// class _SignUpScreenState extends State<SignUpScreen> {
//   final GlobalKey<FormState> _formKey = GlobalKey();
//   var _isLoading = false;
//   SharedPreferences _storage;
//   final _usernameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   bool showPassword1 = true;
//   bool showPassword2 = true;
//
//   bool _isInit = true;
//   String _sessionn;
//   File _image;
//   String _comingFirebaseURL = '';
//
//   Future<void> imageFromCamera() async {
//     final pickedFile =
//         await ImagePicker().getImage(source: ImageSource.camera);
//     if (pickedFile == null) {
//       return;
//     }
//     setState(() {
//       _image = File(pickedFile.path);
//       print('here');
//       print('Path : ${_image.toString()}');
//       print(_image == null);
//     });
//   }
//
//   Future<void> imageFromGallery() async {
//     final pickedFile =
//         await ImagePicker().getImage(source: ImageSource.gallery);
//     if (pickedFile == null) {
//       return;
//     }
//     setState(() {
//       _image = File(pickedFile.path);
//       print('here');
//       print('Path : ${_image.toString()}');
//       print(_image == null);
//     });
//   }
//
//   void _selectImage(BuildContext ctx) {
//     showModalBottomSheet(
//       context: ctx,
//       builder: (_) {
//         return Container(
//           padding: EdgeInsets.only(top: 17),
//           height: 100,
//           child: Column(
//             children: [
//                GestureDetector(
//             onTap: () {
//               imageFromCamera();
//             },
//             child: Row(
//               children: <Widget>[
//                 SizedBox(width: 25),
//                 Icon(Icons.camera_alt, color: Colors.black54, size: 22,),
//                 SizedBox(width: 25),
//                 Text('Take Photo',
//                     style: TextStyle(
//                       fontSize: 17,
//                       //fontWeight: FontWeight.bold,
//                     )),
//               ],
//             ),
//           ),
//           SizedBox(height: 05),
//           Divider(),
//           //SizedBox(height: 10),
//                GestureDetector(
//             onTap: () {
//               imageFromGallery();
//             },
//             child: Row(
//               children: <Widget>[
//                 SizedBox(width: 25),
//                 Icon(Icons.photo_library, color: Colors.black54, size: 22),
//                 SizedBox(width: 25),
//                 Text('Gallery',
//                     style: TextStyle(
//                       fontSize: 17,
//                       //fontWeight: FontWeight.bold,
//                     )),
//               ],
//             ),
//           ),
//
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   Future<String> uploadImage() async {
//     print('here 1');
//
//     String token = _image.path.split('/').last;
//     print('Image Name : $token');
//
//     print('here 2');
//
//     final ref =
//         FirebaseStorage.instance.ref().child('notifications').child('$token');
//     print('here 3');
//
//     await ref.putFile(_image);
//     print('here 4');
//
//     return await ref.getDownloadURL();
//   }
//
//   @override
//   void didChangeDependencies() async {
//     if (_isInit) {
//       _storage = await SharedPreferences.getInstance();
//     }
//     _isInit = false;
//     super.didChangeDependencies();
//   }
//
//   void _showErrorDialog(String message) {
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: Text('An Error Occurred!'),
//         content: Text(message),
//         actions: <Widget>[
//           TextButton(
//             child: Text('Okay'),
//             onPressed: () {
//               Navigator.of(ctx).pop();
//             },
//           )
//         ],
//       ),
//     );
//   }
//
//   @override void initState() {
//     configureFirebase();
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final deviceSize = MediaQuery.of(context).size;
//
//     // final transformConfig = Matrix4.rotationZ(-8 * pi / 180);
//     // transformConfig.translate(-10.0);
//     return Scaffold(
//       // resizeToAvoidBottomInset: false,
//       body: Stack(
//         children: <Widget>[
//           Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [
//                   Color.fromRGBO(0, 0, 0, 0).withOpacity(1.0),
//                   Color.fromRGBO(128, 128, 128, 1).withOpacity(0.7),
//                 ],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 stops: [0, 1],
//               ),
//             ),
//           ),
//           SingleChildScrollView(
//             child: Container(
//               height: deviceSize.height,
//               width: deviceSize.width,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: <Widget>[
//                   Stack(
//                     children: [
//                       Container(
//                         height: 110,
//                         width: 180,
//                         margin: EdgeInsets.only(bottom: 20.0),
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(20),
//                           //color: Colors.red,
//                           // image: DecorationImage(
//                           //   image: AssetImage('assets/images/profile2.png'),
//                           //   //fit: BoxFit.cover
//                           // ),
//                         ),
//                         child: _image == null
//                             ? Center(
//                                 child:
//                                     Image.asset('assets/images/profile2.png'),
//                               )
//                             : CircleAvatar(
//                                 child: Container(
//                                   height: 110,
//                                   width: 110,
//                                   child: ClipRRect(
//                                     borderRadius: BorderRadius.circular(50),
//                                     child: Image.file(
//                                       _image,
//                                       fit: BoxFit.cover,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                       ),
//                       Positioned(
//                         top: 80,
//                         right: 33.0,
//                         child: Container(
//                           height: 40,
//                           width: 40,
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(25),
//                             color: Colors.grey,
//                           ),
//                           child: Center(
//                             child: GestureDetector(
//                                 onTap: () => _selectImage(context),
//                                 child: Icon(Icons.camera_alt,
//                                     color: Colors.black)),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   Flexible(
//                     flex: deviceSize.width > 600 ? 2 : 1,
//                     child: Card(
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10.0),
//                       ),
//                       elevation: 8.0,
//                       child: Container(
//                         height: 390,
//                         width: deviceSize.width * 0.75,
//                         padding: EdgeInsets.all(16.0),
//                         child: Form(
//                           key: _formKey,
//                           child: SingleChildScrollView(
//                             child: Column(
//                               children: <Widget>[
//                                 TextFormField(
//                                   decoration: InputDecoration(
//                                     labelText: 'User Name',
//                                     suffixIcon: Icon(Icons.person),
//                                   ),
//                                   keyboardType: TextInputType.name,
//                                   controller: _usernameController,
//                                   validator: (value) {
//                                     if (value.isEmpty) {
//                                       return 'Invalid User Name';
//                                     }
//                                     return null;
//                                   },
//                                   // onSaved: (value) {
//                                   //   _authData['email'] = value;
//                                   // },
//                                 ),
//                                 TextFormField(
//                                   decoration: InputDecoration(
//                                     labelText: 'E-Mail',
//                                     suffixIcon: Icon(Icons.email),
//                                   ),
//                                   keyboardType: TextInputType.emailAddress,
//                                   controller: _emailController,
//                                   validator: (value) {
//                                     if (value.isEmpty || !value.contains('@')) {
//                                       return 'Invalid email!';
//                                     }
//                                     return null;
//                                   },
//                                   // onSaved: (value) {
//                                   //   _authData['email'] = value;
//                                   // },
//                                 ),
//                                 TextFormField(
//                                   decoration: InputDecoration(
//                                       labelText: 'Password',
//                                       hintText: '******',
//                                       suffixIcon: GestureDetector(
//                                         onTap: () {
//                                           setState(() {
//                                             showPassword1 = !showPassword1;
//                                           });
//                                         },
//                                         child: showPassword1 == true
//                                             ? Icon(Icons.visibility_off)
//                                             : Icon(Icons.remove_red_eye),
//                                       )),
//                                   obscureText: showPassword1,
//                                   controller: _passwordController,
//                                   validator: (value) {
//                                     if (value.isEmpty || value.length < 5) {
//                                       return 'Password is too short!';
//                                     }
//                                     return null;
//                                   },
//                                   // onSaved: (value) {
//                                   //   _authData['password'] = value;
//                                   // },
//                                 ),
//                                 TextFormField(
//                                   decoration: InputDecoration(
//                                       labelText: 'Confirm Password',
//                                       hintText: '******',
//                                       suffixIcon: GestureDetector(
//                                         onTap: () {
//                                           setState(() {
//                                             showPassword2 = !showPassword2;
//                                           });
//                                         },
//                                         child: showPassword2 == true
//                                             ? Icon(Icons.visibility_off)
//                                             : Icon(Icons.remove_red_eye),
//                                       )),
//                                   obscureText: showPassword2,
//                                   validator: (value) {
//                                     if (value != _passwordController.text) {
//                                       return 'Passwords do not match!';
//                                     }
//                                     return null;
//                                   },
//                                 ),
//                                 Container(
//                                   decoration: BoxDecoration(
//                                     border: Border(
//                                       bottom: BorderSide(
//                                           width: 0.7, color: Colors.grey[600]),
//                                     ),
//                                   ),
//                                   child: Row(
//                                     mainAxisAlignment: MainAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         "Session:",
//                                         style: TextStyle(
//                                           fontSize: 18,
//                                           color: Colors.grey[600],
//                                         ),
//                                       ),
//                                       Spacer(),
//                                       DropdownButton(
//                                         items: [
//                                           'BS(2017-2021)',
//                                           'BS(2018-2022)',
//                                           'BS(2019-2023)',
//                                           'BS(2020-2024)',
//                                           'MCS(2019-2021)',
//                                           'MCS(2020-2022)',
//                                         ]
//                                             .map((e) => DropdownMenuItem(
//                                                   child: Text(e),
//                                                   value: e,
//                                                 ))
//                                             .toList(),
//                                         underline: Container(),
//                                         value: _sessionn,
//                                         onChanged: (value) {
//                                           setState(() {
//                                             FocusScope.of(context).unfocus();
//                                             _sessionn = value;
//                                           });
//                                           print('$_sessionn : $value');
//                                         },
//                                         //validator: (value) => value == null ? 'field required' : null,
//                                         //     validator: (value) {
//                                         //   if (value.isEmpty) {
//                                         //     return 'Please select session!';
//                                         //   }
//                                         //   return null;
//                                         // },
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 // SizedBox(
//                                 //   height: 15,
//                                 // ),
//                                 if (_isLoading)
//                                   CircularProgressIndicator()
//                                 else
//                                   ElevatedButton(
//                                     child: Text('SIGN UP'),
//                                     onPressed: () async {
//                                       //_editedNotificationn.imageUrl = _comingFirebaseURL;
//
//                                       if (!_formKey.currentState.validate()) {
//                                         // Invalid!
//                                         return;
//                                       }
//                                       if (_image == null) {
//                                         ScaffoldMessenger.of(context)
//                                             .showSnackBar(SnackBar(
//                                                 content:
//                                                     Text('No Image Selected')));
//                                         return;
//                                       }
//
//                                       if (_sessionn == null) {
//                                         ScaffoldMessenger.of(context)
//                                             .showSnackBar(SnackBar(
//                                                 content:
//                                                     Text('Select Session')));
//                                         return;
//                                       }
//
//                                       setState(() {
//                                         _isLoading = true;
//                                       });
//                                       try {
//                                         final authProvider = Provider.of<Auth>(
//                                             context,
//                                             listen: false);
//
//                                         await authProvider.signup(
//                                             _emailController.text,
//                                             _passwordController.text);
//                                         setState(() {});
//
//                                         _comingFirebaseURL =
//                                             await uploadImage();
//
//                                         print(
//                                             'URL After Image Save : $_comingFirebaseURL');
//                                         //
//
//                                         final authToken = authProvider.token;
//
//                                         print(
//                                             'Token From Provider : : $authToken');
//
//                                         final response = await http.post('https://notice-board-app-2afdd-default-rtdb.firebaseio.com/usersData.json?auth=$authToken',
//                                             body: json.encode({
//                                               'email': _emailController.text,
//                                               'userName':
//                                                   _usernameController.text,
//                                               'session': _sessionn,
//                                               'photoUrl': _comingFirebaseURL,
//                                               "fcmToken":FCM_TOKEN,
//                                             }));
//                                         await _storage.setString('comingID',
//                                             json.decode(response.body)['name']);
//                                         print(
//                                             'Coming Response : ${json.decode(response.body)}');
//                                       } on HttpException catch (error) {
//                                         var errorMessage =
//                                             'Authentication failed';
//                                         if (error
//                                             .toString()
//                                             .contains('EMAIL_EXISTS')) {
//                                           errorMessage =
//                                               'This email address is already in use.';
//                                         } else if (error
//                                             .toString()
//                                             .contains('INVALID_EMAIL')) {
//                                           errorMessage =
//                                               'This is not a valid email address';
//                                         } else if (error
//                                             .toString()
//                                             .contains('WEAK_PASSWORD')) {
//                                           errorMessage =
//                                               'This password is too weak.';
//                                         } else if (error
//                                             .toString()
//                                             .contains('EMAIL_NOT_FOUND')) {
//                                           errorMessage =
//                                               'Could not find a user with that email.';
//                                         } else if (error
//                                             .toString()
//                                             .contains('INVALID_PASSWORD')) {
//                                           errorMessage = 'Invalid password.';
//                                         }
//                                         _showErrorDialog(errorMessage);
//                                       } catch (error) {
//                                         const errorMessage =
//                                             'Could not authenticate you. Please try again later.';
//                                         _showErrorDialog(errorMessage);
//                                       }
//
//                                       if (this.mounted) {
//                                         setState(() {
//                                           _isLoading = false;
//                                         });
//                                       }
//                                     },
//
//                                     //_submit,
//
//                                     style: ElevatedButton.styleFrom(
//                                       shape: RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.circular(30),
//                                       ),
//                                       padding: EdgeInsets.symmetric(
//                                           horizontal: 30.0, vertical: 8.0),
//                                       primary: Theme.of(context).primaryColor,
//                                       onPrimary: Theme.of(context)
//                                           .primaryTextTheme
//                                           .button
//                                           .color,
//                                     ),
//                                   ),
//                                 Container(
//                                   padding: EdgeInsets.only(
//                                       top: 05, left: 20, right: 05),
//                                   child: Row(children: <Widget>[
//                                     Text('Already have an account?'),
//                                     TextButton(
//                                       child: Text('Log In'),
//                                       onPressed: () {
//                                         Navigator.pushReplacement(
//                                           context,
//                                           MaterialPageRoute(
//                                               builder: (context) =>
//                                                   LogInScreen()),
//                                         );
//                                       },
//                                     )
//                                   ]),
//                                 )
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//   String FCM_TOKEN = "";
//   // Configuration of FCM
//   configureFirebase()async{
//     FirebaseMessaging.instance.getToken().then((value) {
//       print("FCM Token:-> $value");
//       FCM_TOKEN = value;
//     });
//   }
// }
