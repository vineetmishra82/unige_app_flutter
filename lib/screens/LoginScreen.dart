import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
// import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:unige_app/Other_data/Countries.dart';

import '../Other_data/Apis.dart';
import '../Other_data/Country.dart';
import '../Other_data/IntlPhoneField.dart';
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
  TextEditingController phoneController = TextEditingController();
  int maxPhoneLength = 0;
  bool showSpinner = false;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: ModalProgressHUD(
          inAsyncCall: showSpinner,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 54.0),
                child: SingleChildScrollView(
                 child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 30,
                      ),
                      ClipOval(
                        child: Image.asset(
                          'images/logo.png',
                          height: 100,
                          width: size.width * 0.4,// Ensures proper scaling
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 30,
                          ),
                          Text(
                            "Login",
                            style: GoogleFonts.poppins(
                              fontSize: size.width * 0.1,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2196F3),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 35,
                          ),
                          Image.asset(
                            'images/LoginImage.png',
                            height: size.height*.23,// Ensures proper scaling
                          ),
                        ],
                      ),
        
                      SizedBox(height: 20), // Space before phone field
        
                      IntlPhoneField(
                        controller: phoneController,
                        dropdownIconPosition: IconPosition.trailing,
                        initialCountryCode: checkSavedCountryCode(),
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: MediaQuery.textScalerOf(context).scale(14),
                        ),
                        dropdownTextStyle: TextStyle(color: Colors.green),
                        disableLengthCheck: true,
                        textAlign: TextAlign.left,
                        decoration: InputDecoration(
                          hintText: "Phone Number", // ✅ Replaces labelText
                          hintStyle:  GoogleFonts.poppins(
                        fontSize: size.width * 0.04,
                          color: Color(0xFF003060)),
                          floatingLabelBehavior: FloatingLabelBehavior.never, // ✅ Ensures label does not float
                          contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        
                          // ✅ RECTANGULAR BOX (No Rounded Corners)
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.zero, // ✅ Removes rounded corners
                            borderSide: BorderSide(color: Colors.lightBlueAccent, width: 2.0),
                          ),
        
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.zero, // ✅ Ensures rectangular shape
                            borderSide: BorderSide(color: Colors.black, width: 1.0),
                          ),
        
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.zero, // ✅ Ensures rectangular shape on focus
                            borderSide: BorderSide(color: Colors.blue, width: 2.0),
                          ),
                        ),
                        onCountryChanged: (country) {
                          setState(() {
                            LoginScreen.countryCode = country.dialCode;
                            LoginScreen.countryCodeISO = country.code;
                          });
                        },
                        onChanged: (phone) {
                          setState(() {
                            LoginScreen.mobile = LoginScreen.countryCode + phone.number;
                          });
                          print(LoginScreen.mobile);
                        },
                      ),
        
        
                      SizedBox(height: 25), // Space before button
        
                      GestureDetector(
                        onTap: () async {
                          FocusScope.of(context).unfocus();
                          if (LoginScreen.mobile.isNotEmpty) {
                            setState(() {
                              showSpinner = true;
                            });
                            print("trying to log in ${LoginScreen.mobile}");
                            var url = Uri.parse(Apis.userExists(LoginScreen.mobile));
                            var response = await http.get(url);
        
                            if (response.body == "true") {
                              setState(() {
                                showSpinner = false;
                              });
        
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
                                    "",
                                  ),
                                ),
                              );
                            } else {
                              showSnackBar("User not registered");
                              setState(() {
                                showSpinner = false;
                              });
                              resetLoginVariables();
                            }
                          } else {
                            showSnackBar("Need a mobile number to login");
                            setState(() {
                              showSpinner = false;
                            });
                          }
                        },
                        child: Image.asset(
                          'images/LoginButton.png', // ✅ Clickable image
                          width: 200, // ✅ Adjust width as needed
                          height: 45, // ✅ Adjust height as needed
                          fit: BoxFit.contain, // Ensures it scales correctly
                        ),
                      ),
        
                      SizedBox(height: 10), // Space before "New User?" text
        
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Don\'t have account?',
                            style: GoogleFonts.poppins(
                              fontSize: size.width * 0.03,
                              color: Color(0xFF2196F3),
                            ),
                          ),
                          InkWell(
                            child: Text(
                              ' Sign up',
                              style: GoogleFonts.poppins(
                                fontSize: size.width * 0.03,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                decoration: TextDecoration.underline
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => RegisterUser()),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showSnackBar(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      action: SnackBarAction(
        label: 'OK',
        onPressed: () {},
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
    print("LoginScreen.countryCode is " + LoginScreen.countryCode);
    if (LoginScreen.countryCode == "") {
      LoginScreen.countryCode = "41";
      LoginScreen.countryCodeISO = "CH";
      return "CH";
    } else {
      return LoginScreen.countryCodeISO;
    }
  }

  void resetLoginVariables() {
    LoginScreen.mobile = "";
    LoginScreen.countryCode = "";
    LoginScreen.countryCodeISO = ApplicationData.countryCodeISO;
    phoneController.clear();
  }
}
