import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EVLandingPage extends StatefulWidget {
  const EVLandingPage({super.key});

  @override
  State<EVLandingPage> createState() => _EVLandingPageState();
}

class _EVLandingPageState extends State<EVLandingPage> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          SizedBox(
            height: 30,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipOval(
                child: Image.asset(
                  'images/logo.png',
                  height: 100,
                  width: size.width * 0.4,// Ensures proper scaling
                ),
              ),
            ],
          ),
          SizedBox(
            height: 100,
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 20,
                    ),
                    Text(
                      "Join the EVolution!",
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
                          "Tell us about your EV and help us make the electric driving experience even better. 🤝",
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
                SizedBox(
                  height: 40,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context, true);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset("images/EVButton.png",
                          height: 100,
                          width: size.width * 0.8,
                      )
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      )
    );
  }
}
