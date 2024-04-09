import 'package:flutter/material.dart';

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

const kDefaultPadding = 20.0;

TextStyle StyleTextAdmin(double SizeText, Color colorText) {
  return TextStyle(
      fontFamily: 'Amiri',
      fontSize: SizeText,
      fontStyle: FontStyle.italic,
      color: colorText);
}
