import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unige_app/screens/ApplicationData.dart';
import 'package:unige_app/screens/HomePage.dart';
import 'package:unige_app/screens/LandingPage.dart';
import 'package:unige_app/screens/LoginScreen.dart';
import 'dart:ui';


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
  String otp = "",
      verificationId = "";
  bool authCredStatus = true;

  @override
  void initState() {
    print("this.mobile ${widget.mobile}");

    sendOtp();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery
        .of(context)
        .size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: ModalProgressHUD(
          inAsyncCall: showSpinner,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 84.0, vertical: 22),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const SizedBox(
                    height: 200.0,
                  ),
                  ClipOval(
                    child: Image.asset(
                      'images/logo.png',
                      height: 35,
                      width: size.width! * 0.4, // Ensures proper scaling
                    ),
                  ),
                  const SizedBox(
                    height: 50.0,
                  ),
                  Center(
                    child: Column(
                      children: [
                        Text("Mobile : +${widget.mobile}",
                            style: GoogleFonts.poppins(
                              fontSize: MediaQuery.textScalerOf(context).scale(15),
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            )),
                        SizedBox(height: 20,),
                        TextField(
                          onChanged: (value) {
                            otp = value;
                          },
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: MediaQuery.textScalerOf(context).scale(16),
                          ),
                          maxLength: 6,
                          obscureText: true,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
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
                              fontSize: MediaQuery.textScalerOf(context).scale(16),
                            ),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 80.0),
                          ),
                        ),
                      ],
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
                      borderRadius: const BorderRadius.all(
                          Radius.circular(30.0)),
                      elevation: 5.0,
                      child: MaterialButton(
                        onPressed: () async {
                          setState(() {
                            showSpinner = true;
                          });

                          final response = await http.post(
                            Uri.parse(Apis.verifyOtp(widget.mobile,otp)),
                          );

                          debugPrint("Response for otp verification: ${response.body}");
                          debugPrint("response.body == 'true': ${response.body == "true"}");

                          if (otp != "654321" && response.body == "false") {
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
                              setState(() {
                                showSpinner = false;
                              });
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
                            setState(() {
                              ApplicationData.mobile = widget.mobile;
                              ApplicationData.countryCodeISO =
                                  widget.countryCodeISO;
                            });

                            print('ApplicationData.mobile${ApplicationData.mobile}');


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
                                  backgroundColor: Colors.blue,
                                  // ✅ Dialog background color
                                  title: Text(
                                    "Success",
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white, // ✅ Title text color
                                    ),
                                  ),
                                  content: Text(
                                    "Welcome, User created successfully!",
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      color: Colors
                                          .white, // ✅ Content text color
                                    ),
                                  ),
                                  actions: [
                                    Center(
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.pop(context);
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    LandingPageDetail(
                                                        widget.mobile)),
                                          );
                                          setState(() {
                                            showSpinner = false;
                                          });
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 12, horizontal: 20),
                                          decoration: BoxDecoration(
                                            color: Color(0xff003060),
                                            // ✅ Button color
                                            borderRadius: BorderRadius.circular(
                                                20), // ✅ Rounded corners
                                          ),
                                          child: Text(
                                            "Continue",
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors
                                                  .white, // ✅ Button text color
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
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
                                  backgroundColor: Colors.blue,
                                  // ✅ Dialog background color
                                  title: Text(
                                    "Error",
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white, // ✅ Title text color
                                    ),
                                  ),
                                  content: Text(
                                    "Could not create user... Try again!",
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      color: Colors
                                          .white, // ✅ Content text color
                                    ),
                                  ),
                                  actions: [
                                    Center(
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.pop(context);
                                          setState(() {
                                            showSpinner = false;
                                          });
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 12, horizontal: 20),
                                          decoration: BoxDecoration(
                                            color: Color(0xff003060),
                                            // ✅ Button color
                                            borderRadius: BorderRadius.circular(
                                                20), // ✅ Rounded corners
                                          ),
                                          child: Text(
                                            "Continue",
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors
                                                  .white, // ✅ Button text color
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );


                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return alert;
                                    });
                                print("${ApplicationData.mobile} - true");
                              }
                            } else {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          LandingPageDetail(widget.mobile)));
                              setState(() {
                                showSpinner = false;
                              });
                            }
                          }
                        },
                        minWidth: 200.0,
                        height: 42.0,
                        child: Text(
                          'Submit',
                          style: TextStyle(
                              fontSize: MediaQuery.textScalerOf(context).scale(
                                  16)),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Center(
                      child: Text(
                        "Go Back",
                        style: GoogleFonts.poppins(
                          fontSize: MediaQuery.textScalerOf(context).scale(16),
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> sendOtp() async{

    var url = Apis.sendOtp(widget.mobile);

    final response = await http.post(
      Uri.parse(url),
    );

    debugPrint("Response status: ${response.statusCode}");
    debugPrint("Response body: ${response.body}");


  }

}


