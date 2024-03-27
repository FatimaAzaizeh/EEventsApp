import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; //firebase
import 'package:google_sign_in/google_sign_in.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:testtapp/responsive.dart';
import 'package:testtapp/screens/Admin_screen.dart';
import 'package:testtapp/screens/chat_screen.dart';
import 'package:testtapp/screens/registration_screen.dart';
import 'package:testtapp/widgets/alert_code.dart';
import 'package:testtapp/widgets/button_design.dart';
import 'package:testtapp/widgets/textfield_design.dart';

class SignIn extends StatefulWidget {
  static const String screenRoute = 'Sign_in';
  const SignIn({Key? key}) : super(key: key);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final _auth = FirebaseAuth.instance;
  late bool admin = false;
  late String email;
  late String password;
  bool showSpinner = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          image: DecorationImage(
            image: AssetImage(
              '',
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: ModalProgressHUD(
          inAsyncCall: showSpinner,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                    height: 180, child: Center(child: Text('تسجيل الدخول '))),
                SizedBox(height: 50),
                Text('البريد الالكتروني'),
                CustomTextField(
                  hintText: 'ادخال البريد الالكتروني',
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (value) {
                    email = value;
                  },
                  obscureText: false,
                ),
                SizedBox(height: 8),
                Text(' كلمة المرور'),
                CustomTextField(
                  hintText: 'أدخال كلمة المرور',
                  keyboardType: TextInputType.visiblePassword,
                  onChanged: (value) {
                    password = value;
                  },
                  obscureText: true,
                ),
                SizedBox(height: 10),
                ButtonDesign(
                  color: Color.fromARGB(26, 23, 186, 245)!,
                  title: 'Sign in',
                  onPressed: () async {
                    setState(() {
                      showSpinner = true;
                    });

                    try {
                      final user = await _auth.signInWithEmailAndPassword(
                          email: email, password: password);
                      //User
                      if (user != null && !admin) {
                        //Navigator.pushNamed(context, ChatScreen.screenRoute);
                      }
                      //Admin
                      else if (user != null && admin) {
                        Stream<QuerySnapshot<Map<String, dynamic>>>
                            collectionStream = FirebaseFirestore.instance
                                .collection('adminUser')
                                .where('Email', isEqualTo: email)
                                .snapshots();
                        collectionStream.listen((querySnapshot) {
                          // Check if there are documents that match the query
                          if (querySnapshot.docs.isNotEmpty) {
                            // User with the specified email exists in the 'adminUser' collection

                            Navigator.pushNamed(
                                context, AdminScreen.screenRoute);
                          } else {
                            // User with the specified email doesn't exist in the 'adminUser' collection
                            print('User is not an admin');
                          }
                          // Handle the case when the user is not an admin }
                          setState(() {
                            showSpinner = false;
                          });
                        });
                      }
                    } catch (e) {
                      print(e);
                    }
                  },
                ),
                Text('مسؤول'),
                Checkbox(
                  value: admin,
                  onChanged: (value) {
                    setState(() {
                      admin = value!;
                    });
                  },
                ),
                ButtonDesign(
                  color: Color.fromARGB(58, 229, 235, 241)!,
                  title: 'gmail',
                  onPressed: () async {
                    {
                      final GoogleSignIn googleSignIn = GoogleSignIn();

                      try {
                        final GoogleSignInAccount? googleSignInAccount =
                            await googleSignIn.signIn();
                        final GoogleSignInAuthentication
                            googleSignInAuthentication =
                            await googleSignInAccount!.authentication;

                        final AuthCredential credential =
                            GoogleAuthProvider.credential(
                          accessToken: googleSignInAuthentication.accessToken,
                          idToken: googleSignInAuthentication.idToken,
                        );

                        final UserCredential userCredential = await FirebaseAuth
                            .instance
                            .signInWithCredential(credential);
                        final User? user = userCredential.user;

                        // Use the user object for further operations or navigate to a new screen.
                        Navigator.pushNamed(context, ChatScreen.screenRoute);
                      } catch (e) {
                        print(e.toString());
                      }
                    }
                  },
                ),
                TextButton(
                    onPressed: () {
                      Navigator.pushNamed(
                          context, RegistrationScreen.screenRoute);
                    },
                    child: Text('تسجيل مستخدم جديد'))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
