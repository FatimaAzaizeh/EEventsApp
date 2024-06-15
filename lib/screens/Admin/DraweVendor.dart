import 'dart:typed_data';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:testtapp/Alert/error.dart';
import 'package:testtapp/Alert/info.dart';
import 'package:testtapp/Alert/success.dart';
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
  late DocumentReference businessTypeId;
  String email = '';
  String socialMedia = '';
  String commercialName = '';
  String description = '';
  String password = '';
  String fileName = " لم يتم اختيار صورة";
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
              _buildDrawerHeader(size),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    _buildCustomTextField(
                        'الإسم التجاري',
                        _commercialNameController,
                        TextInputType.text,
                        false,
                        (value) => commercialName = value),
                    SizedBox(height: 10),
                    _buildCustomTextField(
                        'ادخال البريد الالكتروني',
                        _emailController,
                        TextInputType.emailAddress,
                        false,
                        (value) => email = value),
                    SizedBox(height: 10),
                    _buildCustomTextField(
                        'رابط التواصل الاجتماعي',
                        _socialMediaController,
                        TextInputType.text,
                        false,
                        (value) => socialMedia = value),
                    SizedBox(height: 10),
                    _buildCustomTextField(
                        'أدخال كلمة المرور',
                        _passwordController,
                        TextInputType.visiblePassword,
                        true,
                        (value) => password = value),
                    SizedBox(height: 10),
                    _buildCustomTextField(
                        'كيف تعتقد أن عملك سيضيف قيمة إلى إيفينتس؟',
                        _descriptionController,
                        TextInputType.text,
                        false,
                        (value) => description = value),
                    SizedBox(height: 10),
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
                              .limit(1)
                              .get()
                              .then((QuerySnapshot querySnapshot) {
                            if (querySnapshot.docs.isNotEmpty) {
                              DocumentSnapshot docSnapshot =
                                  querySnapshot.docs.first;
                              serviceTypeId = docSnapshot.reference;
                            }
                          });
                        }
                      },
                    ),
                    FirestoreDropdown(
                      collectionName: 'business_types',
                      dropdownLabel: 'نوع المتجر',
                      onChanged: (value) {
                        if (value != null) {
                          FirebaseFirestore.instance
                              .collection("business_types")
                              .where('description', isEqualTo: value.toString())
                              .limit(1)
                              .get()
                              .then((QuerySnapshot querySnapshot) {
                            if (querySnapshot.docs.isNotEmpty) {
                              DocumentSnapshot docSnapshot =
                                  querySnapshot.docs.first;
                              DocumentReference busTypeRef =
                                  docSnapshot.reference;
                              businessTypeId = busTypeRef;
                              setState(() {});
                            }
                          });
                        }
                      },
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor:
                              ColorPink_100, // Change this to your desired text color
                          padding: EdgeInsets.symmetric(
                              horizontal: 32, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          )),
                      child: Text('تسجيل'),
                    ),
                  ],
                ),
              ),
              _buildBottomImage(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(Size size) {
    return Container(
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
            Color.fromARGB(233, 239, 182, 178),
            Color.fromARGB(175, 239, 199, 241),
          ],
        ),
      ),
      child: DrawerHeader(
        padding: EdgeInsets.zero,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _pickFile, // Handle avatar tap to pick file
              child: pickedImage != null
                  ? ClipOval(
                      child: SizedBox(
                        width: size.width * 0.04,
                        height: size.width * 0.04,
                        child: pickedImage!,
                      ),
                    )
                  : Tooltip(
                      message: 'إضغط هنا لإضافة صورة',
                      child: CircleAvatar(
                        radius: size.width * 0.02,
                        backgroundColor: Colors.grey[400]!.withOpacity(0.4),
                        child: Icon(
                          Icons.person_3_outlined,
                          color: Colors.white,
                          size: size.width * 0.02,
                        ),
                      ),
                    ),
            ),
            SizedBox(height: 10),
            Text(
              'هل تود تسجيل الدخول كبائع؟',
              style: StyleTextAdmin(20, activeColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomTextField(
      String hintText,
      TextEditingController controller,
      TextInputType keyboardType,
      bool obscureText,
      ValueChanged<String> onChanged) {
    return CustomTextField(
      //color: activeColor,
      hintText: hintText,
      keyboardType: keyboardType,
      onChanged: onChanged,
      obscureText: obscureText,
      TextController: controller, color: activeColor,
    );
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        showSpinner = true;
        fileName = result.files.first.name;
      });

      fileBytes = result.files.first.bytes;

      // Upload file to Firebase Storage
      final TaskSnapshot uploadTask = await FirebaseStorage.instance
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
  }

  Future<void> _submitForm() async {
    setState(() {
      showSpinner = true;
    });

    try {
      DocumentReference vendorStatusRef =
          FirebaseFirestore.instance.collection('vendor_status').doc('1');
      final _auth = FirebaseAuth.instance;
      final newUser = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (newUser.user != null) {
        String uid = newUser.user!.uid;
        Timestamp myTimestamp = Timestamp.now();
        UserDataBase newVendorUser = UserDataBase(
          UID: uid,
          email: _emailController.text,
          name: _commercialNameController.text,
          user_type_id:
              FirebaseFirestore.instance.collection('user_types').doc('3'),
          phone: '',
          address: '',
          isActive: false,
          imageUrl: imageUrls,
        );

        String result = await newVendorUser.saveToDatabase();

        if (result == 'تمت إضافة المستخدم إلى قاعدة البيانات بنجاح!') {
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
            SuccessAlert(context, 'تم تقديم الطلب بنجاح');
          });
        } else if (result.contains('خطأ')) {
          setState(() {
            ErrorAlert(context, 'خطأ', '$result');
          });
        } else {
          InfoAlert(context, 'معلومات مكررة', result);
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
  }

  Widget _buildBottomImage(BuildContext context) {
    return Positioned(
      bottom: 0,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.3,
        width: double.maxFinite,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/Vendor.png'),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
