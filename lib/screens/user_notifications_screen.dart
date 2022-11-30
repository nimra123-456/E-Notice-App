import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import 'dart:isolate';
import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:notification_board/main.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../providers/notifications.dart';
import '../widgets/user_notification_item.dart';
import '../widgets/app_drawer.dart';
import 'edit_notificationn_screen.dart';
enum DeleteOption {
  Now,
  Schedule,
}
class UserNotificationsScreen extends StatelessWidget {
  static const routeName = '/user-notifications';

  Future<void> _refreshNotifications(BuildContext context) async {
    await Provider.of<Notifications>(context, listen: false)
        .fetchAndSetNotifications();
  }

  bool isNotificationScheduled = false;
  DateTime notificationScheduleTime = DateTime.now();
  static BuildContext cntext;
  @override
  Widget build(BuildContext context) {
    cntext = context;
    return Scaffold(
      //backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Your Notifications'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(EditNotificationnScreen.routeName);
            },
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: _refreshNotifications(context),
        builder: (ctx, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : RefreshIndicator(
                    onRefresh: () => _refreshNotifications(context),
                    child: Consumer<Notifications>(
                      builder: (ctx, notificationsData, _) => Padding(
                            padding: EdgeInsets.all(8),
                            child: ListView.builder(
                              itemCount: notificationsData.items.length,
                              itemBuilder: (_, i) => Column(
                                    children: [
                                      // UserNotificationnItem(
                                      //   notificationsData.items[i].id,
                                      //   notificationsData.items[i].title,
                                      //   notificationsData.items[i].imageUrl,
                                      //     ((id)async{
                                      //       await Provider.of<Notifications>(context, listen: false).deleteNotificationn(id);
                                      //     }),
                                      // ),
                                      ListTile(
                                        title: Text(notificationsData.items[i].title),
                                        leading: notificationsData.items[i].imageUrl!=null && notificationsData.items[i].imageUrl.isNotEmpty ?
                                        CircleAvatar(
                                            backgroundImage: NetworkImage(notificationsData.items[i].imageUrl)
                                        )
                                            :CircleAvatar(
                                          child: Icon(Icons.image_not_supported_outlined),
                                        ),
                                        trailing: Container(
                                          width: 100,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: <Widget>[
                                              PopupMenuButton(
                                                onSelected: (DeleteOption selectedValue)async {
                                                  if (selectedValue == DeleteOption.Schedule) {
                                                    isNotificationScheduled = true;
                                                  } else {
                                                    isNotificationScheduled = false;
                                                  }
                                                  if(isNotificationScheduled) {
                                                    notificationScheduleTime = await pickNotificationUploadTime();
                                                    await SharedPreferences.getInstance().then((value) {
                                                      value.setString("scheduleDeleteNotification", notificationsData.items[i].id);
                                                    });

                                                    await AndroidAlarmManager.oneShotAt(
                                                      notificationScheduleTime,
                                                      Random().nextInt(pow(2, 31).toInt()),
                                                      callback,
                                                      exact: true,
                                                      wakeup: true,
                                                    );
                                                  }else{
                                                    await Provider.of<Notifications>(context, listen: false).deleteNotificationn(notificationsData.items[i].id);
                                                  }
                                                },
                                                icon: Icon(
                                                  Icons.delete,
                                                  color: Theme.of(context).errorColor,
                                                ),
                                                itemBuilder: (_) => [
                                                  PopupMenuItem(
                                                    child: Text('Delete Now'),
                                                    value: DeleteOption.Now,
                                                  ),
                                                  PopupMenuItem(
                                                    child: Text('Schedule'),
                                                    value: DeleteOption.Schedule,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Divider(),
                                    ],
                                  ),
                            ),
                          ),
                    ),
                  ),
      ),
    );
  }
  static SendPort uiSendPort;
  static Future<void> callback() async {
    print("Fireeee");
    String pendingNotiId = "";
    await SharedPreferences.getInstance().then((value) {
      pendingNotiId = value.getString("scheduleDeleteNotification");
    });
    deleteNoti(pendingNotiId);
    
    uiSendPort ??= IsolateNameServer.lookupPortByName(isolateName);
    uiSendPort?.send(null);
  }
  Future<DateTime> pickNotificationUploadTime()async{
    DateTime picked = await showDatePicker(
      context: cntext,
      initialDate: DateTime.now(),
      initialEntryMode: DatePickerEntryMode.calendar,
      initialDatePickerMode: DatePickerMode.day,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    TimeOfDay picked1 = await showTimePicker(
      context: cntext,
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

  static deleteNoti(String id)async{
    print("Function Call From Call Back");
    bool isDeleted = await deleteNotification(id);
    print("isDeleted-->$isDeleted");
    if(isDeleted){
      Fluttertoast.showToast(msg: 'Notification Deleted');
    }
  }

  static Future<bool> deleteNotification(String id) async {
    print("calling API");
    SharedPreferences _storage = await SharedPreferences.getInstance();
    final extractedUserData = json.decode(_storage.getString('userData')) as Map<String, Object>;
    String authenticationToken = extractedUserData["token"];
    final url = 'https://notice-board-app-2afdd-default-rtdb.firebaseio.com/notifications/$id.json?auth=$authenticationToken';
    final response = await http.patch(
        Uri.parse(url),
        body: json.encode({
          "isDeleted" : "1",
        })
    );
    print("Response of Delete = ${response.body}");
    print("Response of Delete = ${response.statusCode}");
    if(response.statusCode==200){
      return true;
    }else
      return false;
  }
}
