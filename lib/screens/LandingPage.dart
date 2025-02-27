import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unige_app/main.dart';
import 'package:unige_app/screens/HomePage.dart';
import 'package:url_launcher/url_launcher.dart';

class LandingPageDetail extends StatefulWidget {
  static String id = "LandingPage";


  @override
  State<LandingPageDetail> createState() => _LandingPageDetailState();
}

class _LandingPageDetailState extends State<LandingPageDetail> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: Colors.white,
  body: SingleChildScrollView(
    physics: BouncingScrollPhysics(),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
    const SizedBox(
    height: 60.0,
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
        Container(
          width: double.infinity, // Full width (end-to-end)
          height: 15, // Line weight (thickness)
          color: Color(0xFF2296F3), // Line color
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
              "About us",
              style: GoogleFonts.poppins(
                fontSize: size.width * 0.08,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2196F3),
              ),
            ),
          ],
        ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0), // Adjust padding
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text:
                    "We're a team dedicated to improving the product experience. "
                        "Through this app, we gather valuable insights to help shape the "
                        "future of products and ensure they meet your needs.\n ",
                    style: GoogleFonts.poppins(
                      color: Color(0xFF003060), // Text color
                      fontSize: 16.0,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  WidgetSpan(
                    child: GestureDetector(
                      onTap: ()  {
                        _launchUrl();
                      },
                      child: Text(
                        "Learn more...",
                        style: GoogleFonts.poppins(
                          color: Color(0xFF2196F3), // Link color
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline, // Optional: Underline link
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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
              "Why your opinion matters",
              style: GoogleFonts.poppins(
                fontSize: size.width * 0.05,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2196F3),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22.0), // Adjust padding
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text:
                  "Your feedback is crucial. It directly influences product development, "
                      "helping manufacturers and service providers understand and "
                      "address your concerns for a better consumer experience. ",
                  style: GoogleFonts.poppins(
                    color: Color(0xFF003060), // Text color
                    fontSize: 16.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),

              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 50.0),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomePage(ApplicationData.mobile)),
              );
            },
            child: Image.asset(
              'images/LoginButton.png', // ✅ Clickable image as a button
              width: 200, // ✅ Adjust width as needed
              height: 45, // ✅ Adjust height as needed
              fit: BoxFit.contain, // ✅ Ensures it scales correctly
            ),
          ),
        ),

      ]
    ),
  ),
    );
  }

  Future<void> _launchUrl() async{
    final url = Uri.parse("https://qualtrack-privacypolicy.web.app/");
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    } else {
      print("Could not launch URL");
    }
  }
}
