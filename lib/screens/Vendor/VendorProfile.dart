import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:testtapp/constants.dart';
import 'package:testtapp/models/Vendor.dart';
import 'package:testtapp/screens/Vendor/DropdownList.dart';
import 'package:testtapp/widgets/textfield_design.dart';

class ProfileVendor extends StatefulWidget {
  const ProfileVendor({Key? key}) : super(key: key);

  @override
  State<ProfileVendor> createState() => _ProfileVendorState();
}

class _ProfileVendorState extends State<ProfileVendor> {
  String serviceName = '';
  Image? pickedImage;
  String fileName = '';
  String imageUrls = '';
  bool showSpinner = false;
  Uint8List? fileBytes;
  
  late DocumentReference businessTypeId;

  final TextEditingController _commercialNameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _instegramController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _adressController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

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

  Future<void> _fetchVendorData() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot vendorSnapshot = await FirebaseFirestore.instance.collection('vendor').doc(uid).get();
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
      _locationController.text = vendorSnapshot['location_url'];
      imageUrls = vendorSnapshot['logo_url'];
      serviceName = serviceTypesSnapshot['name'];
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/signin.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Center(
              child: Container(
                color: Color.fromARGB(55, 245, 234, 222),
                width: 900,
                height: 700,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      children: [
                        pickedImage != null
                            ? ClipOval(
                                child: SizedBox(
                                  width: size.width * 0.04,
                                  height: size.height * 0.04,
                                  child: pickedImage,
                                ),
                              )
                            : CircleAvatar(
                                radius: size.width * 0.02,
                                backgroundColor: Colors.grey[400]!.withOpacity(0.4),
                                backgroundImage: NetworkImage(imageUrls),
                              ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () async {
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
                            },
                            child: CircleAvatar(
                              radius: 12,
                              backgroundColor: const Color.fromARGB(19, 255, 255, 255),
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
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomTextField(
                            color: activeColor,
                            hintText: 'الإسم التجاري',
                            keyboardType: TextInputType.text,
                            onChanged: (value) {},
                            obscureText: false,
                            TextController: _commercialNameController,
                          ),
                          SizedBox(height: 10),
                          CustomTextField(
                            color: activeColor,
                            hintText: 'رقم الهاتف',
                            keyboardType: TextInputType.phone,
                            onChanged: (value) {},
                            obscureText: false,
                            TextController: _contactController,
                          ),
                          SizedBox(height: 10),
                          CustomTextField(
                            color: activeColor,
                            hintText: 'رابط التواصل الاجتماعي الانستغرام',
                            keyboardType: TextInputType.text,
                            onChanged: (value) {},
                            obscureText: false,
                            TextController: _instegramController,
                          ),
                          SizedBox(height: 10),
                          CustomTextField(
                            color: activeColor,
                            hintText: 'رابط التواصل الاجتماعي موقع ويب',
                            keyboardType: TextInputType.text,
                            onChanged: (value) {},
                            obscureText: false,
                            TextController: _websiteController,
                          ),
                          SizedBox(height: 10),
                          CustomTextField(
                            color: activeColor,
                            hintText: 'العنوان',
                            keyboardType: TextInputType.text,
                            onChanged: (value) {},
                            obscureText: false,
                            TextController: _adressController,
                          ),
                          SizedBox(height: 10),
                          CustomTextField(
                            color: activeColor,
                            hintText: 'الموقع',
                            keyboardType: TextInputType.text,
                            onChanged: (value) {},
                            obscureText: false,
                            TextController: _locationController,
                          ),
                          SizedBox(height: 10),
                          CustomTextField(
                            color: activeColor,
                            hintText: 'كيف تعتقد أن عملك سيضيف قيمة إلى إيفينتس؟',
                            keyboardType: TextInputType.text,
                            onChanged: (value) {},
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
                                    .limit(1)
                                    .get()
                                    .then((QuerySnapshot querySnapshot) {
                                  if (querySnapshot.docs.isNotEmpty) {
                                    DocumentSnapshot docSnapshot = querySnapshot.docs.first;
                                    DocumentReference busTypeRef = docSnapshot.reference;
                                    businessTypeId = busTypeRef;
                                    setState(() {});
                                  }
                                });
                              }
                            },
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
                                  businessName: _commercialNameController.text,
                                  contactNumber: _contactController.text,
                                  logoUrl: imageUrls,
                                  instagramUrl: _instegramController.text,
                                  website: _websiteController.text,
                                  bio: _descriptionController.text,
                                  businessTypesId: businessTypeId,
                                  address: _adressController.text,
                                  locationUrl: _locationController.text,
                                );

                                setState(() {
                                  showSpinner = false;
                                  // Clear text fields and reset image
                                  _commercialNameController.clear();
                                  _locationController.clear();
                                  _adressController.clear();
                                  _instegramController.clear();
                                  _descriptionController.clear();
                                  _websiteController.clear();
                                  _contactController.clear();
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
            ),
          ),
        ],
      ),
    );
  }
}
