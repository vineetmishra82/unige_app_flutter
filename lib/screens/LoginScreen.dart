import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:unige_app/Other_data/Countries.dart';

import '../Other_data/Apis.dart';
import 'ApplicationData.dart';
import 'OTPVerify.dart';
import 'RegisterUser.dart';

class LoginScreen extends StatefulWidget {
  static String id = "LoginScreen";
  static String mobile = "";
  static String countryCode = "";
  static String countryCodeISO = ApplicationData.countryCodeISO;

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final txt = TextEditingController();
  int maxPhoneLength = 0;
  bool showSpinner = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 54.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(
                  height: 48.0,
                ),
                Hero(
                  tag: 'logo',
                  child: SizedBox(
                    height: 100.0,
                    child: Image.asset('images/logo.png'),
                  ),
                ),
                const SizedBox(
                  height: 100.0,
                ),
                Padding(
                  padding: const EdgeInsets.all(0),
                  child: Column(
                    children: <Widget>[
                      IntlPhoneField(
                        dropdownIconPosition: IconPosition.trailing,
                        initialCountryCode: checkSavedCountryCode(),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16.0,
                        ),
                        dropdownTextStyle: const TextStyle(color: Colors.green),
                        disableLengthCheck: true,
                        textAlign: TextAlign.left,
                        decoration: const InputDecoration(
                          enabled: true,
                          labelText: "Enter your number",
                          labelStyle: TextStyle(
                            color: Colors.blue,
                            fontSize: 18.0,
                          ),
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          prefixStyle: TextStyle(
                            color: Colors.blue,
                            fontSize: 18.0,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 0.0),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(32.0)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.lightBlueAccent, width: 2.0),
                            borderRadius:
                                BorderRadius.all(Radius.circular(32.0)),
                          ),
                        ),
                        enabled: true,
                        onCountryChanged: (country) {
                          LoginScreen.countryCode = country.dialCode;
                          LoginScreen.countryCodeISO = country.code;
                          print(
                              "New country code - " + LoginScreen.countryCode);
                        },
                        onChanged: (phone) {
                          LoginScreen.mobile =
                              LoginScreen.countryCode + phone.number;
                          print("Entered num is " + LoginScreen.mobile);
                        },
                      ),
                      const SizedBox(
                        height: 24.0,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 50.0),
                        child: Material(
                          color: Colors.blue,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(30.0)),
                          elevation: 5.0,
                          child: MaterialButton(
                            onPressed: () async {
                              print("Width - " +
                                  ApplicationData.screenWidth.toString() +
                                  " And height - " +
                                  ApplicationData.screenHeight.toString());
                              showSpinner = true;
                              if (LoginScreen.mobile.isNotEmpty) {
                                setState(() {});

                                var url = Uri.parse(
                                    Apis.userExists(LoginScreen.mobile));
                                print(url);
                                var response = await http.get(url);
                                print("Response to login is " + response.body);
                                if (response.body == "true") {
                                  setState(() {
                                    showSpinner = false;
                                  });
                                  ApplicationData.mobile = LoginScreen.mobile;
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => OTPVerify(
                                              1,
                                              LoginScreen.mobile,
                                              LoginScreen.countryCode,
                                              LoginScreen.countryCodeISO,
                                              "",
                                              "",
                                              "")));
                                } else {
                                  final snackBar = SnackBar(
                                    content: const Text("User not registered"),
                                    action: SnackBarAction(
                                      label: 'Invalid User',
                                      onPressed: () {},
                                    ),
                                  );
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBar);
                                  setState(() {
                                    showSpinner = false;
                                  });
                                }
                              } else {
                                final snackBar = SnackBar(
                                  content:
                                      Text("Need a mobile number to login"),
                                  action: SnackBarAction(
                                    label: 'Invalid input',
                                    onPressed: () {},
                                  ),
                                );

                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackBar);
                              }
                            },
                            minWidth: 200.0,
                            height: 42.0,
                            child: const Text(
                              'Log In',
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5.0, horizontal: 30.0),
                        child: InkWell(
                          child: const Text(
                            'New User ? Register here',
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.blue,
                                fontWeight: FontWeight.bold),
                          ),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => RegisterUser()));
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  getMaxLength() {
    if (LoginScreen.countryCode == "") {
      return 10;
    } else {
      for (Country country in countries) {
        if (country.dialCode == LoginScreen.countryCode) {
          int length = (country.dialCode).length + country.maxLength;
          print("max kength is " + length.toString());
          return length;
        }
      }
    }
  }

  checkSavedCountryCode() {
    print(
        "ApplicationData.countryCodeISO is " + ApplicationData.countryCodeISO);
    if (ApplicationData.countryCodeISO == "") {
      LoginScreen.countryCode = "+41";
      return "CH";
    } else {
      return ApplicationData.countryCodeISO;
    }
  }
}
