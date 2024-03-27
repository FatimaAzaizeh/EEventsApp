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

  @override
  void initState() {
    super.initState();
    startTextAnimation();
  }

  void startTextAnimation() {
    const text = 'Eevents';
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
          decoration: const BoxDecoration(
            color: Colors.white,
            image: DecorationImage(
              image: AssetImage(
                'assets/images/backAnim3.png',
              ),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: Text(
              textToShow,
              style: TextStyle(
                  fontSize: 90,
                  fontFamily: 'DancingScript',
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  shadows: [
                    /* Shadow(
                      color: Colors.white,
                      offset: Offset(3, 3),
                      blurRadius: 2,
                    ),*/
                  ]),
            ),
          ),
        ));
  }
}
