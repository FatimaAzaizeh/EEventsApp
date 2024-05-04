import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:testtapp/constants.dart';
import 'package:testtapp/models/Vendor.dart';
import 'package:testtapp/screens/Vendor/button.dart';
import 'package:testtapp/widgets/textfield_design.dart';

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

  String email = '';
  String socialMedia = '';
  String commercialName = '';
  String description = '';
  String password = '';
  String fileName = "No File Selected";
  Uint8List? fileBytes;
  bool showSpinner = false;
  List<String> images = [];

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

                          String imageUrl =
                              await uploadTask.ref.getDownloadURL();

                          images.add(imageUrl);
                          images.add(imageUrl);
                          images.add(imageUrl);

                          print('Download URL: $imageUrl');
                        });
                      }
                    },
                  ),
                  Text(
                    fileName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    width: double.maxFinite,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(kColor1),
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

                        Vendor vendorNew = Vendor(
                          CommercialName: _commercialName.text,
                          email: _emailController.text,
                          socialMedia: _socialMedia.text,
                          description: _description.text,
                          state: false,
                          images: images,
                        );
                        vendorNew.addToFirestore();

                        _commercialName.clear();
                        _emailController.clear();
                        _passwordController.clear();
                        _socialMedia.clear();
                        _description.clear();
                        setState(() {
                          showSpinner = false;
                        });
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
