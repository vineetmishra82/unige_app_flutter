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

Future<bool> checkIfUserLoggedIn() async {
  SharedPreferences loginCheck = await SharedPreferences.getInstance();
  bool? isLoggedIn = loginCheck.getBool('isLoggedIn') ?? false;

  ApplicationData.mobile = loginCheck.getString("LoginMobileInThisSuperliciousApp") ?? "";
  ApplicationData.countryCodeISO = loginCheck.getString("CountryCodeISO") ?? "";

  // Ensure ApplicationData.mobile is valid (not null and not empty)
  bool isMobileValid = ApplicationData.mobile.isNotEmpty ;

  return isLoggedIn && isMobileValid;
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
      home: FutureBuilder<bool>(
        future: checkIfUserLoggedIn(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show a loading indicator while waiting for the Future
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || snapshot.data == false) {
            // Go to LoginScreen if not logged in or an error occurs
            return LoginScreen();
          } else {
            // Go to HomePage if logged in
            return HomePage(ApplicationData.mobile);
          }
        },
      ),
      routes: {
        LoginScreen.id: (context) => LoginScreen(),
        HomePage.id: (context) => HomePage(ApplicationData.mobile),
        RegisterUser.id: (context) => RegisterUser(),
        LandingPageDetail.id: (context) => LandingPageDetail(),
      },
    );
  }
}

