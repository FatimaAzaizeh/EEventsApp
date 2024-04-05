import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; //firebase
import 'package:firebase_core/firebase_core.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:testtapp/screens/Admin/widgets_admin/TexFieldDesign.dart';
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
            TextFieldDesign(
              Text: 'إدخال البريد الإلكتروني',
              icon: Icons.account_circle,
              ControllerTextField: ControllerEmail,
              onChanged: (value) {
                email = value;
              },
              obscureTextField: false,
            ),
            TextFieldDesign(
              Text: 'إدخال كلمة المرور',
              icon: Icons.password,
              ControllerTextField: ControllerPassword,
              onChanged: (value) {
                password = value;
              },
              obscureTextField: true,
            ),
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
}
