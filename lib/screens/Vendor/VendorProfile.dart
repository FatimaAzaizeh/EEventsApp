import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:testtapp/models/Vendor.dart';
import 'package:testtapp/screens/Vendor/DropdownList.dart';
import 'package:testtapp/widgets/textfield_design.dart';

String serviceName = '';
Image? pickedImage;
String fileName = '';
String commercialName = '';
String email = '';
String socialMedia = '';
String description = '';
bool showSpinner = false;
Uint8List? fileBytes;
String imageUrls = '';
TextEditingController _commercialNameController = TextEditingController();
TextEditingController _contactController = TextEditingController();
TextEditingController _instegramController = TextEditingController();
TextEditingController _websiteController = TextEditingController();
TextEditingController _descriptionController = TextEditingController();
TextEditingController _adressController = TextEditingController();
TextEditingController _locatinController = TextEditingController();
late DocumentReference bussnessTypeId;
late DocumentReference serviceTypeId;

class ProfileVendor extends StatefulWidget {
  const ProfileVendor({Key? key}) : super(key: key);

  @override
  State<ProfileVendor> createState() => _ProfileVendorState();
}

class _ProfileVendorState extends State<ProfileVendor> {
  late Future<Vendor> _vendorFuture;

  @override
  void initState() {
    super.initState();
    _fetchVendorData();
  }

  Future<void> _fetchVendorData() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot vendorSnapshot =
        await FirebaseFirestore.instance.collection('vendor').doc(uid).get();
    DocumentReference serviceTypesRef = vendorSnapshot['service_types_id'];

    // Fetch the referenced service_types document
    DocumentSnapshot serviceTypesSnapshot = await serviceTypesRef.get();
    setState(() {
      _commercialNameController.text = vendorSnapshot['business_name'];
      _contactController.text = vendorSnapshot['contact_number'];
      _websiteController.text = vendorSnapshot['website'];
      _instegramController.text = vendorSnapshot['instagram_url'];
      _descriptionController.text = vendorSnapshot['bio'];
      _adressController.text = vendorSnapshot['address'];
      _locatinController.text = vendorSnapshot['location_url'];
      imageUrls = vendorSnapshot['logo_url'];
      serviceName = serviceTypesSnapshot['name'];
      // Check if the service_types document exists
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            pickedImage != null
                ? ClipOval(
                    child: SizedBox(
                      width: size.width * 0.4,
                      height: size.width * 0.4,
                      child: pickedImage,
                    ),
                  )
                : CircleAvatar(
                    radius: size.width * 0.2,
                    backgroundColor: Colors.grey[400]!.withOpacity(0.4),
                    backgroundImage: NetworkImage(imageUrls),
                  ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(height: 10),
                  CustomTextField(
                    hintText: 'الإسم التجاري',
                    keyboardType: TextInputType.text,
                    onChanged: (value) {
                      setState(() {
                        commercialName = value;
                      });
                    },
                    obscureText: false,
                    TextController: _commercialNameController,
                  ),
                  SizedBox(height: 10),
                  CustomTextField(
                    hintText: 'رقم الهاتف',
                    keyboardType: TextInputType.phone,
                    onChanged: (value) {
                      setState(() {});
                    },
                    obscureText: false,
                    TextController: _contactController,
                  ),
                  SizedBox(height: 10),
                  CustomTextField(
                    hintText: ' رابط التواصل الاجتماعي الانستغرام',
                    keyboardType: TextInputType.text,
                    onChanged: (value) {
                      setState(() {});
                    },
                    obscureText: false,
                    TextController: _instegramController,
                  ),
                  CustomTextField(
                    hintText: '  رابط التواصل الاجتماعي موقع ويب',
                    keyboardType: TextInputType.text,
                    onChanged: (value) {
                      setState(() {});
                    },
                    obscureText: false,
                    TextController: _websiteController,
                  ),
                  SizedBox(height: 10),
                  CustomTextField(
                    hintText: 'العنوان',
                    keyboardType: TextInputType.text,
                    onChanged: (value) {
                      setState(() {});
                    },
                    obscureText: false,
                    TextController: _adressController,
                  ),
                  CustomTextField(
                    hintText: 'الموقع',
                    keyboardType: TextInputType.text,
                    onChanged: (value) {
                      setState(() {});
                    },
                    obscureText: false,
                    TextController: _locatinController,
                  ),
                  SizedBox(height: 10),
                  CustomTextField(
                    hintText: 'كيف تعتقد أن عملك سيضيف قيمة إلى إيفينتس؟',
                    keyboardType: TextInputType.text,
                    onChanged: (value) {
                      setState(() {
                        description = value;
                      });
                    },
                    obscureText: false,
                    TextController: _descriptionController,
                  ),
                  SizedBox(height: 10),
                  Text('Service Name: $serviceName'),
                  FirestoreDropdown(
                    collectionName: 'business_types',
                    dropdownLabel: 'نوع المتجر',
                    onChanged: (value) {
                      if (value != null) {
                        FirebaseFirestore.instance
                            .collection("business_types")
                            .where('description', isEqualTo: value.toString())
                            .limit(
                                1) // Limiting to one document as 'where' query might return multiple documents
                            .get()
                            .then((QuerySnapshot querySnapshot) {
                          if (querySnapshot.docs.isNotEmpty) {
                            // If document(s) found, assign the reference
                            DocumentSnapshot docSnapshot =
                                querySnapshot.docs.first;
                            DocumentReference bussTyoeRef =
                                docSnapshot.reference;
                            bussnessTypeId = bussTyoeRef;
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
                      FilePickerResult? result =
                          await FilePicker.platform.pickFiles();
                      if (result != null) {
                        setState(() {
                          showSpinner = true;
                          fileName = result.files.first.name!;
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
                  ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        showSpinner = true;
                      });

                      try {
                        await Vendor.edit(
                          UID: FirebaseAuth.instance.currentUser!.uid,
                          businessName: commercialName,
                          contactNumber: _contactController.text,
                          logoUrl: imageUrls,
                          instagramUrl: _instegramController.text,
                          website: _websiteController.text,
                          bio: _descriptionController.text,
                          businessTypesId: bussnessTypeId,
                          address: _adressController.text,
                          locationUrl: _locatinController.text,
                        );

                        setState(() {
                          showSpinner = false;
                          // Clear text fields and reset image
                          _commercialNameController.clear();
                          _locatinController.clear();
                          _adressController.clear();
                          _instegramController.clear();
                          _descriptionController.clear();

                          pickedImage = null; // Reset picked image
                        });
                      } catch (e) {
                        print(e);
                        setState(() {
                          showSpinner = false;
                        });
                      }
                    },
                    child: Text('حفظ التعديل'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
