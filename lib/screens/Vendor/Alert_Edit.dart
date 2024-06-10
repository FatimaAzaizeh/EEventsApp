import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:testtapp/Alert/error.dart';
import 'package:testtapp/Alert/success.dart';
import 'package:testtapp/constants.dart';
import 'package:testtapp/models/item.dart';
import 'package:testtapp/screens/Admin/widgets_admin/TexFieldDesign.dart';
import 'package:testtapp/screens/Vendor/DropdownList.dart';

class AlertEditItem extends StatefulWidget {
  final String vendor_id;
  final String item_code;

  AlertEditItem({
    Key? key,
    required this.vendor_id,
    required this.item_code,
  }) : super(key: key);

  @override
  State<AlertEditItem> createState() => _AlertEditItemState();
}

Uint8List? fileBytes;

class _AlertEditItemState extends State<AlertEditItem> {
  final _firestore = FirebaseFirestore.instance;
  bool showSpinner = false;
  late TextEditingController ControllerDescription = TextEditingController();
  late TextEditingController ControllerName = TextEditingController();
  late TextEditingController ControllerCapacity = TextEditingController();
  late TextEditingController ControllerItemCode = TextEditingController();
  late TextEditingController ControllerPrice = TextEditingController();
  final _auth = FirebaseAuth.instance;
  late String imageUrl;
  late String fileName = "لم يتم اختيار صورة ";
  late String dropdownValue = '';
  late DocumentReference itemStatusId;

  @override
  void initState() {
    super.initState();
    getItemData(widget.item_code);
  }

  Future<void> getItemData(String itemCode) async {
    try {
      final itemSnapshot =
          await _firestore.collection('item').doc(itemCode).get();

      if (itemSnapshot.exists) {
        final data = itemSnapshot.data() as Map<String, dynamic>;
        setState(() async {
          ControllerDescription.text = data['description'] ?? '';
          ControllerName.text = data['name'] ?? '';
          ControllerCapacity.text = (data['capacity'] ?? 0).toString();
          ControllerPrice.text = (data['price'] ?? 0).toString();
          ControllerItemCode.text = (data['item_code'] ?? 0).toString();
          DocumentReference? itemStatus = itemSnapshot.get('item_status_id');
          imageUrl = (data['image_url'] ?? 0).toString();

          if (itemStatus != null) {
            DocumentSnapshot eventDocSnapshot = await itemStatus.get();
            itemStatusId = itemStatus;

            if (eventDocSnapshot.exists) {
              Map<String, dynamic> eventData =
                  eventDocSnapshot.data() as Map<String, dynamic>;
              setState(() {
                dropdownValue = eventData['description'].toString();
              });
            }
          }
        });
      }
    } catch (error) {
      print(error); // Handle error
    }
  }

  Future<void> uploadFile() async {
    setState(() {
      showSpinner = true;
    });

    try {
      final TaskSnapshot uploadTask = await FirebaseStorage.instance
          .ref('uploads/$fileName')
          .putData(fileBytes!);

      imageUrl = await uploadTask.ref.getDownloadURL();
    } catch (error) {
      print('Error uploading file: $error');
    } finally {
      setState(() {
        showSpinner = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Color.fromARGB(147, 246, 242, 239),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'تعديل المنتج',
            style: StyleTextAdmin(22, Colors.black),
          ),
          GestureDetector(
            onTap: () async {
              await deleteImageByUrl(imageUrl);
              FilePickerResult? result = await FilePicker.platform.pickFiles();
              if (result != null) {
                setState(() {
                  fileBytes = result.files.first.bytes;
                  fileName = result.files.first.name;
                });
              }
            },
            child: Container(
              width: 400,
              height: 200,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 224, 224, 224),
                borderRadius: BorderRadius.circular(8),
              ),
              child: fileBytes != null
                  ? Image.memory(
                      fileBytes!,
                      fit: BoxFit.cover,
                    )
                  : Icon(Icons.camera_alt, color: Colors.grey[700]),
            ),
          ),
          SizedBox(height: 8),
          SizedBox(width: 8),
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
            icon: Icons.description,
            ControllerTextField: ControllerDescription,
            onChanged: (value) {},
            obscureTextField: false,
            enabled: true,
          ),
          TextFieldDesign(
            Text: 'إدخال رمز المنتج',
            icon: Icons.numbers,
            ControllerTextField: ControllerItemCode,
            onChanged: (value) {},
            obscureTextField: false,
            enabled: false,
          ),
          TextFieldDesign(
            Text: 'السعر',
            icon: Icons.price_change_outlined,
            ControllerTextField: ControllerPrice,
            onChanged: (value) {},
            obscureTextField: false,
            enabled: true,
          ),
          FirestoreDropdown(
            collectionName: 'item_status',
            dropdownLabel: dropdownValue,
            onChanged: (value) {
              if (value != null) {
                FirebaseFirestore.instance
                    .collection('item_status')
                    .where('description', isEqualTo: value.toString())
                    .limit(1)
                    .get()
                    .then((QuerySnapshot querySnapshot) {
                  if (querySnapshot.docs.isNotEmpty) {
                    DocumentSnapshot docSnapshot = querySnapshot.docs.first;
                    DocumentReference itemStatusRef = docSnapshot.reference;
                    itemStatusId = itemStatusRef;
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
                if (ControllerName.text.isEmpty) {
                  ErrorAlert(
                      context, 'خطأ', 'الرجاء إدخال كل البيانات المطلوبة');
                } else {
                  await uploadFile();
                  double price = double.tryParse(ControllerPrice.text) ?? 0.0;
                  int capacity = int.tryParse(ControllerCapacity.text) ?? 0;
                  DocumentReference Vendorid = FirebaseFirestore.instance
                      .collection('vendor')
                      .doc(widget.vendor_id);

                  String result = await Item.editItemInFirestore(
                      ControllerName.text,
                      ControllerItemCode.text,
                      imageUrl,
                      ControllerDescription.text,
                      price,
                      capacity,
                      itemStatusId);

                  setState(() {
                    showSpinner = true;
                  });

                  try {
                    // Your logic for creating the product
                  } catch (error) {
                    // Handle error with specific message
                  } finally {
                    Navigator.of(context).pop();
                    if (result.contains('تعديل')) {
                      SuccessAlert(context, result);
                    } else {
                      ErrorAlert(context, 'خطأ', result);
                    }

                    setState(() {
                      showSpinner = false;
                    });
                  }
                }
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(ColorPink_100),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'تعديل المنتج  ',
                  style: StyleTextAdmin(17, Colors.white),
                ),
              ),
            ),
          ),
          if (showSpinner) CircularProgressIndicator(),
        ],
      ),
    );
  }
}
