import 'dart:isolate';
import 'dart:ui';

import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:notification_board/providers/users.dart';
import 'package:notification_board/screens/login.dart';
import 'package:provider/provider.dart';

import './screens/splash_screen.dart';
import 'screens/notifications_overview_screen.dart';
import 'screens/notificationn_detail_screen.dart';
import 'providers/notifications.dart';
import './providers/auth.dart';
import 'screens/user_notifications_screen.dart';
import 'screens/edit_notificationn_screen.dart';
import './screens/auth_screen.dart';
import './screens/signup.dart';
import './helpers/custom_route.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message ${message.data}');
}

/// The [SharedPreferences] key to access the alarm fire count.
const String countKey = 'count';
/// The name associated with the UI isolate's [SendPort].
const String isolateName = 'isolate';
/// A port used to communicate from a background isolate to the UI isolate.
final ReceivePort port = ReceivePort();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  IsolateNameServer.registerPortWithName(
    port.sendPort,
    isolateName,
  );
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, Notifications>(
          create: (ctx) => Notifications(),
          update: (ctx, auth, previousNotifications) => previousNotifications
            ..recieveToken(
              auth,
              previousNotifications == null ? [] : previousNotifications.items,
            ),
        ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) {

          return MaterialApp(
          title: 'e-Notice',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.grey,
            accentColor: Colors.deepOrange,
            fontFamily: 'Lato',
            pageTransitionsTheme: PageTransitionsTheme(builders: {
              TargetPlatform.android: CustomPageTransitionBuilder(),
              TargetPlatform.iOS: CustomPageTransitionBuilder(),
            }),
          ),
          home: auth.isAuth
              ? NotificationsOverviewScreen()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (ctx, authResultSnapshot) =>
                      authResultSnapshot.connectionState ==
                              ConnectionState.waiting
                          ? SplashScreen()
                          : LogInScreen(),
                ),
          routes: {
            NotificationnDetailScreen.routeName: (ctx) =>
                NotificationnDetailScreen(),
            UserNotificationsScreen.routeName: (ctx) =>
                UserNotificationsScreen(),
            EditNotificationnScreen.routeName: (ctx) =>
                EditNotificationnScreen(),
          },
        );
        }
      ),
    );
  }

}
