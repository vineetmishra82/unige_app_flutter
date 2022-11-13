import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:unige_app/screens/ApplicationData.dart';
import 'package:unige_app/screens/LoginScreen.dart';
import 'package:unige_app/screens/OTPVerify.dart';

import '../Other_data/Apis.dart';
import '../Other_data/Countries.dart';

class RegisterUser extends StatefulWidget {
  static String id = "RegisterUser";

  @override
  _RegisterUserState createState() => _RegisterUserState();
}

class _RegisterUserState extends State<RegisterUser> {
  late String mobile = "",
      email = "",
      name = "",
      countryCode = "",
      countryCodeISO = "";

  bool showSpinner = false;

  @override
  Widget build(BuildContext context) {
    String? dropdownValue = "Gurugram";
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 54.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
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
                  height: 40.0,
                ),
                Center(
                  child: IntlPhoneField(
                    dropdownIconPosition: IconPosition.trailing,
                    initialCountryCode: checkSavedCountryCode(),
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 16.0,
                    ),
                    dropdownTextStyle: const TextStyle(color: Colors.green),
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
                          vertical: 10.0, horizontal: 10.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(32.0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.lightBlueAccent, width: 2.0),
                        borderRadius: BorderRadius.all(Radius.circular(32.0)),
                      ),
                    ),
                    enabled: true,
                    onCountryChanged: (country) {
                      countryCode = country.dialCode;
                      countryCodeISO = country.code;
                      print("New country code - " + LoginScreen.countryCode);
                    },
                    onChanged: (phone) {
                      mobile = countryCode + phone.number;
                      print("Entered num is " + mobile);
                    },
                  ),
                ),
                Center(
                  child: TextField(
                    onChanged: (value) {
                      name = value;
                      print(value);
                    },
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 18.0,
                    ),
                    maxLength: 100,
                    keyboardType: TextInputType.name,
                    decoration: const InputDecoration(
                      enabled: true,
                      labelText: "Your Name",
                      labelStyle: TextStyle(
                        color: Colors.blue,
                        fontSize: 18.0,
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 20.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(32.0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.lightBlueAccent, width: 2.0),
                        borderRadius: BorderRadius.all(Radius.circular(32.0)),
                      ),
                    ),
                  ),
                ),
                Center(
                  child: TextField(
                    onChanged: (value) {
                      email = value;
                      print(value);
                    },
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 18.0,
                    ),
                    maxLength: 100,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      enabled: true,
                      labelText: "Email",
                      labelStyle: TextStyle(
                        color: Colors.blue,
                        fontSize: 18.0,
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 20.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(32.0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.lightBlueAccent, width: 2.0),
                        borderRadius: BorderRadius.all(Radius.circular(32.0)),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 16.0, horizontal: 50.0),
                  child: Material(
                    color: Colors.blue,
                    borderRadius: const BorderRadius.all(Radius.circular(30.0)),
                    elevation: 5.0,
                    child: MaterialButton(
                      onPressed: () async {
                        print("mobile.length " + mobile.length.toString());
                        if (name != "" && email != "") {
                          setState(() {
                            showSpinner = true;
                          });

                          var url = Uri.parse(Apis.userExists(mobile));
                          var response = await http.get(url);
                          print(url.toString() + "-" + response.body);
                          if (response.body == "false") {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => OTPVerify(
                                        2,
                                        mobile,
                                        countryCode,
                                        countryCodeISO,
                                        "",
                                        name,
                                        email)));
                          } else {
                            final snackBar = SnackBar(
                              content: const Text("User already registered"),
                              action: SnackBarAction(
                                label: 'User Exists',
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
                          print("mobile.length is " + mobile.length.toString());
                          if (name == "" || email == "" || mobile == "") {
                            final snackBar = SnackBar(
                              content: const Text("All fields are mandatory"),
                              action: SnackBarAction(
                                label: 'Missing fields',
                                onPressed: () {},
                              ),
                            );
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                          }
                        }
                      },
                      minWidth: 200.0,
                      height: 42.0,
                      child: const Text(
                        'Register',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 5.0, horizontal: 100.0),
                  child: InkWell(
                    child: const Text(
                      'Back to login',
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LoginScreen()));
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  getMaxLength() {
    if (countryCode == "") {
      return 10;
    } else {
      for (Country country in countries) {
        if (country.dialCode == countryCode) {
          int length = (country.dialCode).length + country.maxLength;
          print("max kength is " + length.toString());
          return length;
        }
      }
    }
  }

  checkSavedCountryCode() {
    if (ApplicationData.countryCodeISO == "") {
      ApplicationData.countryCodeISO = "CH";
      countryCode = "+41";
      return "CH";
    } else {
      return ApplicationData.countryCodeISO;
    }
  }
}
