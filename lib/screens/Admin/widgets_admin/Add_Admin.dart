import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; //firebase
import 'package:firebase_core/firebase_core.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:testtapp/widgets/button_design.dart';
import 'package:testtapp/widgets/textfield_design.dart';

final _firestore = FirebaseFirestore.instance;

class AddAdmin extends StatefulWidget {
  static const String screenRoute = 'Add_Admin';
  const AddAdmin({Key? key}) : super(key: key);

  @override
  _AddAdminState createState() => _AddAdminState();
}

class _AddAdminState extends State<AddAdmin> {
  final ControllerEmail = TextEditingController();
  final ControllerPassword = TextEditingController();
  final _auth = FirebaseAuth.instance;
  late String email;
  late String password;
  bool showSpinner = false;

  @override
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(80.0),
      child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: Color.fromARGB(221, 255, 255, 255)),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            TextFieldDesign('إدخال البريد الإلكتروني', Icons.account_circle,
                ControllerEmail, (value) {
              email = value;
            }, false),
            TextFieldDesign(
                'إدخال كلمة المرور', Icons.password, ControllerPassword,
                (value) {
              password = value;
            }, true),
            SizedBox(height: 8),
            Container(
              width: 300,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: FloatingActionButton(
                  backgroundColor: Color.fromARGB(135, 230, 72, 203),
                  child: Text('إنشاء حساب مسؤول جديد',
                      style: TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                          color: Colors.white)),
                  onPressed: () async {
                    setState(() {
                      showSpinner = true;
                    });

                    try {
                      final newUser =
                          await _auth.createUserWithEmailAndPassword(
                              email: email, password: password);

                      _firestore.collection('adminUser').add({
                        'Email': email,
                      });
                      print('تم اضافة الادمن');
                      setState(() {
                        showSpinner = false;
                        ControllerEmail.clear();
                        ControllerPassword.clear();
                        QuickAlert.show(
                            context: context,
                            customAsset:
                                'assets/images/Completionanimation.gif',
                            width: 300,
                            title: 'تم إضافة $email',
                            type: QuickAlertType.success,
                            confirmBtnText: 'إغلاق');
                      });
                    } catch (e) {
                      print(e);
                    }
                  },
                ),
              ),
            ),
          ])),
    );
  }

  Container TextFieldDesign(
      String Text,
      IconData icon,
      TextEditingController ControllerTextField,
      Function(String) onChanged,
      bool obscureTextField) {
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
