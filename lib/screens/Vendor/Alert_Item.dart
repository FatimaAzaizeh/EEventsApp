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
  final String vendorId;

  AlertItem({
    Key? key,
    required this.vendorId,
  }) : super(key: key);

  @override
  State<AlertItem> createState() => _AlertItemState();
}

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
  late DocumentReference eventTypeId;
  late DocumentReference itemStatusId;
  Uint8List? fileBytes;

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
        content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Container(
              width: 400,
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'إضافة منتج جديد',
                    style: StyleTextAdmin(22, Colors.black),
                  ),
                  SizedBox(height: 16),
                  Container(
                    height: 150,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (fileBytes != null)
                          Image.memory(
                            fileBytes!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        if (fileBytes == null)
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.photo, size: 50, color: Colors.grey),
                              SizedBox(height: 8),
                              Text('No photo'),
                            ],
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
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
                  ),
                  SizedBox(height: 16),
                  Column(
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
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'capacity',
                          hintText: '',
                        ),
                        controller: ControllerCapacity,
                      ),
                      FirestoreDropdown(
                        dropdownLabel: 'نوع الحدث',
                        collectionName: 'event_types',
                        onChanged: (value) {
                          if (value != null) {
                            FirebaseFirestore.instance
                                .collection('event_types')
                                .where('name', isEqualTo: value.toString())
                                .limit(1)
                                .get()
                                .then((QuerySnapshot querySnapshot) {
                              if (querySnapshot.docs.isNotEmpty) {
                                DocumentSnapshot docSnapshot =
                                    querySnapshot.docs.first;
                                DocumentReference EventTypeRef =
                                    docSnapshot.reference;
                                eventTypeId = EventTypeRef;
                                setState(() {});
                              } else {
                                // Handle no document found
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
                                .where('description',
                                    isEqualTo: value.toString())
                                .limit(1)
                                .get()
                                .then((QuerySnapshot querySnapshot) {
                              if (querySnapshot.docs.isNotEmpty) {
                                DocumentSnapshot docSnapshot =
                                    querySnapshot.docs.first;
                                DocumentReference itemStatusRef =
                                    docSnapshot.reference;
                                itemStatusId = itemStatusRef;
                                setState(() {});
                              } else {
                                // Handle no document found
                              }
                            });
                          }
                        },
                      ),
                      SizedBox(height: 8),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          setState(() {
                            showSpinner = true;
                          });

                          if (ControllerName.text.isEmpty ||
                              fileBytes == null) {
                            QuickAlert.show(
                              context: context,
                              title: 'خطأ',
                              text: 'الرجاء إدخال كل البيانات المطلوبة',
                              type: QuickAlertType.error,
                              confirmBtnText: 'حسناً',
                            );
                          } else {
                            await uploadFile();
                            double price =
                                double.tryParse(ControllerPrice.text) ?? 0.0;
                            int capacity =
                                int.tryParse(ControllerCapacity.text) ?? 0;
                            Timestamp myTimestamp = Timestamp.now();
                            DocumentSnapshot vendorSnapshot =
                                await FirebaseFirestore.instance
                                    .collection('vendor')
                                    .doc(widget.vendorId)
                                    .get();
                            DocumentReference Vendorid = FirebaseFirestore
                                .instance
                                .collection('vendor')
                                .doc(widget.vendorId);
                            DocumentReference serviceTypeId =
                                vendorSnapshot.get('service_types_id');

                            Item newitem = Item(
                              vendorId: Vendorid,
                              name: ControllerName.text,
                              itemCode: ControllerItemCode.text,
                              imageUrl: imageUrl,
                              description: ControllerDescription.text,
                              price: price,
                              capacity:
                                  int.tryParse(ControllerCapacity.text) ?? 0,
                              eventTypeId: eventTypeId,
                              serviceTypeId: serviceTypeId,
                              itemStatusId: itemStatusId,
                              createdAt: myTimestamp,
                            );
                            newitem.addItemToFirestore();

                            // إعادة ضبط قيمة showSpinner بعد الانتهاء من العمليات
                            setState(() {
                              showSpinner = false;
                            });

                            // عرض الرسالة بنجاح وإغلاق النافذة بعد ذلك
                            Navigator.of(context).pop();
                            QuickAlert.show(
                              context: context,
                              customAsset:
                                  'assets/images/Completionanimation.gif',
                              width: 300,
                              type: QuickAlertType.success,
                              confirmBtnText: 'إغلاق',
                            );
                          }
                        },
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.black),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'إنشاء منتج  ',
                            style: StyleTextAdmin(17, Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ));
  }
}
