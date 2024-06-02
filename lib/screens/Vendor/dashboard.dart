import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:testtapp/constants.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  String userEmail = "email";
  String serviceName = '';
  String fileName = '';
  String imageUrls = '';
  bool showSpinner = false;
  Uint8List? fileBytes;

  final TextEditingController _commercialNameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _instagramController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  late DocumentReference businessTypeId;
  late DocumentReference serviceTypeId;

  @override
  void initState() {
    super.initState();
    _fetchVendorData();
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
      _instagramController.text = vendorSnapshot['instagram_url'];
      _descriptionController.text = vendorSnapshot['bio'];
      _addressController.text = vendorSnapshot['address'];
      _locationController.text = vendorSnapshot['location_url'];
      imageUrls = vendorSnapshot['logo_url'];
      serviceName = serviceTypesSnapshot['name'];
      userEmail = vendorSnapshot['email']; // Fetch and set the email
    });
  }

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        showSpinner = true;
        fileName = result.files.first.name!;
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
      });
    }
  }

  Future<void> _saveVendorData() async {
    setState(() {
      showSpinner = true;
    });

    try {
      await Vendor.edit(
        UID: FirebaseAuth.instance.currentUser!.uid,
        businessName: _commercialNameController.text,
        contactNumber: _contactController.text,
        logoUrl: imageUrls,
        instagramUrl: _instagramController.text,
        website: _websiteController.text,
        bio: _descriptionController.text,
        businessTypesId: businessTypeId,
        address: _addressController.text,
        locationUrl: _locationController.text,
      );

      setState(() {
        showSpinner = false;
        // Clear text fields and reset image
        _commercialNameController.clear();
        _locationController.clear();
        _addressController.clear();
        _instagramController.clear();
        _descriptionController.clear();

        fileBytes = null; // Reset picked image
      });
    } catch (e) {
      print(e);
      setState(() {
        showSpinner = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Stack(
          children: [
            // Background image
            Positioned.fill(
              child: Image.asset(
                "assets/images/signin.png",
                fit: BoxFit.cover,
              ),
            ),
            // Main content
            Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        ProfileHeader(
                          userEmail: userEmail,
                          imageUrls: imageUrls,
                          commercialNameController: _commercialNameController,
                          pickImage: _pickImage,
                          fileBytes: fileBytes,
                        ),
                        ExperienceSection(
                          contactController: _contactController,
                          instagramController: _instagramController,
                          websiteController: _websiteController,
                          addressController: _addressController,
                          locationController: _locationController,
                          descriptionController: _descriptionController,
                          serviceName: serviceName,
                          fileName: fileName,
                          saveVendorData: _saveVendorData,
                          setBusinessTypeId: (ref) => businessTypeId = ref,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileHeader extends StatelessWidget {
  final String userEmail;
  final String imageUrls;
  final TextEditingController commercialNameController;
  final VoidCallback pickImage;
  final Uint8List? fileBytes;

  ProfileHeader({
    required this.userEmail,
    required this.imageUrls,
    required this.commercialNameController,
    required this.pickImage,
    required this.fileBytes,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(41, 237, 194, 191),
            Color.fromARGB(5, 230, 202, 232),
          ], // Two colors for the gradient
          begin: Alignment.topLeft, // Start position of the gradient
          end: Alignment.bottomRight, // End position of the gradient
        ),
        border: Border.all(
          color: const Color.fromARGB(16, 158, 158, 158), // Border color
          width: 2.0, // Border width
        ),
        borderRadius: BorderRadius.circular(10), // Rounded corners
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: fileBytes != null
                    ? MemoryImage(fileBytes!)
                    : NetworkImage(imageUrls.isEmpty
                        ? 'https://via.placeholder.com/150'
                        : imageUrls) as ImageProvider,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: pickImage,
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
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                commercialNameController.text.isEmpty
                    ? 'user name'
                    : commercialNameController.text,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                userEmail,
                style: TextStyle(color:Colors.black, fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ExperienceSection extends StatefulWidget {
  final TextEditingController contactController;
  final TextEditingController instagramController;
  final TextEditingController websiteController;
  final TextEditingController addressController;
  final TextEditingController locationController;
  final TextEditingController descriptionController;
  final String serviceName;
  final String fileName;
  final VoidCallback saveVendorData;
  final ValueChanged<DocumentReference> setBusinessTypeId;

  ExperienceSection({
    required this.contactController,
    required this.instagramController,
    required this.websiteController,
    required this.addressController,
    required this.locationController,
    required this.descriptionController,
    required this.serviceName,
    required this.fileName,
    required this.saveVendorData,
    required this.setBusinessTypeId,
  });

  @override
  _ExperienceSectionState createState() => _ExperienceSectionState();
}

class _ExperienceSectionState extends State<ExperienceSection> {
  String _selectedItem = 'متاح';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 900, // Adjust the width as needed
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color.fromARGB(55, 245, 234, 222),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Color.fromARGB(17, 228, 224, 224).withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'معلومات البائع',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: activeColor),
            ),
            SizedBox(height: 16),
            TextField(
              controller: widget.contactController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'رقم الهاتف',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              enabled: false, // Set to false to make it read-only
            ),
            SizedBox(height: 10),
            TextField(
              controller: widget.instagramController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                labelText: 'رابط التواصل الاجتماعي الانستغرام',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              enabled: false, // Set to false to make it read-only
            ),
            SizedBox(height: 10),
            TextField(
              controller: widget.websiteController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                labelText: 'رابط التواصل الاجتماعي موقع ويب',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              enabled: false, // Set to false to make it read-only
            ),
            SizedBox(height: 10),
            TextField(
              controller: widget.addressController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                labelText: 'العنوان',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              enabled: false, // Set to false to make it read-only
            ),
            SizedBox(height: 10),
            TextField(
              controller: widget.locationController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                labelText: 'الموقع',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              enabled: false, // Set to false to make it read-only
            ),
            SizedBox(height: 10),
            TextField(
              controller: widget.descriptionController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                labelText: 'كيف تعتقد أن عملك سيضيف قيمة إلى إيفينتس؟',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              enabled: false, // Set to false to make it read-only
            ),
            SizedBox(height: 10),
            Text('Service Name: ${widget.serviceName}'),
            SizedBox(height: 10),
            FirestoreDropdown(
              collectionName: 'business_types',
              dropdownLabel: 'نوع المتجر',
              onChanged: (value) {
                if (value != null) {
                  FirebaseFirestore.instance
                      .collection("business_types")
                      .where('description', isEqualTo: value.toString())
                      .limit(1) // Limiting to one document as 'where' query might return multiple documents
                      .get()
                      .then((QuerySnapshot querySnapshot) {
                    if (querySnapshot.docs.isNotEmpty) {
                      // If document(s) found, assign the reference
                      DocumentSnapshot docSnapshot = querySnapshot.docs.first;
                      DocumentReference bussTyoeRef = docSnapshot.reference;
                      widget.setBusinessTypeId(bussTyoeRef);
                    }
                  });
                }
              },
            ),
            SizedBox(height: 8),
            DropdownButton<String>(
              value: _selectedItem,
              onChanged: (String? newValue) async {
                setState(() {
                  _selectedItem = newValue!;
                });

                try {
                  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
                      .collection('users')
                      .where('UID', isEqualTo: FirebaseAuth.instance.currentUser!.uid.toString())
                      .get();

                  if (querySnapshot.docs.isNotEmpty) {
                    DocumentSnapshot userSnapshot = querySnapshot.docs.first;
                    await userSnapshot.reference.update({'isAvailable': newValue});
                  }
                } catch (e) {
                  print(e);
                }
              },
              items: <String>['متاح', 'غير متاح'].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: widget.saveVendorData,
                  child: Text('حفظ التغييرات'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class FirestoreDropdown extends StatefulWidget {
  final String collectionName;
  final String dropdownLabel;
  final ValueChanged<String?> onChanged;
  

  const FirestoreDropdown({
    required this.collectionName,
    required this.dropdownLabel,
    required this.onChanged,
  });

  @override
  _FirestoreDropdownState createState() => _FirestoreDropdownState();
}

class _FirestoreDropdownState extends State<FirestoreDropdown> {
  String? _selectedValue;
  List<DropdownMenuItem<String>> _dropdownItems = [];

  @override
  void initState() {
    super.initState();
    _fetchDropdownItems();
  }

  Future<void> _fetchDropdownItems() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection(widget.collectionName).get();

      setState(() {
        _dropdownItems = querySnapshot.docs
            .map((doc) => DropdownMenuItem<String>(
                  value: doc['description'],
                  child: Text(doc['description']),
                ))
            .toList();
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.dropdownLabel,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        DropdownButton<String>(
          value: _selectedValue,
          onChanged: (String? newValue) {
            setState(() {
              _selectedValue = newValue;
            });
            widget.onChanged(newValue);
          },
          items: _dropdownItems,
          hint: Text('اختر نوع المتجر'),
          isExpanded: true,
        ),
      ],
    );
  }
}

class Vendor {
  static Future<void> edit({
    required String UID,
    required String businessName,
    required String contactNumber,
    required String logoUrl,
    required String instagramUrl,
    required String website,
    required String bio,
    required DocumentReference businessTypesId,
    required String address,
    required String locationUrl,
  }) async {
    await FirebaseFirestore.instance.collection('vendor').doc(UID).update({
      'business_name': businessName,
      'contact_number': contactNumber,
      'logo_url': logoUrl,
      'instagram_url': instagramUrl,
      'website': website,
      'bio': bio,
      'business_types_id': businessTypesId,
      'address': address,
      'location_url': locationUrl,
    });
  }
}

