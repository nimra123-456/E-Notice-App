//import 'dart:io';

import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'dart:isolate';
import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notification_board/constants.dart';
import 'package:notification_board/main.dart';
import 'package:notification_board/providers/auth.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/notificationn.dart';
import '../providers/notifications.dart';
//import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;
enum NotificationOption {
  Now,
  Schedule,
}

class EditNotificationnScreen extends StatefulWidget {
  static const routeName = '/edit-product';

  @override
  _EditNotificationnScreenState createState() =>
      _EditNotificationnScreenState();
}

class _EditNotificationnScreenState extends State<EditNotificationnScreen> {

  final _descriptionFocusNode = FocusNode();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _titleController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  String _notType;

  //String _noticeId = '';

  static File _image;
  static String _comingFirebaseURL = '';
  static var _editedNotificationn = Notificationn(
    id: null,
    title: '',
    timestamp: '',
    noticetype: '',
    session: '',
    description: '',
    imageUrl: '',
  );
  var _initValues = {
    'title': '',
    'description': '',
    'timestamp': '',
    'noticetype': '',
    'session': '',
    'imageUrl': '',
  };
  var _isInit = true;
  var _isLoading = false;

  Future imageFromCamera() async {
    final pickedFile = await ImagePicker().getImage(source: ImageSource.camera);
    if (pickedFile == null) {
      return;
    }
    _image = File(pickedFile.path);
    setState(() {});
    // return pickedFile;
  }
  Future imageFromGallery() async {
    final pickedFile = await ImagePicker().getImage(source: ImageSource.gallery);
    if (pickedFile == null) {
      return;
    }
    _image = File(pickedFile.path);
    setState(() {});
    // return pickedFile;
  }
  void _selectImage(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      builder: (_) {
        return Container(
          padding: EdgeInsets.only(top: 17),
          height: 100,
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  imageFromCamera();
                },
                child: Row(
                  children: <Widget>[
                    SizedBox(width: 25),
                    Icon(Icons.camera_alt, color: Colors.black54, size: 22,),
                    SizedBox(width: 25),
                    Text('Take Photo',
                        style: TextStyle(
                          fontSize: 17,
                          //fontWeight: FontWeight.bold,
                        )),
                  ],
                ),
              ),
              SizedBox(height: 05),
              Divider(),
              //SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  imageFromGallery();
                },
                child: Row(
                  children: <Widget>[
                    SizedBox(width: 25),
                    Icon(Icons.photo_library, color: Colors.black54, size: 22),
                    SizedBox(width: 25),
                    Text('Gallery',
                        style: TextStyle(
                          fontSize: 17,
                          //fontWeight: FontWeight.bold,
                        )),
                  ],
                ),
              ),

            ],
          ),
        );
      },
    );
  }


  static Future<String> uploadImage() async {
    String token = _image.path.split('/').last;
    final ref =
        FirebaseStorage.instance.ref().child('notifications').child('$token');
    await ref.putFile(_image);
    return await ref.getDownloadURL();
  }

  @override
  void initState() {
    AndroidAlarmManager.initialize();
    _imageUrlFocusNode.addListener(_updateImageUrl);
    _image = null;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final notificationnId =
          ModalRoute.of(context).settings.arguments as String;
      if (notificationnId != null) {
        _editedNotificationn =
            Provider.of<Notifications>(context, listen: false)
                .findById(notificationnId);
        _initValues = {
          'title': _editedNotificationn.title,
          'description': _editedNotificationn.description,
          'timeStamp': _editedNotificationn.timestamp,
          'noticetype': _editedNotificationn.noticetype,
          'session': _editedNotificationn.session,
          'imageUrl': _editedNotificationn.imageUrl,
        };
        _imageUrlController.text = _editedNotificationn.imageUrl;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      if ((!_imageUrlController.text.startsWith('http') &&
              !_imageUrlController.text.startsWith('https')) ||
          (!_imageUrlController.text.endsWith('.png') &&
              !_imageUrlController.text.endsWith('.jpg') &&
              !_imageUrlController.text.endsWith('.jpeg'))) {
        return;
      }
      setState(() {});
    }
  }

  bool isNotificationScheduled = false;
  Future<void> _saveForm() async {


    final isValid = _form.currentState.validate();
    if (_notType == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Select Notice Type')));
      return;
    }
    if (!isValid) {
      return;
    }
    _form.currentState.save();

    setState(() {
      _isLoading = true;
    });
      try {
        if(_image!=null) {
          _comingFirebaseURL = await uploadImage();
          _editedNotificationn.imageUrl = _comingFirebaseURL;
        }else{
          _editedNotificationn.imageUrl = "";
        }

        if(!isNotificationScheduled){
          Notificationn newNoti = await uploadNotification(_editedNotificationn);
          if(newNoti.title!=null||newNoti.imageUrl!=null)
          Provider.of<Notifications>(cntext, listen: false).addNewNotification(newNoti);
        }
        else{
          _editedNotificationn.timestamp = notificationScheduleTime.toIso8601String();
          Map<String, dynamic> notiTobeUpload = _editedNotificationn.toJson();
          await SharedPreferences.getInstance().then((value) {
            value.setString("scheduleNotification", json.encode(notiTobeUpload));
          });

          await AndroidAlarmManager.oneShotAt(
            notificationScheduleTime,
            Random().nextInt(pow(2, 31).toInt()),
            callback,
            exact: true,
            wakeup: true,
          );
        }
      } catch (error) {
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('An error occurred!'),
            content: Text('Something went wrong.'),
            actions: <Widget>[
              TextButton(
                child: Text('Okay'),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              ),
            ],
          ),
        );
      }
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
  }

  static SendPort uiSendPort;

  static Future<void> callback() async {
    String pendingNoti = "";
    await SharedPreferences.getInstance().then((value) {
      pendingNoti = value.getString("scheduleNotification");
    });
    Notificationn noti = Notificationn.fromJson(json.decode(pendingNoti));
    uploadNotification(noti);

    uiSendPort ??= IsolateNameServer.lookupPortByName(isolateName);
    uiSendPort?.send(null);
  }

 static Future<Notificationn> uploadNotification(Notificationn notiTobeUpload,)async{
    Notificationn newNoti = await addNotificationn(notiTobeUpload);
    return newNoti;
  }

 Future<DateTime> pickNotificationUploadTime()async{
    DateTime picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        initialEntryMode: DatePickerEntryMode.calendar,
        initialDatePickerMode: DatePickerMode.day,
        firstDate: DateTime.now(),
        lastDate: DateTime(2101),
    );
    TimeOfDay picked1 = await showTimePicker(
        context: context,
      initialTime: TimeOfDay(hour: DateTime.now().hour, minute: DateTime.now().minute),
    );
    if(picked==null){
      picked = DateTime.now();
    }if(picked1==null){
      picked1 = TimeOfDay(hour: DateTime.now().hour, minute: DateTime.now().minute);
    }
    DateTime PickedTime =  DateTime(picked.year,picked.month,picked.day,picked1.hour,picked1.minute,);
     return PickedTime;
  }

  static BuildContext cntext;
  DateTime notificationScheduleTime = DateTime.now();
  @override
  Widget build(BuildContext context) {
    cntext = context;
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: Text('Add Notification'),
        actions: <Widget>[
          PopupMenuButton(
            onSelected: (NotificationOption selectedValue)async {
              setState(() {
                if (selectedValue == NotificationOption.Schedule) {
                  isNotificationScheduled = true;
                } else {
                  isNotificationScheduled = false;
                }
              });
              if(isNotificationScheduled)
                notificationScheduleTime = await pickNotificationUploadTime();
              _saveForm();
            },
            icon: Icon(
              Icons.save,
            ),
            itemBuilder: (_) => [
              PopupMenuItem(
                child: Text('Upload Now'),
                value: NotificationOption.Now,
              ),
              PopupMenuItem(
                child: Text('Schedule'),
                value: NotificationOption.Schedule,
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _form,
                child: ListView(
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.all(8),
                      height: 200,
                      width: 200,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.yellow[100], width: 1),
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      child: _image == null
                          ? Center(
                              child: Text(
                              'No Image Selected',
                              style: TextStyle(color: Colors.white),
                            ))
                          : Container(
                              child: Image.file(_image),
                            ),
                    ),
                    ElevatedButton(
                      onPressed: () => _selectImage(context),
                      child: Text(
                        _image == null ? 'Select Image' : 'Update Image',
                      ),
                    ),
                    Container(
                      child: TextFormField(
                        controller: _titleController,
                        style: TextStyle(color: Colors.yellow),
                        cursorColor: Colors.yellow,
                        // initialValue: _initValues['title'],
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                            borderSide: BorderSide(
                              color: Colors.yellow[100],
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                            borderSide: BorderSide(
                              color: Colors.yellow[100],
                            ),
                          ),
                          labelText: 'Title',
                          labelStyle: TextStyle(
                              color: Colors.yellow[100], fontSize: 16.0),
                        ),
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context)
                              .requestFocus(_descriptionFocusNode);
                        },
                        validator: (value) {
                          if ((_image==null && value.isEmpty)||(_descriptionController.text.isNotEmpty&& value.isEmpty)) {
                            return 'Please provide a value.';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _editedNotificationn = Notificationn(
                              title: value,
                              timestamp: DateTime.now().toIso8601String(),
                              noticetype: _notType,
                              session: _editedNotificationn.session,
                              description: _editedNotificationn.description,
                              imageUrl: _comingFirebaseURL,
                              id: _editedNotificationn.id,
                              isFavorite: _editedNotificationn.isFavorite);
                        },
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      child: TextFormField(
                        style: TextStyle(color: Colors.yellow),
                        cursorColor: Colors.yellow,
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                            borderSide: BorderSide(
                              color: Colors.yellow[100],
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                            borderSide: BorderSide(
                              color: Colors.yellow[100],
                            ),
                          ),
                          labelText: 'Description',
                          labelStyle: TextStyle(
                              color: Colors.yellow[100], fontSize: 16.0),
                        ),
                        maxLines: 3,
                        keyboardType: TextInputType.multiline,
                        controller: _descriptionController,
                        //textInputAction: TextInputAction.done,
                        focusNode: _descriptionFocusNode,
                        validator: (value) {
                          if ((_image==null && value.isEmpty)||(_titleController.text.isNotEmpty&& value.isEmpty)){
                            return 'Please enter a description.';
                          }
                          if (_titleController.text.isNotEmpty&&value.length < 10) {
                            return 'Should be at least 10 characters long.';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _editedNotificationn = Notificationn(
                            title: _editedNotificationn.title,
                            timestamp: DateTime.now().toIso8601String(),
                            noticetype: _notType,
                            session: _editedNotificationn.session,
                            description: value,
                            imageUrl: _comingFirebaseURL,
                            id: _editedNotificationn.id,
                            isFavorite: _editedNotificationn.isFavorite,
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.yellow[100]),
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text("   Notice Type:",
                              style: TextStyle(
                                  fontSize: 16, color: Colors.yellow[100])),
                          Spacer(),
                          DropdownButton(
                            style: TextStyle(
                              color: Colors.yellow,
                            ),
                            dropdownColor: Colors.grey,
                            items: ['Normal', 'Important']
                                .map((e) => DropdownMenuItem(
                                      child: Text(e),
                                      value: e,
                                    ))
                                .toList(),
                            underline: Container(),
                            value: _notType,
                            onChanged: (value) {
                              setState(() {
                                FocusScope.of(context).unfocus();
                                _notType = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}


// Fetch all users FCM and send Push Notification
Future<void> fetch_FCM_AndSend_PUSH_Notifications(String noti,String id,) async {
  SharedPreferences _storage = await SharedPreferences.getInstance();
  String _userID = _storage.getString('comingID');
  final extractedUserData = json.decode(_storage.getString('userData')) as Map<String, Object>;
  String authenticationToken = extractedUserData["token"];
  var url = 'https://notice-board-app-2afdd-default-rtdb.firebaseio.com/usersData.json?auth=$authenticationToken';
  try {
    final response = await http.get(Uri.parse(url));
    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    List<String>fcmTokenList = [];
    if (extractedData == null) {
      return;

    }else{
      extractedData.forEach((key, value) {
        if(key!=_userID){
          if(value["fcmToken"]!=null&&value["fcmToken"]!=""&&value["email"]!=ADMIN_USER_EMAIL){
            fcmTokenList.add(value["fcmToken"]??"");
          }
        }
      });
      String FCM_Notification_Send_API = "https://fcm.googleapis.com/fcm/send";
      String SERVER_API_KEY = "AAAAgcDd6tE:APA91bGcD9w2dr21CjTAIkliGo8M6eaf440dRkOSktI1rN3sHFckE5w3dvaN8Q61q9ra2wlj1s9EvX5dY5aKBe9xqpqC6dmlz1lzU0z1qBmLh0Fy7cIiz-hJF5FtvgrNO4JPRgOgsapX";
      var headers = {
        'Authorization': 'key= $SERVER_API_KEY',
        'Content-Type' : 'application/json',
      };
      var body = {
        "registration_ids" : fcmTokenList,
        "notification" : {
          "title" : "Notice Board",
          "body" : "$noti",
          "sound" : "default",
        },

        "data" : {
          "id" : "$id",
          "type" : "$NOTIFICATION_TYPE_NEW_NOTIFICATION",
          'click_action'  : 'FLUTTER_NOTIFICATION_CLICK',
        }
      };
      final response = await http.post(
          Uri.parse(FCM_Notification_Send_API),
        body: json.encode(body),
        headers: headers,
      );
    }
  } catch (error) {
    throw (error);
  }
}
Future<Notificationn> addNotificationn(Notificationn notificationn,) async {
  SharedPreferences _storage = await SharedPreferences.getInstance();
  final extractedUserData = json.decode(_storage.getString('userData')) as Map<String, Object>;
  String authenticationToken = extractedUserData["token"];
  final url = 'https://notice-board-app-2afdd-default-rtdb.firebaseio.com/notifications.json?auth=$authenticationToken';
  try {
    final response = await http.post(
      Uri.parse(url),
      body: json.encode({
        'title': notificationn.title,
        'description': notificationn.description,
        'imageUrl': notificationn.imageUrl,
        'creatorId': "${extractedUserData['userId']}",
        'timeStamp': notificationn.timestamp,
        'noticetype': notificationn.noticetype,
        "isDeleted": "0",
      }),
    );
    final newNotificationn = Notificationn(
      title: notificationn.title,
      description: notificationn.description,
      timestamp: notificationn.timestamp,
      noticetype: notificationn.noticetype,
      session: notificationn.session,
      imageUrl: notificationn.imageUrl,
      id: json.decode(response.body)['name'],
    );
    fetch_FCM_AndSend_PUSH_Notifications("Admin has uploaded a new notification. See your notice board for details",newNotificationn.id,);
    return newNotificationn;
  } catch (error) {
    print(error);
    throw error;
  }
}