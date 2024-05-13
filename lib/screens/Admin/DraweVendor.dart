import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:testtapp/constants.dart';
import 'package:testtapp/models/User.dart';
import 'package:testtapp/models/Vendor.dart';
import 'package:testtapp/screens/Vendor/button.dart';
import 'package:testtapp/widgets/textfield_design.dart';

final _firestore = FirebaseFirestore.instance;
Uint8List? fileBytes;
String fileName = "لم يتم اختيار صورة ";

class DrawerVendor extends StatefulWidget {
  const DrawerVendor({Key? key}) : super(key: key);

  @override
  State<DrawerVendor> createState() => _DrawerVendorState();
}

class _DrawerVendorState extends State<DrawerVendor> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _commercialName = TextEditingController();
  final TextEditingController _socialMedia = TextEditingController();
  final TextEditingController _description = TextEditingController();
  late String imageUrl;
  String email = '';
  String socialMedia = '';
  String commercialName = '';
  String description = '';
  String password = '';
  String fileName = "No File Selected";
  Uint8List? fileBytes;
  bool showSpinner = false;
  List<String> images = [];
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.fromARGB(255, 239, 182, 178),
                    Color.fromARGB(255, 242, 207, 137),
                  ],
                ),
              ),
              child: Text(
                'هل تود تسجيل الدخول كمنظم؟',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomTextField(
                    hintText: 'الإسم التجاري',
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (value) {
                      setState(() {
                        commercialName = value;
                      });
                    },
                    obscureText: false,
                    TextController: _commercialName,
                  ),
                  SizedBox(height: 8),
                  CustomTextField(
                    hintText: 'ادخال البريد الالكتروني',
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (value) {
                      setState(() {
                        email = value;
                      });
                    },
                    obscureText: false,
                    TextController: _emailController,
                  ),
                  SizedBox(height: 8),
                  CustomTextField(
                    hintText: 'رابط التواصل الاجتماعي',
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (value) {
                      setState(() {
                        socialMedia = value;
                      });
                    },
                    obscureText: false,
                    TextController: _socialMedia,
                  ),
                  SizedBox(height: 8),
                  CustomTextField(
                    hintText: 'أدخال كلمة المرور',
                    keyboardType: TextInputType.visiblePassword,
                    onChanged: (value) {
                      setState(() {
                        password = value;
                      });
                    },
                    obscureText: true,
                    TextController: _passwordController,
                  ),
                  SizedBox(height: 8),
                  CustomTextField(
                    hintText: 'كيف تعتقد أن عملك سيضيف قيمة إلى إييفينتس؟',
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (value) {
                      setState(() {
                        description = value;
                      });
                    },
                    obscureText: false,
                    TextController: _description,
                  ),
                  ButtonWidget(
                    text: 'Select File',
                    icon: Icons.attach_file,
                    onClicked: () async {
                      FilePickerResult? result =
                          await FilePicker.platform.pickFiles();

                      if (result != null) {
                        fileBytes = result.files.first.bytes;
                        setState(() async {
                          fileName = result.files.first.name;
                          // Upload file to Firebase Storage
                          final TaskSnapshot uploadTask = await FirebaseStorage
                              .instance
                              .ref('uploads/$fileName')
                              .putData(fileBytes!);

                          // Get download URL of the uploaded file

                          imageUrl = await uploadTask.ref.getDownloadURL();

                          images.add(imageUrl);
                          images.add(imageUrl);
                          images.add(imageUrl);

                          print('Download URL: $imageUrl');
                        });
                      }
                    },
                  ),
                  Row(
                    children: [
                      Container(
                        child: IconButton(
                          onPressed: () async {
                            FilePickerResult? result =
                                await FilePicker.platform.pickFiles();
                            if (result != null) {
                              fileBytes = result.files.first.bytes;
                              setState(() async {
                                showSpinner = true;
                                fileName = result.files.first.name;
                                // Upload file to Firebase Storage
                                final TaskSnapshot uploadTask =
                                    await FirebaseStorage.instance
                                        .ref('uploads/$fileName')
                                        .putData(fileBytes!);

                                // Get download URL of the uploaded file
                                String imageUrl =
                                    await uploadTask.ref.getDownloadURL();

                                // Add the download URL to Firestore
                                await _firestore.collection('image').add({
                                  'name': imageUrl,
                                });

                                print('Download URL: $imageUrl');
                                showSpinner = false;
                              });
                            }
                          },
                          icon: Icon(
                            Icons.add,
                            size: 16,
                          ),
                        ),
                      ),
                      Container(
                        child: IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.add, size: 16),
                        ),
                      ),
                      Container(
                        child: IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.add, size: 16),
                        ),
                      )
                    ],
                  ),
                  Text(
                    fileName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      style: const ButtonStyle(
                          animationDuration: Durations.long3,
                          backgroundColor:
                              MaterialStatePropertyAll(Colors.black)),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('إنشاء حساب  ',
                            style: StyleTextAdmin(17, Colors.white)),
                      ),
                      onPressed: () async {
                        setState(() {
                          showSpinner = true; //ما ببين في مشكلة
                        });

                        try {
                          final newUser =
                              await _auth.createUserWithEmailAndPassword(
                            email: email,
                            password: password,
                          );
                          // Upload file to Firebase Storage
                          final TaskSnapshot uploadTask = await FirebaseStorage
                              .instance
                              .ref('uploads/$fileName')
                              .putData(fileBytes!);

                          // Get download URL of the uploaded file
                          imageUrl = await uploadTask.ref.getDownloadURL();

                          // Add the download URL to Firestore
                          if (newUser.user != null) {
                            String? uid = newUser.user!
                                .uid; // Access the UID from the created user
                            DocumentReference docRef3 =
                                _firestore.collection('user_type').doc('3');
                            UserDataBase newuser = UserDataBase(
                              UID: uid,
                              email: _emailController.text,
                              name: _commercialName.text,
                              user_type_id: docRef3,
                              phone: '',
                              address: '',
                              isActive: false,
                              imageUrl: imageUrl,
                            );
                            await newuser.saveToDatabase();
                          }

                          setState(() {
                            showSpinner = false;
                            _emailController.clear();
                            _passwordController.clear();
                            fileBytes = null;
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
                  Container(
                    width: double.maxFinite,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(ColorCream_100),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          showSpinner = true;
                        });
                        // Handle sign up logic
                      },
                      child: Text('تقديم الطلب'),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.1,
                width: double.maxFinite,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/Vendor.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
