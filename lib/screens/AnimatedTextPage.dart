import 'dart:async';
import 'package:flutter/material.dart';
import 'package:testtapp/screens/Sign_in.dart';

class AnimatedTextPage extends StatefulWidget {
  static const String screenRoute = 'AnimatedTextPage';
  @override
  _AnimatedTextPageState createState() => _AnimatedTextPageState();
}

class _AnimatedTextPageState extends State<AnimatedTextPage> {
  String textToShow = '';

  // Reusable DecorationImage instance for the background
  final DecorationImage backgroundDecorationImage = const DecorationImage(
    image: AssetImage('assets/images/123.png'),
    fit: BoxFit.cover,
  );

  // Reusable DecorationImage instance for the logo
  final DecorationImage logoDecorationImage = const DecorationImage(
    image: AssetImage('assets/images/logo.png'),
  );

  @override
  void initState() {
    super.initState();
    startTextAnimation();
  }

  // Function to animate the text
  void startTextAnimation() {
    const text = 'Eeventş';
    const duration = Duration(milliseconds: 400); // Adjust duration as needed
    int index = 0;

    Timer.periodic(duration, (Timer timer) {
      setState(() {
        if (index < text.length) {
          textToShow += text[index];
          index++;
        } else {
          timer.cancel();
          Navigator.popAndPushNamed(context, SignIn.screenRoute);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          image: DecorationImage(
            image: AssetImage(
              'assets/images/back1.jpg',
            ),
            fit: BoxFit.cover,
          ),
          //backgroundDecorationImage, // Background image using the reusable DecorationImage
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo using the reusable DecorationImage, with increased size
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                image: logoDecorationImage,
              ),
            ),
            SizedBox(height: 20), // Space between logo and text
            Text(
              textToShow,
              style: TextStyle(
                fontSize: 90,
                fontFamily: 'DancingScript',
                fontWeight: FontWeight.w900,
                color: Colors.white,
                shadows: [],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
