import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

//The colors to be used in the app and the required padding space.
//"The main color of the app."
const kColor0 = Color.fromARGB(255, 177, 126, 178);
const kColor1 = Color.fromARGB(255, 222, 164, 162);
const kColor2 = Color.fromARGB(255, 225, 169, 160);
const kColor3 = Color.fromARGB(255, 234, 188, 135);

//"The secondary color of the app."
const kColor4 = Color.fromARGB(255, 244, 231, 228);
const kColor5 = Color.fromARGB(255, 233, 203, 202);
const kColor6 = Color.fromARGB(255, 234, 209, 218);

const kColorA = Color.fromARGB(255, 162, 115, 150);

const kColorD = Color.fromARGB(255, 249, 240, 241);

const kDefaultPadding = 20.0;
//Main color for admin page.
const AdminColor = kColor1;

//admin/Vendor  color
const kColorBack = Color.fromARGB(255, 236, 232, 232);

const kColorPress = Color.fromARGB(255, 231, 195, 189);
const kColorIcon = Color.fromARGB(255, 222, 164, 162);

const AdminButton = Color.fromARGB(255, 68, 67, 67);
const AdminMenu = Color.fromARGB(255, 243, 197, 191);
const List<Color> gradientColors = [kColor0, kColor1, kColor2, kColor3];
const Color iconColor = Color.fromARGB(255, 149, 164, 173);
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
