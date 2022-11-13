import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unige_app/screens/ApplicationData.dart';
import 'package:unige_app/screens/HomePage.dart';
import 'package:unige_app/screens/LoginScreen.dart';

import '../Other_data/Apis.dart';

class OTPVerify extends StatefulWidget {
  final int id;
  final String mobile;
  final String countryCode;
  final String countryCodeISO;
  final String address;
  final String name;
  final String email;
  int count = 1;

  OTPVerify(this.id, this.mobile, this.countryCode, this.countryCodeISO,
      this.address, this.name, this.email);

  @override
  _OTPVerifyState createState() => _OTPVerifyState();
}

class _OTPVerifyState extends State<OTPVerify> {
  bool showSpinner = false;
  String otp = "", verificationId = "";
  bool authCredStatus = true;

  @override
  void initState() {
    //generateOTPandVerify();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 84.0, vertical: 22),
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
                  height: 100.0,
                ),
                Center(
                  child: TextField(
                    onChanged: (value) {
                      otp = value;
                    },
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 18.0,
                    ),
                    maxLength: 6,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(32.0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.lightBlueAccent, width: 2.0),
                        borderRadius: BorderRadius.all(Radius.circular(32.0)),
                      ),
                      labelText: "Enter OTP",
                      labelStyle: TextStyle(
                        color: Colors.blue,
                        fontSize: 18.0,
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 80.0),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 24.0,
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
                        //    verifyOTP();

                        if (otp != "123456") {
                          print("verify returned false");
                          if (widget.count >= 4) {
                            ApplicationData.mobile = "";
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('No of tries exceeded...Redirecting'),
                              ),
                            );

                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginScreen()));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Invalid OTP..try again'),
                              ),
                            );
                            widget.count++;
                          }
                        } else {
                          SharedPreferences loginCheck =
                              await SharedPreferences.getInstance();
                          loginCheck.setBool("isLoggedIn", true);
                          loginCheck.setString(
                              "LoginMobileInThisSuperliciousApp",
                              widget.mobile);
                          loginCheck.setString(
                              "CountryCodeISO", widget.countryCodeISO);
                          ApplicationData.mobile = widget.mobile;
                          print('ApplicationData.mobile' +
                              ApplicationData.mobile);
                          ApplicationData.countryCodeISO =
                              widget.countryCodeISO;

                          if (widget.id == 2) {
                            setState(() {
                              showSpinner = true;
                            });
                            var url = Uri.parse(Apis.createUser(
                                widget.name, widget.mobile, widget.email));
                            var response = await http.post(url);
                            print(url);
                            if (response.body == "true") {
                              AlertDialog alert = AlertDialog(
                                title: Text("Success"),
                                content: Text(
                                    "Welcome, User created successfully !"),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => HomePage(
                                                    ApplicationData.mobile)));
                                        print(
                                            ApplicationData.mobile + " - true");
                                        setState(() {
                                          showSpinner = false;
                                        });
                                      },
                                      child: Text("Continue"))
                                ],
                              );

                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return alert;
                                  });
                              print(ApplicationData.mobile + " - true");
                            } else {
                              AlertDialog alert = AlertDialog(
                                title: Text("Error"),
                                content:
                                    Text("Could not Create User...Try again !"),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);

                                        setState(() {
                                          showSpinner = false;
                                        });
                                      },
                                      child: Text("Continue"))
                                ],
                              );

                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return alert;
                                  });
                              print(ApplicationData.mobile + " - true");
                            }
                          } else {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        HomePage(ApplicationData.mobile)));
                            print(ApplicationData.mobile + " - true");
                            setState(() {
                              showSpinner = false;
                            });
                          }
                        }
                      },
                      minWidth: 200.0,
                      height: 42.0,
                      child: const Text(
                        'Submit',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> generateOTPandVerify() async {
    String mobileWithCode = ("+" + widget.mobile);

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: (mobileWithCode),
      verificationCompleted: (PhoneAuthCredential credential) async {
        await FirebaseAuth.instance.signInWithCredential(credential);
        print('Successful verification');
      },
      verificationFailed: (FirebaseAuthException e) {
        print('UNSuccessful verification - ' + e.message.toString());
      },
      codeSent: (String verificationId, int? resendToken) async {
        this.verificationId = verificationId;
        print('code sent');
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  verifyOTP() async {
    setState(() {
      showSpinner = true;
    });
    Future<bool> result;
    PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(
        verificationId: verificationId, smsCode: otp);
    print('OTP is ' + phoneAuthCredential.smsCode.toString());
    print("phoneauthcred is " + phoneAuthCredential.toString());

    try {
      final authCredential =
          await FirebaseAuth.instance.signInWithCredential(phoneAuthCredential);

      if (authCredential.user != null) {
        print('inside authcred');
        SharedPreferences loginCheck = await SharedPreferences.getInstance();

        loginCheck.setBool("isLoggedIn", true);
        loginCheck.setString("LoginMobileInThisSuperliciousApp", widget.mobile);
        loginCheck.setString("CountryCodeISO", widget.countryCodeISO);
        ApplicationData.mobile = widget.mobile;
        print('ApplicationData.mobile' + ApplicationData.mobile);
        ApplicationData.countryCodeISO = widget.countryCodeISO;

        if (widget.id == 2) {
          var url = Uri.parse(
              Apis.createUser(widget.name, widget.mobile, widget.email));
          var response = await http.post(url);
          print(url);
          if (response.body == "true") {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('User Created...Welcome !'),
              ),
            );
          } else {
            final snackBar = SnackBar(
              content: const Text("Could not register user"),
              action: SnackBarAction(
                label: 'Server Error',
                onPressed: () {},
              ),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
            setState(() {
              showSpinner = false;
            });
          }
        }

        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => HomePage(ApplicationData.mobile)));
        print(ApplicationData.mobile + " - true");
        print("verify returned truew");
      } else {
        authCredStatus = false;
        setState(() {
          showSpinner = false;
        });
      }
    } on FirebaseAuthException catch (e) {
      String error = "catch " + e.message.toString();
      print(error);
      authCredStatus = false;
      setState(() {
        showSpinner = false;
      });
    }
  }
}
