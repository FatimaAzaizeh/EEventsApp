import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

//The colors to be used in the app and the required padding space.
//"The main color of the app."
//Purple
const ColorPurple_100 = Color.fromARGB(255, 189, 140, 177);
Color ColorPurple_70 = Color.fromARGB(255, 189, 140, 177).withOpacity(0.7);
Color ColorPurple_50 = Color.fromARGB(255, 189, 140, 177).withOpacity(0.5);
Color ColorPurple_20 = Color.fromARGB(255, 189, 140, 177).withOpacity(0.2);

//Pink
const ColorPink_100 = Color.fromARGB(255, 214, 170, 173);
Color ColorPink_70 = Color.fromARGB(255, 214, 170, 173).withOpacity(0.7);
Color ColorPink_50 = Color.fromARGB(255, 214, 170, 173).withOpacity(0.5);
Color ColorPink_20 = Color.fromARGB(255, 214, 170, 173).withOpacity(0.2);

//Cream
const ColorCream_100 = Color.fromARGB(255, 225, 189, 158);
Color ColorCream_70 = Color.fromARGB(255, 225, 189, 158).withOpacity(0.7);
Color ColorCream_50 = Color.fromARGB(255, 225, 189, 158).withOpacity(0.5);
Color ColorCream_20 = Color.fromARGB(255, 225, 189, 158).withOpacity(0.2);
//"The secondary color of the app."

const kDefaultPadding = 20.0;
//Main color for admin page.

//admin/Vendor  color
const kColorBack = Color.fromARGB(255, 245, 246, 248);
const AdminMenu = Color(0xFFFFFF);
const Color iconColor = Color.fromARGB(255, 194, 207, 224);

const kColorPress = Color.fromARGB(255, 231, 195, 189);
const kColorIcon = Color.fromARGB(255, 222, 164, 162);

const AdminButton = Color.fromARGB(255, 68, 67, 67);

const Color activeColor = Color(0xFF09126C);
const Color textColor1 = Color.fromARGB(255, 104, 118, 125);
const Color textColor2 = Color.fromARGB(255, 106, 124, 125);
const Color googleColor = Color(0xFFDE4B39);
TextStyle StyleTextAdmin(double SizeText, Color colorText) {
  return TextStyle(
      fontFamily: 'Marhey',
      fontSize: SizeText,
      fontWeight: FontWeight.w600,
      color: colorText);
}
