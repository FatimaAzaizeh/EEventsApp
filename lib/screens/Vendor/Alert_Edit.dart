import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
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

class _AlertEditItemState extends State<AlertEditItem> {
  final _firestore = FirebaseFirestore.instance;
  bool showSpinner = false;
  late TextEditingController ControllerDescription;
  late TextEditingController ControllerName;
  late TextEditingController ControllerCapacity;
  late TextEditingController ControllerItemCode;
  late TextEditingController ControllerPrice;
  late String imageUrl = '';
  late String fileName = "لم يتم اختيار صورة ";
  late String dropdownValue = '';
  late String dropdownValueEvent = '';
  late DocumentReference itemStatusId;
  late DocumentReference itemEventId;
  Uint8List? fileBytes;

  @override
  void initState() {
    super.initState();
    ControllerDescription = TextEditingController();
    ControllerName = TextEditingController();
    ControllerCapacity = TextEditingController();
    ControllerItemCode = TextEditingController();
    ControllerPrice = TextEditingController();
    getItemData(widget.item_code);
  }

  @override
  void dispose() {
    ControllerDescription.dispose();
    ControllerName.dispose();
    ControllerCapacity.dispose();
    ControllerItemCode.dispose();
    ControllerPrice.dispose();
    super.dispose();
  }

  Future<void> getItemData(String itemCode) async {
    try {
      final itemSnapshot =
          await _firestore.collection('item').doc(itemCode).get();

      if (itemSnapshot.exists) {
        final data = itemSnapshot.data() as Map<String, dynamic>;

        // Fetch item status and event details before calling setState
        DocumentReference? itemStatus = itemSnapshot.get('item_status_id');
        DocumentReference? item_event = itemSnapshot.get('event_type_id');
        DocumentSnapshot? eventDocSnapshot;
        DocumentSnapshot? eventIdSnapshot;

        if (itemStatus != null) {
          eventDocSnapshot = await itemStatus.get();
        }

        if (item_event != null) {
          eventIdSnapshot = await item_event.get();
        }

        setState(() {
          ControllerDescription.text = data['description'] ?? '';
          ControllerName.text = data['name'] ?? '';
          ControllerCapacity.text = (data['capacity'] ?? 0).toString();
          ControllerPrice.text = (data['price'] ?? 0).toString();
          ControllerItemCode.text = (data['item_code'] ?? 0).toString();
          imageUrl = (data['image_url'] ?? '').toString();

          if (eventDocSnapshot != null && eventDocSnapshot.exists) {
            final eventData = eventDocSnapshot.data() as Map<String, dynamic>;
            dropdownValue = eventData['description'].toString();
          }

          if (eventIdSnapshot != null && eventIdSnapshot.exists) {
            final eventIdData = eventIdSnapshot.data() as Map<String, dynamic>;
            dropdownValueEvent = eventIdData['name'];
          }
          itemEventId = item_event!;
          itemStatusId = itemStatus!;
        });
      }
    } catch (e) {
      // Handle the error
      print(e);
    }
  }

//upload an image to Firebase Storage.
  Future<void> uploadFile() async {
    if (fileBytes == null) return;

    setState(() {
      showSpinner = true;
    });

    try {
      // Upload file to Firebase Storage under 'uploads/$fileName' path
      final TaskSnapshot uploadTask = await FirebaseStorage.instance
          .ref('uploads/$fileName')
          .putData(fileBytes!);
      // Get download URL of the uploaded file
      imageUrl = await uploadTask.ref.getDownloadURL();
    } catch (error) {
      print('Error uploading file: $error');
      // Handle error here
    } finally {
      setState(() {
        showSpinner = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Color.fromARGB(255, 246, 242, 239),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "تعديل المنتج / الخدمة",
              style: StyleTextAdmin(22, Colors.black),
            ),
          ),
          GestureDetector(
            onTap: () async {
              await chooseNewImage();
            },
            child: Container(
              width: 200,
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
                  : imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                        )
                      : Icon(Icons.camera_alt, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
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
              collectionName: 'event_types',
              dropdownLabel: dropdownValueEvent,
              onChanged: (value) {
                FirebaseFirestore.instance
                    .collection('event_types')
                    .where('name', isEqualTo: value.toString())
                    .limit(1)
                    .get()
                    .then((QuerySnapshot querySnapshot) {
                  if (querySnapshot.docs.isNotEmpty) {
                    DocumentSnapshot docSnapshot = querySnapshot.docs.first;
                    DocumentReference itemEvent_Id = docSnapshot.reference;
                    itemEventId = itemEvent_Id;
                  }
                });
              },
            ),
            FirestoreDropdown(
              collectionName: 'item_status',
              dropdownLabel: dropdownValue,
              onChanged: (value) {
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
                    setState(() {
                      showSpinner = true;
                    });
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
                        itemStatusId,
                        itemEventId);

                    try {
                      // Your logic for creating the product
                    } catch (error) {
                      // Handle error with specific message
                    } finally {
                      setState(() {
                        showSpinner = false;
                      });
                      Navigator.of(context).pop();
                      if (result.contains('تعديل')) {
                        SuccessAlert(context, result);
                      } else {
                        ErrorAlert(context, 'خطأ', result);
                      }
                    }
                  }
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(ColorPink_100),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "تعديل المنتج / الخدمة",
                    style: StyleTextAdmin(17, Colors.white),
                  ),
                ),
              ),
            ),
            if (showSpinner) CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }

  Future<void> chooseNewImage() async {
    await deleteImageByUrl(imageUrl);
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        fileBytes = result.files.first.bytes;
        fileName = result.files.first.name;
        imageUrl = ''; // Clear the old imageUrl
      });
    }
  }
}
