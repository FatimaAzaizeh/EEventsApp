import 'dart:typed_data';
import 'dart:ui';
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
import 'package:testtapp/screens/Vendor/DropdownList.dart';
import 'package:testtapp/widgets/textfield_design.dart';

final _firestore = FirebaseFirestore.instance;

class DrawerVendor extends StatefulWidget {
  const DrawerVendor({Key? key}) : super(key: key);

  @override
  State<DrawerVendor> createState() => _DrawerVendorState();
}

class _DrawerVendorState extends State<DrawerVendor> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _commercialNameController =
      TextEditingController();
  final TextEditingController _socialMediaController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  late DocumentReference serviceTypeId;
  String email = '';
  String socialMedia = '';
  String commercialName = '';
  String description = '';
  String password = '';
  String fileName = "No File Selected";
  Uint8List? fileBytes;
  bool showSpinner = false;
  String imageUrls = '';
  Image? pickedImage; // Variable to hold the picked image

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double drawerWidth = size.width * 0.3;
    return Drawer(
      width: drawerWidth,
      child: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.fromARGB(255, 239, 182, 178),
                      Color.fromARGB(255, 242, 207, 137),
                    ],
                  ),
                ),
                child: DrawerHeader(
                  padding: EdgeInsets.zero,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Display picked image within CircleAvatar
                      pickedImage != null
                          ? ClipOval(
                              child: SizedBox(
                                width: size.width * 0.04, // Adjust as needed
                                height: size.width * 0.04, // Adjust as needed
                                child: pickedImage!,
                              ),
                            )
                          : CircleAvatar(
                              radius: size.width * 0.02,
                              backgroundColor:
                                  Colors.grey[400]!.withOpacity(0.4),
                              child: Icon(
                                Icons.person_3_outlined,
                                color: Colors.white,
                                size: size.width * 0.02,
                              ),
                            ),
                      SizedBox(height: 10),
                      Text(
                        'هل تود تسجيل الدخول كمنظم؟',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(height: 10),
                    CustomTextField(
                      hintText: 'الإسم التجاري',
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (value) {
                        setState(() {
                          commercialName = value;
                        });
                      },
                      obscureText: false,
                      TextController: _commercialNameController, color: activeColor,
                    ),
                    SizedBox(height: 10),
                    CustomTextField(
                      hintText: 'ادخال البريد الالكتروني',
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (value) {
                        setState(() {
                          email = value;
                        });
                      },
                      obscureText: false,
                      TextController: _emailController, color: activeColor,
                    ),
                    SizedBox(height: 10),
                    CustomTextField(
                      hintText: 'رابط التواصل الاجتماعي',
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (value) {
                        setState(() {
                          socialMedia = value;
                        });
                      },
                      obscureText: false,
                      TextController: _socialMediaController, color: activeColor,
                    ),
                    SizedBox(height: 10),
                    CustomTextField(
                      hintText: 'أدخال كلمة المرور',
                      keyboardType: TextInputType.visiblePassword,
                      onChanged: (value) {
                        setState(() {
                          password = value;
                        });
                      },
                      obscureText: true,
                      TextController: _passwordController, color: activeColor,
                    ),
                    SizedBox(height: 10),
                    CustomTextField(
                      hintText: 'كيف تعتقد أن عملك سيضيف قيمة إلى إيفينتس؟',
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (value) {
                        setState(() {
                          description = value;
                        });
                      },
                      obscureText: false,
                      TextController: _descriptionController, color: activeColor,
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () async {
                        FilePickerResult? result =
                            await FilePicker.platform.pickFiles();
                        if (result != null) {
                          setState(() {
                            showSpinner = true;
                            fileName = result.files.first.name;
                          });

                          fileBytes = result.files.first.bytes;

                          // Upload file to Firebase Storage
                          final TaskSnapshot uploadTask = await FirebaseStorage
                              .instance
                              .ref('uploads/$fileName')
                              .putData(fileBytes!);

                          // Get download URL of the uploaded file
                          imageUrls = await uploadTask.ref.getDownloadURL();

                          // Set the picked image
                          setState(() {
                            showSpinner = false;

                            pickedImage = Image.memory(fileBytes!);
                          });
                        }
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add, size: 16),
                          SizedBox(width: 4),
                          Text('إضافة صورة'),
                        ],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      fileName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 10),
                    FirestoreDropdown(
                      collectionName: 'service_types',
                      dropdownLabel: 'نوع الخدمة',
                      onChanged: (value) {
                        if (value != null) {
                          FirebaseFirestore.instance
                              .collection('service_types')
                              .where('name', isEqualTo: value.toString())
                              .limit(
                                  1) // Limiting to one document as 'where' query might return multiple documents
                              .get()
                              .then((QuerySnapshot querySnapshot) {
                            if (querySnapshot.docs.isNotEmpty) {
                              // If document(s) found, assign the reference
                              DocumentSnapshot docSnapshot =
                                  querySnapshot.docs.first;
                              DocumentReference ServiceRef =
                                  docSnapshot.reference;
                              serviceTypeId = ServiceRef;
                              // Now you can use itemStatusRef as needed
                              // For example, you can store it in a state variable or perform other operations with it
                              setState(() {
                                // Store the DocumentReference in a state variable or use it as needed
                              });
                            } else {
                              // If no document found, handle the case accordingly
                            }
                          });
                        }
                      },
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          showSpinner = true;
                        });

                        try {
                          DocumentReference vendorStatusRef = FirebaseFirestore
                              .instance
                              .collection('vendor_status')
                              .doc('1');

                          final _auth = FirebaseAuth.instance;
                          final newUser =
                              await _auth.createUserWithEmailAndPassword(
                            email: email,
                            password: password,
                          );

                          if (newUser.user != null) {
                            String uid = newUser.user!.uid;
                            // Initialize with current time
                            Timestamp myTimestamp = Timestamp.now();
                            UserDataBase newVendorUser = UserDataBase(
                              UID: uid,
                              email: _emailController.text,
                              name: _commercialNameController.text,
                              user_type_id: FirebaseFirestore.instance
                                  .collection('user_types')
                                  .doc('3'),
                              phone: '',
                              address: '',
                              isActive: false,
                              imageUrl: imageUrls,
                            );

                            String result =
                                await newVendorUser.saveToDatabase();

                            if (result ==
                                'User added to the database successfully!') {
                              Vendor newVendor = Vendor(
                                id: uid,
                                businessName: _commercialNameController.text,
                                email: _emailController.text,
                                contactNumber: '',
                                logoUrl: imageUrls,
                                instagramUrl: _socialMediaController.text,
                                website: '',
                                bio: _descriptionController.text,
                                serviceTypesId: serviceTypeId,
                                businessTypesId: '',
                                address: '',
                                locationUrl: '',
                                workingHour: {},
                                createdAt: myTimestamp,
                                vendorStatusId: vendorStatusRef,
                              );

                              await newVendor.addToFirestore();
                              setState(() {
                                QuickAlert.show(
                                  context: context,
                                  text: 'User and vendor added successfully!',
                                  type: QuickAlertType.success,
                                );
                              });
                            } else {
                              setState(() {
                                QuickAlert.show(
                                  context: context,
                                  text: 'Error: $result',
                                  type: QuickAlertType.error,
                                );
                              });
                            }

                            setState(() {
                              showSpinner = false;
                              // Clear text fields and reset image
                              _commercialNameController.clear();
                              _emailController.clear();
                              _passwordController.clear();
                              _socialMediaController.clear();
                              _descriptionController.clear();
                              pickedImage = null; // Reset picked image
                            });
                          }
                        } catch (e) {
                          print(e);
                          setState(() {
                            showSpinner = false;
                          });
                        }
                      },
                      child: Text('Submit'),
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
      ),
    );
  }
}
