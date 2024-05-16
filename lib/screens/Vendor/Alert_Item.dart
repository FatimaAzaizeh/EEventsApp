// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

import 'package:testtapp/constants.dart';
import 'package:testtapp/models/item.dart';
import 'package:testtapp/screens/Admin/widgets_admin/EventClassification.dart';
import 'package:testtapp/screens/Admin/widgets_admin/TexFieldDesign.dart';
import 'package:testtapp/screens/Vendor/DropdownList.dart';

class AlertItem extends StatefulWidget {
  String vendor_id;
  AlertItem({
    Key? key,
    required this.vendor_id,
  }) : super(key: key);

  @override
  State<AlertItem> createState() => _AlertItemState();
}

Uint8List? fileBytes;

class _AlertItemState extends State<AlertItem> {
  final _firestore = FirebaseFirestore.instance;
  bool showSpinner = false;
  final ControllerDescription = TextEditingController();
  final ControllerName = TextEditingController();
  final ControllerCapacity = TextEditingController();
  final ControllerItemCode = TextEditingController();
  final ControllerPrice = TextEditingController();
  final _auth = FirebaseAuth.instance;
  late String imageUrl;
  late String fileName = "لم يتم اختيار صورة ";

  late DocumentReference EventTypeId;
  late DocumentReference serviceTypeId;
  late DocumentReference eventClassificationTypeId;
  late DocumentReference itemStatusId;
  Future<void> uploadFile() async {
    setState(() {
      showSpinner = true; // Show spinner before uploading file
    });

    try {
      // Upload file to Firebase Storage
      final TaskSnapshot uploadTask = await FirebaseStorage.instance
          .ref('uploads/$fileName')
          .putData(fileBytes!);

      // Get download URL of the uploaded file
      imageUrl = await uploadTask.ref.getDownloadURL();
    } catch (error) {
      print('Error uploading file: $error');
      // Handle error with specific message
      // You can also show an alert dialog here
    } finally {
      setState(() {
        showSpinner = false; // Hide spinner after upload completes
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'إضافة منتج جديد',
            style: StyleTextAdmin(22, Colors.black),
          ),
          Row(
            children: [
              TextButton(
                onPressed: () async {
                  FilePickerResult? result =
                      await FilePicker.platform.pickFiles();
                  if (result != null) {
                    setState(() {
                      fileBytes = result.files.first.bytes;
                      fileName = result.files.first.name;
                    });
                  }
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Tooltip(
                      message: 'إضافة صورة',
                      child: Icon(
                        Icons.add,
                        size: 34,
                        color: ColorPurple_100,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      fileName,
                      style: StyleTextAdmin(
                        18,
                        fileBytes != null ? ColorPurple_100 : Colors.grey,
                      ),
                    ),
                  ],
                ),
              )
            ],
          )
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFieldDesign(
            Text: 'إدخال إسم المنتج',
            icon: Icons.info_rounded,
            ControllerTextField: ControllerName,
            onChanged: (value) {},
            obscureTextField: false,
            enabled: true,
          ),
          TextFieldDesign(
            Text: 'إدخال وصف المنتج',
            icon: Icons.account_circle,
            ControllerTextField: ControllerDescription,
            onChanged: (value) {},
            obscureTextField: false,
            enabled: true,
          ),
          TextFieldDesign(
            Text: 'إدخال رمز المنتج',
            icon: Icons.account_circle,
            ControllerTextField: ControllerItemCode,
            onChanged: (value) {},
            obscureTextField: false,
            enabled: true,
          ),
          TextFieldDesign(
            Text: 'السعر',
            icon: Icons.account_circle,
            ControllerTextField: ControllerPrice,
            onChanged: (value) {},
            obscureTextField: false,
            enabled: true,
          ),

          // Other TextFields...

          FirestoreDropdown(
            dropdownLabel: 'نوع الحدث',
            collectionName: 'event_types',
            onChanged: (value) {
              if (value != null) {
                FirebaseFirestore.instance
                    .collection('event_types')
                    .where('name', isEqualTo: value.toString())
                    .limit(
                        1) // Limiting to one document as 'where' query might return multiple documents
                    .get()
                    .then((QuerySnapshot querySnapshot) {
                  if (querySnapshot.docs.isNotEmpty) {
                    // If document(s) found, assign the reference
                    DocumentSnapshot docSnapshot = querySnapshot.docs.first;
                    DocumentReference EventTypeRef = docSnapshot.reference;
                    EventTypeId = EventTypeRef;
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
                    DocumentSnapshot docSnapshot = querySnapshot.docs.first;
                    DocumentReference ServiceRef = docSnapshot.reference;
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
          FirestoreDropdown(
            collectionName: 'event_classificaion_types',
            dropdownLabel: 'تصنيف الحدث',
            onChanged: (value) {
              if (value != null) {
                FirebaseFirestore.instance
                    .collection('event_classificaion_types')
                    .where('description', isEqualTo: value.toString())
                    .limit(
                        1) // Limiting to one document as 'where' query might return multiple documents
                    .get()
                    .then((QuerySnapshot querySnapshot) {
                  if (querySnapshot.docs.isNotEmpty) {
                    // If document(s) found, assign the reference
                    DocumentSnapshot docSnapshot = querySnapshot.docs.first;
                    DocumentReference EventRef = docSnapshot.reference;
                    eventClassificationTypeId = EventRef;
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
          FirestoreDropdown(
            collectionName: 'item_status',
            dropdownLabel: 'حالة المنتج',
            onChanged: (value) {
              if (value != null) {
                FirebaseFirestore.instance
                    .collection('item_status')
                    .where('description', isEqualTo: value.toString())
                    .limit(
                        1) // Limiting to one document as 'where' query might return multiple documents
                    .get()
                    .then((QuerySnapshot querySnapshot) {
                  if (querySnapshot.docs.isNotEmpty) {
                    // If document(s) found, assign the reference
                    DocumentSnapshot docSnapshot = querySnapshot.docs.first;
                    DocumentReference itemStatusRef = docSnapshot.reference;
                    itemStatusId = itemStatusRef;
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

          SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () async {
                if (ControllerName.text.isEmpty || fileBytes == null) {
                  // Show an alert if any required field is empty
                  QuickAlert.show(
                    context: context,
                    title: 'خطأ',
                    text: 'الرجاء إدخال كل البيانات المطلوبة',
                    type: QuickAlertType.error,
                    confirmBtnText: 'حسناً',
                  );
                } else {
                  await uploadFile(); // Upload file before creating user
                  double price = double.tryParse(ControllerPrice.text) ?? 0.0;
                  int capacity = int.tryParse(ControllerCapacity.text) ?? 0;
                  Timestamp myTimestamp = Timestamp.now();
                  DocumentReference Vendorid = FirebaseFirestore.instance
                      .collection('vendor')
                      .doc(widget.vendor_id);

                  Item newitem = Item(
                      vendorId: Vendorid,
                      name: ControllerName.text,
                      itemCode: ControllerItemCode.text,
                      imageUrl: imageUrl,
                      description: ControllerDescription.text,
                      price: price,
                      capacity: capacity,
                      eventTypeId: EventTypeId,
                      serviceTypeId: serviceTypeId,
                      eventClassificationTypeId: eventClassificationTypeId,
                      itemStatusId: itemStatusId,
                      createdAt: myTimestamp);
                  newitem.addItemToFirestore();

                  setState(() {
                    showSpinner = true; // Show spinner while creating user
                  });

                  try {
                    // Your logic for creating the product
                  } catch (error) {
                    // Handle error with specific message
                    // You can also show an alert dialog here
                  } finally {
                    // Close only the current dialog
                    Navigator.of(context).pop();

                    // Show QuickAlert dialog after user creation
                    QuickAlert.show(
                      context: context,
                      customAsset: 'assets/images/Completionanimation.gif',
                      width: 300,
                      type: QuickAlertType.success,
                      confirmBtnText: 'إغلاق',
                    );

                    setState(() {
                      showSpinner = false; // Hide spinner after user creation
                    });
                  }
                }
              },
              style: const ButtonStyle(
                animationDuration: Durations.long3,
                backgroundColor: MaterialStatePropertyAll(Colors.black),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'إنشاء منتج  ',
                  style: StyleTextAdmin(17, Colors.white),
                ),
              ),
            ),
          ),
          if (showSpinner)
            CircularProgressIndicator(), // Show spinner when uploading file or creating user
        ],
      ),
    );
  }
}
