import 'package:flutter/material.dart';
import 'package:googleapis/dfareporting/v4.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unige_app/screens/ApplicationData.dart';
import 'package:unige_app/screens/HomePage.dart';
import 'package:unige_app/screens/LandingPage.dart';
import 'package:unige_app/screens/LoginScreen.dart';
import 'package:unige_app/screens/RegisterUser.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(UnigeApp());
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
            return HomePage(snapshot.data!); // ← pass clean mobile number
          }
        },
      ),

      routes: {
        LoginScreen.id: (context) => LoginScreen(),
        HomePage.id: (context) => HomePage(ApplicationData.mobile),
        RegisterUser.id: (context) => RegisterUser(),
        LandingPageDetail.id: (context) => LandingPageDetail(ApplicationData.mobile),
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

