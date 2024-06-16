import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:testtapp/Alert/error.dart';
import 'package:testtapp/constants.dart';
import 'package:testtapp/models/User.dart';
import 'package:testtapp/screens/Admin/Admin_screen.dart';
import 'package:testtapp/screens/Vendor/VendorScreen.dart';

import 'package:testtapp/widgets/textfield_design.dart';

class SignIn extends StatefulWidget {
  static const String screenRoute = 'SignAV';
  const SignIn({Key? key}) : super(key: key);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final ControllerEmail = TextEditingController();
  final ControllerPassword = TextEditingController();
  final _auth = FirebaseAuth.instance;
  late bool admin = false;
  late bool vendor = false;
  late String email;
  late String password;
  bool showSpinner = false;
  bool isAdminSelected = false;
  bool isVendorSelected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/signin.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Foreground content
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: 1000,
                height: 700,
                decoration: const BoxDecoration(
                  color: Color.fromARGB(147, 246, 242, 239),
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
                child: ModalProgressHUD(
                  inAsyncCall: showSpinner,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 100),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 250,
                          width: 250,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadiusDirectional.circular(30),
                            image: DecorationImage(
                              image: AssetImage('assets/images/logo2.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(height: 15),
                        Text(
                          'البريد الالكتروني',
                          style: StyleTextAdmin(18, Colors.black),
                        ),
                        CustomTextField(
                          hintText: 'ادخال البريد الالكتروني',
                          color: activeColor,
                          keyboardType: TextInputType.emailAddress,
                          onChanged: (value) {
                            email = value;
                          },
                          obscureText: false,
                          TextController: ControllerEmail,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'كلمة المرور',
                          style: StyleTextAdmin(18, Colors.black),
                        ),
                        CustomTextField(
                          hintText: 'أدخال كلمة المرور',
                          color: activeColor,
                          keyboardType: TextInputType.visiblePassword,
                          onChanged: (value) {
                            password = value;
                          },
                          obscureText: true,
                          TextController: ControllerPassword,
                        ),
                        SizedBox(height: 15),
                        Row(
                          children: [
                            Radio<bool>(
                              value: true,
                              groupValue: isAdminSelected,
                              activeColor: activeColor,
                              onChanged: (value) {
                                setState(() {
                                  isAdminSelected = true;
                                  isVendorSelected = false;
                                  admin = true;
                                  vendor = false;
                                });
                              },
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                              child: Text('مسؤول',
                                  style: StyleTextAdmin(16, activeColor)),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Radio<bool>(
                              value: true,
                              groupValue: isVendorSelected,
                              activeColor: activeColor,
                              onChanged: (value) {
                                setState(() {
                                  isVendorSelected = true;
                                  isAdminSelected = false;
                                  vendor = true;
                                  admin = false;
                                });
                              },
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                              child: Text('بائع',
                                  style: StyleTextAdmin(16, activeColor)),
                            ),
                          ],
                        ),
                        SizedBox(height: 15),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 300,
                            height: 50,
                            margin: EdgeInsets.only(bottom: 90),
                            decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    spreadRadius: 1,
                                    blurRadius: 1,
                                    offset: Offset(0, 3),
                                  )
                                ],
                                borderRadius: BorderRadius.circular(20),
                                color: Color.fromARGB(125, 216, 147, 145)),
                            child: TextButton(
                              child: Text(
                                'تسجيل الدخول ',
                                style: StyleTextAdmin(
                                    20, Colors.white.withOpacity(0.75)),
                              ),
                              onPressed: () async {
                                setState(() {
                                  showSpinner = true;
                                });
                                try {
                                  final user =
                                      await _auth.signInWithEmailAndPassword(
                                    email: email,
                                    password: password,
                                  );

                                  if (user != null) {
                                    String? uid =
                                        FirebaseAuth.instance.currentUser?.uid;

                                    if (!admin && vendor) {
                                      String userId = uid ?? '';
                                      DocumentReference userTypeRef =
                                          FirebaseFirestore.instance
                                              .collection('user_types')
                                              .doc('3');

                                      bool isValid = await UserDataBase
                                          .isUserTypeReferenceValid(
                                              userId, userTypeRef);
                                      if (isValid) {
                                        Navigator.pushNamed(
                                            context, VendorScreen.screenRoute);
                                      } else {
                                        setState(() {
                                          showSpinner = false;
                                        });
                                        ErrorAlert(context, 'خطأ',
                                            'الحساب الذي تحاول الدخول بة ليس حساب بائع');
                                      }
                                    }

                                    if (admin) {
                                      String userId = uid ?? '';
                                      DocumentReference userTypeRef =
                                          FirebaseFirestore.instance
                                              .collection('user_types')
                                              .doc('1');

                                      bool isValid = await UserDataBase
                                          .isUserTypeReferenceValid(
                                              userId, userTypeRef);

                                      if (isValid) {
                                        Navigator.pushNamed(
                                            context, AdminScreen.screenRoute);
                                      } else {
                                        setState(() {
                                          showSpinner = false;
                                        });
                                        ErrorAlert(context, 'خطأ',
                                            'الحساب الذي تحاول الدخول بة ليس حساب مسؤول');
                                      }
                                    }
                                  }
                                } catch (e) {
                                  setState(() {
                                    showSpinner = false;
                                  });
                                  ErrorAlert(context, 'خطأ', e.toString());
                                }
                              },
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
