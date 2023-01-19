import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unige_app/screens/ApplicationData.dart';
import 'package:unige_app/screens/HomePage.dart';
import 'package:unige_app/screens/LoginScreen.dart';
import 'package:unige_app/screens/RegisterUser.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  runApp(Unige_App());
}

Future<bool> checkIfUserLoggedIn() async {
  await logout();
  SharedPreferences loginCheck = await SharedPreferences.getInstance();
  // bool? result = loginCheck.getBool('isLoggedIn');

  ApplicationData.mobile =
      loginCheck.get("LoginMobileInThisSuperliciousApp").toString();
  bool phoneLength = (ApplicationData.mobile.length > 0) ? true : false;
  ApplicationData.countryCodeISO = loginCheck.get("CountryCodeISO").toString();

  return phoneLength;
}

Future<void> logout() async {
  SharedPreferences loginCheck = await SharedPreferences.getInstance();

  loginCheck.setBool("isLoggedIn", false);
  loginCheck.setString("LoginMobileInThisSuperliciousApp", "");
  loginCheck.setString("CountryCodeISO", "");

  ApplicationData.mobile = "";
  ApplicationData.countryCodeISO = "";
}

class Unige_App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        textTheme: const TextTheme(
          bodyText2: TextStyle(color: Colors.white),
        ),
      ),
      home: FutureBuilder<bool>(
          future: checkIfUserLoggedIn(),
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            if (snapshot.data == false) {
              return LoginScreen();
            } else {
              print("Going to home page - " + ApplicationData.mobile);
              return HomePage(ApplicationData.mobile);
            }
          }),
      routes: {
        LoginScreen.id: (context) => LoginScreen(),
        HomePage.id: (context) => HomePage(ApplicationData.mobile),
        RegisterUser.id: (context) => RegisterUser(),
      },
    );
  }
}
