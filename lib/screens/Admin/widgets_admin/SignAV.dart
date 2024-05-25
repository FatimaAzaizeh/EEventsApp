import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:testtapp/constants.dart';
import 'package:testtapp/models/User.dart';
import 'package:testtapp/screens/Admin/Admin_screen.dart';
import 'package:testtapp/screens/Admin/DraweVendor.dart';
import 'package:testtapp/screens/Vendor/VendorHome.dart';
import 'package:testtapp/screens/loginAdmin.dart';
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
                              color: Colors.white,
                              //Color.fromARGB(158, 251, 248, 248),
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
                                          height: 250,
                                          width: 250,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadiusDirectional
                                                    .circular(30),
                                            image: DecorationImage(
                                              image: AssetImage(
                                                  'assets/images/logo2.png'),
                                              fit: BoxFit.fill,
                                            ),
                                          ),
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
                                        Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Center(
                                                child: ButtonDesign(
                                                  color: ColorPink_100,
                                                  // Color.fromARGB(
                                                  //  245, 242, 194, 164),
                                                  title: 'تسجيل الدخول ',

                                                  onPressed: () async {
                                                    setState(() {
                                                      showSpinner = true;
                                                    });
                                                    try {
                                                      final user = await _auth
                                                          .signInWithEmailAndPassword(
                                                        email: email,
                                                        password: password,
                                                      );

                                                      if (user != null) {
                                                        String? uid =
                                                            FirebaseAuth
                                                                .instance
                                                                .currentUser
                                                                ?.uid;

                                                        // Check if the user is not an admin
                                                        if (!admin &&
                                                            isVendorSelected) {
                                                          String userId = uid ??
                                                              ''; // Replace 'your_user_id_here' with the actual user ID
                                                          DocumentReference
                                                              userTypeRef =
                                                              FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'user_types')
                                                                  .doc('3');

                                                          bool isValid =
                                                              await UserDataBase
                                                                  .isUserTypeReferenceValid(
                                                                      userId,
                                                                      userTypeRef);
                                                          if (isValid) {
                                                            Navigator.pushNamed(
                                                                context,
                                                                VendorHome
                                                                    .screenRoute);

                                                            return;
                                                          } else {
                                                            setState(() {
                                                              showSpinner =
                                                                  false;
                                                            });
                                                            return QuickAlert
                                                                .show(
                                                              context: context,
                                                              title: 'خطأ',
                                                              text:
                                                                  'الحساب الذي تحاول الدخول بة ليس حساب بائع',
                                                              type:
                                                                  QuickAlertType
                                                                      .error,
                                                              confirmBtnText:
                                                                  'إغلاق',
                                                            );
                                                          } // Exit the function after navigating
                                                        }

                                                        // Check if the user is an admin
                                                        if (admin) {
                                                          String userId = uid ??
                                                              ''; // Replace 'your_user_id_here' with the actual user ID
                                                          DocumentReference
                                                              userTypeRef =
                                                              FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'user_types')
                                                                  .doc('1');

                                                          bool isValid =
                                                              await UserDataBase
                                                                  .isUserTypeReferenceValid(
                                                                      userId,
                                                                      userTypeRef);

                                                          if (isValid) {
                                                            Navigator.pushNamed(
                                                                context,
                                                                AdminScreen
                                                                    .screenRoute);
                                                          } else {
                                                            setState(() {
                                                              showSpinner =
                                                                  false;
                                                            });
                                                            return QuickAlert
                                                                .show(
                                                              context: context,
                                                              title: 'خطأ',
                                                              text:
                                                                  'الحساب الذي تحاول الدخول بة ليس حساب مسؤول',
                                                              type:
                                                                  QuickAlertType
                                                                      .error,
                                                              confirmBtnText:
                                                                  'إغلاق',
                                                            );
                                                          }

                                                          return; // Exit the function after navigating
                                                        }
                                                      }
                                                    } catch (e) {
                                                      print(e);
                                                    }
                                                  },
                                                ),
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                            ])
                                      ])))))))
        ]));
  }
}
