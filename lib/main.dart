import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:googleapis/dfareporting/v4.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unige_app_flutter/screens/ApplicationData.dart';
import 'package:unige_app_flutter/screens/DesktopWarning.dart';
import 'package:unige_app_flutter/screens/HomePage.dart';
import 'package:unige_app_flutter/screens/LandingPage.dart';
import 'package:unige_app_flutter/screens/LoginScreen.dart';
import 'package:unige_app_flutter/screens/RegisterUser.dart';
import 'firebase_options.dart';



import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // await requestNotificationPermissions();
  // await setUpFlutterNotifications();
  runApp(UnigeApp());

}




Future<String?> getLoggedInMobile() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  if (!isLoggedIn) return null;

  String? mobile = prefs.getString("LoginMobileInThisSuperliciousApp");

  return (mobile != null && mobile.isNotEmpty) ? mobile : null;
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
      home: Builder(
        builder: (context) {
          // Only apply restriction on web
          if (kIsWeb) {
            double width = MediaQuery.of(context).size.width;
            if (width > 600) { // You can adjust threshold as needed
              return DesktopWarning();
            }
          }
          // Continue as normal
          return FutureBuilder<String?>(
            future: getLoggedInMobile(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return LoginScreen();
              } else {
                return HomePage(snapshot.data!, key: homePageKey);
              }
            },
          );
        },
      ),
      routes: {
        LoginScreen.id: (context) => LoginScreen(),
        HomePage.id: (context) => HomePage(ApplicationData.mobile),
        RegisterUser.id: (context) => RegisterUser(),
        LandingPageDetail.id: (context) => LandingPageDetail(ApplicationData.mobile, key: homePageKey),
      },
    );
  }
}

  Future<String> getMobileFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    ApplicationData.mobile = prefs.getString("LoginMobileInThisSuperliciousApp") ?? "";
    print("in main ApplicationData.mobile is ${ApplicationData.mobile}");
    return prefs.getString("LoginMobileInThisSuperliciousApp") ?? "";
  }


