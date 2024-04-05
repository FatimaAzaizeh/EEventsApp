import 'package:flutter/material.dart';

class TextFieldDesign extends StatelessWidget {
  final String Text;
  final IconData icon;
  final TextEditingController ControllerTextField;
  final Function(String) onChanged;
  final bool obscureTextField;

  TextFieldDesign(
      {super.key,
      required this.Text,
      required this.icon,
      required this.ControllerTextField,
      required this.onChanged,
      required this.obscureTextField});

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
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(24),
            ),
            icon: Icon(
              icon,
              color: Color.fromARGB(255, 10, 1, 4),
            ),
          ),
          controller: ControllerTextField,
          onChanged: onChanged,
          obscureText: obscureTextField,
        ),
      ),
    );
  }
}
