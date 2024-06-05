import 'package:flutter/material.dart';
import 'package:testtapp/constants.dart';

class TextFieldDesign extends StatelessWidget {
  final String Text;
  final IconData icon;
  final TextEditingController ControllerTextField;
  final Function(String) onChanged;
  final bool obscureTextField;
  bool enabled;
  TextFieldDesign(
      {super.key,
      required this.Text,
      required this.icon,
      required this.ControllerTextField,
      required this.onChanged,
      required this.obscureTextField,
      required bool this.enabled});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 700,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          decoration: InputDecoration(
            // Display hint text when the field is empty.
            hintText: Text,
            hintTextDirection:
                TextDirection.rtl, // Align the hint text to the right,
            hintStyle: TextStyle(
                fontFamily: 'Amiri', fontSize: 18, fontStyle: FontStyle.italic),
            // Define padding for the content inside the text field.
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            filled: true,
            fillColor: Color.fromARGB(26, 60, 60, 60),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(30),
            ),
            icon: Icon(
              icon,
              color: AdminButton,
              size: 30,
            ),
          ),
          controller: ControllerTextField,
          onChanged: onChanged,
          obscureText: obscureTextField,
          enabled: this.enabled,
        ),
      ),
    );
  }
}
