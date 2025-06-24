import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:googleapis/dfareporting/v4.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unige_app/screens/ApplicationData.dart';
import 'package:unige_app/screens/HomePage.dart';
import 'package:unige_app/screens/LandingPage.dart';
import 'package:unige_app/screens/LoginScreen.dart';
import 'package:unige_app/screens/RegisterUser.dart';


import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  runApp(UnigeApp());
  requestNotificationPermissions();
  setUpFlutterNotifications();
}

void requestNotificationPermissions() async {
 FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
 await firebaseMessaging.requestPermission(
   alert: true,
   announcement: false,
   badge: true,
   carPlay: false,
   criticalAlert: false,
   provisional: false,
   sound: true,
  );
}

void setUpFlutterNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings();

  final InitializationSettings initializationSettings =
  InitializationSettings(android: initializationSettingsAndroid,
  iOS: initializationSettingsDarwin
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings);

  //Front handler

  FirebaseMessaging.onMessage.listen((RemoteMessage message){
    RemoteNotification? notification = message.notification;
    print("Notification received: ${message.data}");
    if(notification!=null)
      {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          const NotificationDetails(
            android: AndroidNotificationDetails('default_channel', 'Default', importance: Importance.max, priority: Priority.high),
            iOS: DarwinNotificationDetails(),
          ),
        );
      }
    print("Current key state: $homePageKey");
    print("Current HomePage state: ${homePageKey.currentState}");
    if(homePageKey.currentState != null) {

      homePageKey.currentState!.loadMyProducts();
    } else {
      print('HomePage is not mounted!');
    }

  });

}



Future<String?> getLoggedInMobile() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  if (!isLoggedIn) return null;

  String? mobile = prefs.getString("LoginMobileInThisSuperliciousApp");

  return (mobile != null && mobile.isNotEmpty) ? mobile : null;
}


class ApplicationData {
  static String mobile = "";
  static String countryCodeISO = "";
}

class UnigeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
        ),
      ),
      home: FutureBuilder<String?>(
        future: getLoggedInMobile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return LoginScreen();
          } else {
            // Now it's guaranteed to be loaded
            return HomePage(snapshot.data!,key: homePageKey); // ← pass clean mobile number
          }
        },
      ),

      routes: {
        LoginScreen.id: (context) => LoginScreen(),
        HomePage.id: (context) => HomePage(ApplicationData.mobile),
        RegisterUser.id: (context) => RegisterUser(),
        LandingPageDetail.id: (context) => LandingPageDetail(ApplicationData.mobile,key: homePageKey),
      },
    );
  }

  Future<String> getMobileFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    ApplicationData.mobile = prefs.getString("LoginMobileInThisSuperliciousApp") ?? "";
    print("in main ApplicationData.mobile is ${ApplicationData.mobile}");
    return prefs.getString("LoginMobileInThisSuperliciousApp") ?? "";
  }
}

