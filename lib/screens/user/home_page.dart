import 'dart:async';
import 'package:flutter/material.dart';
import 'package:testtapp/constants.dart';
import 'package:testtapp/screens/user/free_shopping_page.dart';

class HomePage extends StatefulWidget {
  static const String screenRoute = 'home_page';

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String currentText = 'Events'; // Initial text

  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration(seconds: 3), (timer) {
      setState(() {
        switch (currentText) {
          case 'Events':
            currentText = 'Eventat';
            break;
          case 'Eventat':
            currentText = 'Evnt';
            break;
          case 'Evnt':
            currentText = 'Events';
            break;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(16.0),
            child: Text(
              currentText, // Display the current text
              style: TextStyle(
                fontSize: 50.0,
                fontWeight: FontWeight.bold,
                color: kColor2,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: MyButton(
                      onTap: () {
                        Navigator.pushNamed(context, 'Event_screen');
                      },
                      label: 'Choose your event',
                      color: kColor0,
                      borderColor: kColor0, // Use the same color as the text
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Expanded(
                    child: MyButton(
                      onTap: () {
                        Navigator.pushNamed(context, FreeShopping.screenRoute);
                      },
                      label: 'Free shopping',
                      color: kColor1,
                      borderColor: kColor1, // Use the same color as the text
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MyButton extends StatefulWidget {
  final VoidCallback onTap;
  final String label;
  final Color color;
  final Color borderColor; // Add border color property

  const MyButton({
    required this.onTap,
    required this.label,
    required this.color,
    required this.borderColor, // Initialize the border color
  });

  @override
  _MyButtonState createState() => _MyButtonState();
}

class _MyButtonState extends State<MyButton> {
  bool isTapped = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      onTapCancel: () {
        setState(() {
          isTapped = false;
        });
      },
      onTapDown: (_) {
        setState(() {
          isTapped = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          isTapped = false;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: isTapped ? widget.color : Colors.white,
          border: Border.all(
            color: widget.borderColor, // Use the border color property
            width: 2.0, // Adjust the border width as needed
          ),
          borderRadius: BorderRadius.circular(8.0), // Add border radius
        ),
        child: Center(
          child: Text(
            widget.label,
            style: TextStyle(
              color: isTapped ? Colors.white : widget.color,
            ),
          ),
        ),
      ),
    );
  }
}
