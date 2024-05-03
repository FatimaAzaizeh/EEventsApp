import 'dart:html';
import 'dart:io';
import 'dart:js_util';
import 'package:image_picker/image_picker.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:testtapp/screens/Admin/Admin_screen.dart';
import 'package:testtapp/screens/chat_screen.dart';
import 'package:testtapp/screens/user/home_page.dart';

import 'package:testtapp/widgets/button_design.dart';
import 'package:testtapp/widgets/textfield_design.dart';

class SignIn extends StatefulWidget {
  static const String screenRoute = 'SignAV';
  const SignIn({Key? key}) : super(key: key);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final ControllerEmail = TextEditingController();
  final ControllerVEmail = TextEditingController();
  final ControllerVendor = TextEditingController();
  final ControllerPassword = TextEditingController();
  final ControllerVPassword = TextEditingController();
  final _auth = FirebaseAuth.instance;
  late bool admin = false;
  late bool vendor = false;
  late String email;
  late String password;
  bool showSpinner = false;
  bool isDrawerOpen = false;
  bool isAdminSelected = false;
  bool isVendorSelected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromARGB(255, 236, 232, 232),
        body: Row(children: [
          Expanded(
              child: Center(
                  child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                          width: 1000,
                          height: 700,
                          decoration: const BoxDecoration(
                              color: Color.fromARGB(158, 251, 248, 248),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15))),
                          child: ModalProgressHUD(
                              inAsyncCall: showSpinner,
                              child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 100),
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          height: 70,
                                          width: 70,
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image: AssetImage(
                                                  'assets/images/logo.png'),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 0,
                                          left: 0,
                                          right: 0,
                                          child: Container(
                                              height: 180,
                                              child: Center(
                                                  child: Text(
                                                'Eeventş',
                                                style: TextStyle(fontSize: 40),
                                              ))),
                                        ),
                                        SizedBox(height: 10),
                                        Text('البريد الالكتروني'),
                                        CustomTextField(
                                          hintText: 'ادخال البريد الالكتروني',
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          onChanged: (value) {
                                            email = value;
                                          },
                                          obscureText: false,
                                          TextController: ControllerEmail,
                                        ),
                                        SizedBox(height: 10),
                                        Text(' كلمة المرور'),
                                        CustomTextField(
                                          hintText: 'أدخال كلمة المرور',
                                          keyboardType:
                                              TextInputType.visiblePassword,
                                          onChanged: (value) {
                                            password = value;
                                          },
                                          obscureText: true,
                                          TextController: ControllerPassword,
                                        ),
                                        SizedBox(height: 15),
                                        Row(children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 5),
                                            child: Text('مسؤول'),
                                          ),
                                          Radio(
                                            value: true,
                                            groupValue: isAdminSelected,
                                            onChanged: (value) {
                                              setState(() {
                                                isAdminSelected = true;
                                                admin = true;
                                              });
                                            },
                                          ),
                                          SizedBox(
                                            width: 15,
                                          ),
                                          Row(children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 5),
                                              child: Text('منظم'),
                                            ),
                                            Radio(
                                              value: true,
                                              groupValue: isVendorSelected,
                                              onChanged: (value) {
                                                setState(() {
                                                  isVendorSelected =
                                                      value as bool;
                                                  isAdminSelected = false;
                                                });
                                              },
                                            ),
                                          ]),
                                        ]),
                                        SizedBox(height: 15),
                                        Center(
                                            child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 150),
                                                child: Row(children: [
                                                  ButtonDesign(
                                                    color: Color.fromARGB(
                                                        245, 242, 194, 164),
                                                    title: 'Sign in',
                                                    onPressed: () async {
                                                      setState(() {
                                                        showSpinner = true;
                                                      });

                                                      try {
                                                        final user = await _auth
                                                            .signInWithEmailAndPassword(
                                                                email: email,
                                                                password:
                                                                    password);
                                                        //User
                                                        if (user != null &&
                                                            !admin) {
                                                          Navigator.pushNamed(
                                                              context,
                                                              HomePage
                                                                  .screenRoute);
                                                        }
                                                        //Admin
                                                        else if (user != null &&
                                                            admin) {
                                                          Stream<
                                                                  QuerySnapshot<
                                                                      Map<String,
                                                                          dynamic>>>
                                                              collectionStream =
                                                              FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'adminUser')
                                                                  .where(
                                                                      'Email',
                                                                      isEqualTo:
                                                                          email)
                                                                  .snapshots();
                                                          collectionStream.listen(
                                                              (querySnapshot) {
                                                            // Check if there are documents that match the query
                                                            if (querySnapshot
                                                                .docs
                                                                .isNotEmpty) {
                                                              // User with the specified email exists in the 'adminUser' collection

                                                              Navigator.pushNamed(
                                                                  context,
                                                                  AdminScreen
                                                                      .screenRoute);
                                                            } else {
                                                              // User with the specified email doesn't exist in the 'adminUser' collection
                                                              print(
                                                                  'User is not an admin');
                                                            }
                                                            // Handle the case when the user is not an admin }
                                                            setState(() {
                                                              showSpinner =
                                                                  false;
                                                            });
                                                          });
                                                        }
                                                      } catch (e) {
                                                        print(e);
                                                      }
                                                    },
                                                  ),
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                ])))
                                      ])))))))
        ]));
  }
}
