import 'package:flutter/material.dart';

class DesktopWarning extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // optional
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Replace with your logo asset if you have one
            Image.asset(
              'images/logo.png', // <-- ensure this asset exists!
              width: 120,
            ),
            SizedBox(height: 24),
            Text(
              'This app works only on mobile browsers.',
              style: TextStyle(
                fontSize: 20,
                color: Colors.blue,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}