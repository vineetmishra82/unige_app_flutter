import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:unige_app/screens/ApplicationData.dart';
import 'package:unige_app/screens/LoginScreen.dart';
import 'package:unige_app/screens/OTPVerify.dart';

import '../Other_data/Apis.dart';
import '../Other_data/Countries.dart';
import '../Other_data/Country.dart';
import '../Other_data/IntlPhoneField.dart';

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

  TextEditingController phoneController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 54.0),
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(
                  height: 68.0,
                ),
                ClipOval(
                  child: Image.asset(
                    'images/logo.png',
                    height: 35,
                    width: size.width * 0.4,// Ensures proper scaling
                  ),
                ),
                SizedBox(
                height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 20,
                    ),
                    Text(
                      "Sign Up",
                      style: GoogleFonts.poppins(
                        fontSize: size.width * 0.12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2196F3),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    SizedBox(
                      height: 30,
                      width: 25,
                    ),
                    Text(
                      'Already registered?',
                      style: GoogleFonts.poppins(
                        fontSize: size.width * 0.03,
                        color: Color(0xFF2196F3),
                      ),
                    ),
                    InkWell(
                      child: Text(
                        ' Sign in',
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
                            MaterialPageRoute(
                                builder: (context) => LoginScreen())
                        );
                      },
                    ),
                   ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 35,
                    ),
                    Image.asset(
                      'images/SignUpImage.png',
                      height: size.height*.18,// Ensures proper scaling
                    ),
                  ],
                ),

                SizedBox(height: 20), // Space before phone field

                const SizedBox(
                  height: 20.0,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 📞 Phone Number Field
                    IntlPhoneField(
                      controller: phoneController,
                      dropdownIconPosition: IconPosition.trailing,
                      initialCountryCode: checkSavedCountryCode(),
                      style: GoogleFonts.poppins(
                        color: Colors.black54,
                        fontSize: MediaQuery.textScalerOf(context).scale(16),
                      ),
                      dropdownTextStyle: const TextStyle(color: Colors.green),
                      textAlign: TextAlign.left,
                      decoration: InputDecoration(
                        hintText: "Phone Number", // ✅ Removed label, added hint
                        hintStyle: GoogleFonts.poppins(
                          fontSize: size.width * 0.04,
                          color: Color(0xFF003060),
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 16.0),

                        // ✅ Rectangular Box (No rounded corners)
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.zero,
                          borderSide:
                          BorderSide(color: Colors.lightBlueAccent, width: 2.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.zero,
                          borderSide:
                          BorderSide(color: Colors.lightBlueAccent, width: 2.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.zero,
                          borderSide: BorderSide(color: Colors.blue, width: 2.0),
                        ),
                      ),
                      onCountryChanged: (country) {
                        setState(() {
                          countryCode = country.dialCode;
                          countryCodeISO = country.code;
                        });
                      },
                      onChanged: (phone) {
                        setState(() {
                          mobile = countryCode + phone.number;
                        });
                      },
                    ),

                    SizedBox(height: 10), // Space between fields

                    // 👤 Name Field
                    TextField(
                      controller: nameController,
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: MediaQuery.textScalerOf(context).scale(18),
                      ),
                      maxLength: 100,
                      keyboardType: TextInputType.name,
                      decoration: InputDecoration(
                        hintText: "Your Name", // ✅ Removed label, added hint
                        hintStyle: GoogleFonts.poppins(
                          fontSize: size.width * 0.04,
                          color: Color(0xFF003060),
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 16.0),

                        // ✅ Rectangular Box (No rounded corners)
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.zero,
                          borderSide:
                          BorderSide(color: Colors.lightBlueAccent, width: 2.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.zero,
                          borderSide:
                          BorderSide(color: Colors.lightBlueAccent, width: 2.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.zero,
                          borderSide: BorderSide(color: Colors.blue, width: 2.0),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          name = value;
                        });
                      },
                    ),

                    SizedBox(height: 10), // Space between fields

                    // ✉️ Email Field
                    TextField(
                      controller: emailController,
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: MediaQuery.textScalerOf(context).scale(16),
                      ),
                      maxLength: 100,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: "Email", // ✅ Removed label, added hint
                        hintStyle: GoogleFonts.poppins(
                          fontSize: size.width * 0.04,
                          color: Color(0xFF003060),
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 16.0),

                        // ✅ Rectangular Box (No rounded corners)
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.zero,
                          borderSide:
                          BorderSide(color: Colors.lightBlueAccent, width: 2.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.zero,
                          borderSide:
                          BorderSide(color: Colors.lightBlueAccent, width: 2.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.zero,
                          borderSide: BorderSide(color: Colors.blue, width: 2.0),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          email = value;
                        });
                      },
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 50.0),
                  child: GestureDetector(
                    onTap: () async {
                      FocusScope.of(context).unfocus();
                      if (name.isNotEmpty && email.isNotEmpty && mobile.isNotEmpty) {
                        setState(() {
                          showSpinner = true;
                        });
                        mobile = mobile.replaceAll("+", "");
                        var url = Uri.parse(Apis.userExists(mobile));
                        var response = await http.get(url);
                        print("$url-${response.body}");

                        if (response.body == "false") {
                          print("mobile $mobile");
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
                                email,
                              ),
                            ),
                          );
                        } else {
                          final snackBar = SnackBar(
                            content: const Text("User already registered"),
                            action: SnackBarAction(
                              label: 'User Exists',
                              onPressed: () {},
                            ),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          setState(() {
                            showSpinner = false;
                          });
                        }

                        setState(() {
                          showSpinner = false;
                        });
                      } else {
                        print("mobile.length is " + mobile.length.toString());
                        if (name.isEmpty || email.isEmpty || mobile.isEmpty) {
                          final snackBar = SnackBar(
                            content: const Text("All fields are mandatory"),
                            action: SnackBarAction(
                              label: 'Missing fields',
                              onPressed: () {},
                            ),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        }
                      }
                    },
                    child: Image.asset(
                      'images/LoginButton.png', // ✅ Clickable image as a button
                      width: 200, // ✅ Adjust width as needed
                      height: 45, // ✅ Adjust height as needed
                      fit: BoxFit.contain, // ✅ Ensures it scales correctly
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
