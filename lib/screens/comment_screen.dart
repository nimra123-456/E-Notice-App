import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../models/comment_model.dart';
import '../providers/auth.dart';

class Comments extends StatefulWidget {
  final String notificationId;

  Comments({
    this.notificationId,
  });

  @override
  _CommentsState createState() => _CommentsState();
}

class _CommentsState extends State<Comments> {

  Future<void> _refreshComments(BuildContext context) async {
    await buildComments();
  }

  bool _isLoading = true;
  List<CommentModel> notificationComment = [];
  TextEditingController commentController = TextEditingController();

  buildComments() {
    return notificationComment.isEmpty
        ? Container()
        : ListView.builder(
        itemCount: notificationComment.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey.shade200,
                  child: notificationComment[index].image!=null?
                  ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Image.network(notificationComment[index].image,height: 30,width: 30,fit: BoxFit.cover,))
                      :Icon(Icons.person,size: 30,color: Colors.grey,),
                ),
                SizedBox(width: 2,),
                Flexible(
                  child: Container(
                      decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(5)),
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${notificationComment[index].userName}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 5,
                                bottom: 5,
                              ),
                              child: Text(notificationComment[index].comment),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  bottom: 5,
                                  right: 5
                              ),
                              child: Text(
                                notificationComment[index].commentTime.isEmpty?"":
                                "${DateTime.fromMillisecondsSinceEpoch(int.parse(notificationComment[index].commentTime))}".substring(0,16),
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ],
                        ),
                      )),
                ),
              ],
            ),
          );
        });
  }

  bool _isInit = true;
  var _authToken = '';
  @override
  void didChangeDependencies() async {
    if (_isInit) {
      _authToken = Provider.of<Auth>(context).token;

      setState(() {
        _isLoading = false;
      });
      getComment();
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Comments'),
          backgroundColor: Colors.grey[50],
          elevation: 0.0,
        ),
        body: _isLoading
            ? Center(
          child: CircularProgressIndicator(),
        )
            : RefreshIndicator(
            onRefresh: () => _refreshComments(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: buildComments(),
                    )),
                Divider(),
                ListTile(
                  title: TextFormField(
                    controller: commentController,
                    decoration:
                    InputDecoration(labelText: "Write a comment..."),
                  ),
                  trailing: TextButton(
                    onPressed: addComment,
                    child: Icon(Icons.send_rounded),
                  ),
                ),
              ],
            )));
  }

  getComment() async {
    List comments = [];
    final url =
        'https://notice-board-app-2afdd-default-rtdb.firebaseio.com/comments/${widget.notificationId}.json?auth=$_authToken"}';
    try {
      final response = await http.get(Uri.parse(url));
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      print("extractedData--> ${extractedData}");
      final response1 = await http.get(Uri.parse('https://notice-board-app-2afdd-default-rtdb.firebaseio.com/usersData.json',));
      var _usersData = json.decode(response1.body);
      SharedPreferences _storage = await SharedPreferences.getInstance();
      String _userID = _storage.getString('comingID');
      Auth authProvider = Provider.of<Auth>(context,listen: false);
      authProvider.setUserProfileURL("${_usersData[_userID]['photoUrl']??""}");
      authProvider.setUserName("${_usersData[_userID]["userName"]??""}");

      if (extractedData != null) {
        extractedData.forEach((commentId, commentData) {
          notificationComment.add(
            CommentModel(
              userName: commentData['commentingUserName'],
              image: commentData['commentingUserProfileUrl'],
              comment:  commentData['comment'],
              commentTime: commentData["commentTime"]??"",
            ),
          );
        });

        setState(() {

        });
      }
    } catch (error) {
      print(error);
      throw error;
    }
  }

  // add comment
  Future<void> addComment() async {
    if(commentController.text.isEmpty){
      return;
    }
    print("_authToken--->${_authToken}");
    final url =
        'https://notice-board-app-2afdd-default-rtdb.firebaseio.com/comments/${widget.notificationId}.json?auth=$_authToken';
    String profileURL = Provider.of<Auth>(context, listen: false).userProfileURL;
    String userName = Provider.of<Auth>(context, listen: false).userName;
    String authToken = Provider.of<Auth>(context, listen: false).token;
    try {
      String commentTime = DateTime.now().millisecondsSinceEpoch.toString();
      final response = await http.post(
        Uri.parse(url),
        body: json.encode({
          'notificationId': widget.notificationId,
          "comment": commentController.text,
          "commentingUserName": userName,
          "commentingUserProfileUrl": profileURL,
          "commentTime": commentTime,
        }),
      );
      print(response.statusCode);

      if(response.statusCode!=200){
        Fluttertoast.showToast(msg: 'Failed to add comment');
        return;
      }

      print(response.body);
      setState(() {
        notificationComment.add(CommentModel(userName: "$ADMIN_USER_NAME", image: profileURL, comment: commentController.text,commentTime: commentTime));
        fetch_FCM_AndSend_PUSH_Notifications("$ADMIN_USER_NAME Commented on a notification",_authToken,widget.notificationId);
        commentController.clear();
      });
    } catch (error) {
      print(error);
      throw error;
    }
  }
  // Fetch all users FCM and send Push Notification
  Future<void> fetch_FCM_AndSend_PUSH_Notifications(String noti,String authToken,String notificationId) async {
    SharedPreferences _storage = await SharedPreferences.getInstance();
    String _userID = _storage.getString('comingID');
    var url = 'https://notice-board-app-2afdd-default-rtdb.firebaseio.com/usersData.json?auth=$authToken';
    try {
      final response = await http.get(Uri.parse(url));
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      List<String>fcmTokenList = [];
      if (extractedData == null) {
        return;

      }else{
        extractedData.forEach((key, value) {
          if(key!=_userID){
            if(value["fcmToken"]!=null){
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
            "id" : "$notificationId",
            "type" : "$NOTIFICATION_TYPE_COMMENT",
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
}
