import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';
import 'package:testtapp/Alert/error.dart';
import 'package:testtapp/Alert/success.dart';
import 'package:testtapp/constants.dart';
import 'package:testtapp/models/Vendor.dart';
import 'package:testtapp/screens/Vendor/DropdownList.dart';
import 'package:testtapp/widgets/TextField_vendor.dart';
import 'package:testtapp/widgets/textfield_design.dart';

class VendorProfile extends StatefulWidget {
  const VendorProfile({Key? key}) : super(key: key);

  @override
  State<VendorProfile> createState() => _VendorProfileState();
}

class _VendorProfileState extends State<VendorProfile> {
  Image? pickedImage;
  String fileName = '';
  String imageUrls = '';
  bool showSpinner = false;
  Uint8List? fileBytes;

  final TextEditingController _commercialNameController =
      TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _instegramController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _adressController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController serviceName = TextEditingController();
  final TextEditingController vendorType = TextEditingController();
  @override
  void initState() {
    super.initState();
    _fetchVendorData();
  }

  @override
  void dispose() {
    _commercialNameController.dispose();
    _contactController.dispose();
    _instegramController.dispose();
    _websiteController.dispose();
    _descriptionController.dispose();
    _adressController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  bool anyFieldNotEmpty() {
    return _commercialNameController.text.isNotEmpty &&
        _contactController.text.isNotEmpty &&
        _instegramController.text.isNotEmpty &&
        _websiteController.text.isNotEmpty &&
        _descriptionController.text.isNotEmpty &&
        _adressController.text.isNotEmpty &&
        _locationController.text.isNotEmpty;
  }

  Future<void> _fetchVendorData() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot vendorSnapshot =
        await FirebaseFirestore.instance.collection('vendor').doc(uid).get();
    DocumentReference serviceTypesRef = vendorSnapshot['service_types_id'];
    DocumentReference vendorTypesRef = vendorSnapshot['business_types_id'];
    // Fetch the referenced service_types document
    DocumentSnapshot serviceTypesSnapshot = await serviceTypesRef.get();
    DocumentSnapshot vendorTypesSnapshot = await vendorTypesRef.get();
    setState(() {
      _commercialNameController.text = vendorSnapshot['business_name'];
      _contactController.text = vendorSnapshot['contact_number'];
      _websiteController.text = vendorSnapshot['website'];
      _instegramController.text = vendorSnapshot['instagram_url'];
      _descriptionController.text = vendorSnapshot['bio'];
      _adressController.text = vendorSnapshot['address'];
      _locationController.text = vendorSnapshot['location_url'];
      imageUrls = vendorSnapshot['logo_url'];
      serviceName.text = serviceTypesSnapshot['name'];
      vendorType.text = vendorTypesSnapshot['description'];
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color.fromARGB(0, 255, 255, 255),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              border:
                  Border.all(color: Colors.white.withOpacity(0.3), width: 3),
              borderRadius: BorderRadius.circular(20),
              color: Colors.white.withOpacity(0.22),
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Stack(
                    children: [
                      pickedImage != null
                          ? ClipOval(
                              child: SizedBox(
                                width: size.width * 0.04,
                                height: size.height * 0.04,
                                child: pickedImage!,
                              ),
                            )
                          : CircleAvatar(
                              radius: size.width * 0.025,
                              backgroundColor:
                                  Colors.grey[400]!.withOpacity(0.4),
                              backgroundImage: NetworkImage(imageUrls),
                            ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () async {
                            FilePickerResult? result =
                                await FilePicker.platform.pickFiles();
                            if (result != null) {
                              setState(() {
                                showSpinner = true;
                                fileName = result.files.first.name!;
                              });

                              fileBytes = result.files.first.bytes!;
                              deleteImageByUrl(
                                  imageUrls); // Assuming deleteImageByUrl function is correctly implemented elsewhere

                              // Upload file to Firebase Storage
                              final TaskSnapshot uploadTask =
                                  await FirebaseStorage.instance
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
                          child: CircleAvatar(
                            radius: 12,
                            backgroundColor:
                                Color.fromRGBO(255, 255, 255, 0.075),
                            child: Icon(
                              Icons.camera_alt,
                              size: 16,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextFieldVendor(
                    controller: _commercialNameController,
                    text: 'الإسم التجاري',
                  ),
                  SizedBox(height: 15),
                  TextFieldVendor(
                    controller: _contactController,
                    text: 'رقم الهاتف',
                  ),
                  SizedBox(height: 15),
                  TextFieldVendor(
                    controller: _instegramController,
                    text: 'رابط التواصل الاجتماعي الانستغرام',
                  ),
                  SizedBox(height: 15),
                  TextFieldVendor(
                    controller: _websiteController,
                    text: 'رابط التواصل الاجتماعي موقع ويب',
                  ),
                  SizedBox(height: 15),
                  TextFieldVendor(
                      controller: _adressController, text: 'العنوان'),
                  SizedBox(height: 10),
                  SizedBox(height: 10),
                  TextFieldVendor(
                    controller: _locationController,
                    text: 'الموقع',
                  ),
                  SizedBox(height: 15),
                  TextFieldVendor(
                    controller: _descriptionController,
                    text: 'كيف تعتقد أن عملك سيضيف قيمة إلى إيفينتس؟',
                  ),
                  SizedBox(height: 20),
                  TextField(
                    style: StyleTextAdmin(16, ColorPurple_100),
                    controller: serviceName,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      labelText: 'اسم الخدمة:',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      labelStyle: StyleTextAdmin(18, Colors.black),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    enabled: false,
                  ),
                  SizedBox(height: 10),
                  TextField(
                    style: StyleTextAdmin(16, ColorPurple_100),
                    controller: vendorType,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      labelText: 'نوع المتجر',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      labelStyle: StyleTextAdmin(18, Colors.black),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    enabled: false,
                  ),
                  SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      width: 200,
                      margin: EdgeInsets.only(bottom: 90),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white.withOpacity(0.3),
                      ),
                      child: showSpinner
                          ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : TextButton(
                              onPressed: () async {
                                setState(() {
                                  showSpinner = true;
                                });
                                if (anyFieldNotEmpty()) {
                                  try {
                                    String result = await Vendor.edit(
                                      UID: FirebaseAuth
                                          .instance.currentUser!.uid,
                                      businessName:
                                          _commercialNameController.text,
                                      contactNumber: _contactController.text,
                                      logoUrl: imageUrls,
                                      instagramUrl: _instegramController.text,
                                      website: _websiteController.text,
                                      bio: _descriptionController.text,
                                      address: _adressController.text,
                                      locationUrl: _locationController.text,
                                    );

                                    setState(() {
                                      if (result ==
                                          'تم تعديل المعلومات بنجاح') {
                                        SuccessAlert(context, result);
                                        showSpinner = false;
                                        // Clear text fields and reset image

                                        pickedImage =
                                            null; // Reset picked image
                                      } else {
                                        ErrorAlert(context, 'خطأ', result);
                                      }
                                    });
                                  } catch (error) {
                                    setState(() {
                                      showSpinner = false;
                                    });
                                  }
                                } else {
                                  setState(() {
                                    showSpinner = false;
                                  });
                                  ErrorAlert(context, 'خطأ',
                                      'الرجاء إدخال كل البيانات المطلوبة');
                                }
                              },
                              child: Text(
                                'حفظ التغيرات',
                                style: StyleTextAdmin(
                                  16,
                                  Colors.black,
                                ),
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
