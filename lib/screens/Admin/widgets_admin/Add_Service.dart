import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:testtapp/Alert/error.dart';
import 'package:testtapp/Alert/success.dart';

// Your imports
import 'package:testtapp/constants.dart';
import 'package:testtapp/models/FirestoreService.dart';
import 'package:testtapp/models/ServiceType.dart';
import 'package:testtapp/screens/Admin/widgets_admin/serviceItem.dart';

final _firestore = FirebaseFirestore.instance;

class AddService extends StatefulWidget {
  static const String screenRoute = 'Add_Service';
  const AddService({Key? key}) : super(key: key);

  @override
  State<AddService> createState() => _AddServiceState();
}

class _AddServiceState extends State<AddService> {
  late String imageUrl;
  Uint8List? fileBytes;
  String fileName = "لم يتم اختيار صورة ";
  TextEditingController ControllerName = TextEditingController();
  TextEditingController ControllerImage = TextEditingController();
  TextEditingController ControllerId = TextEditingController();
  bool showEditButton = false;
  late String name; // Name of the Event

  bool showSpinner = false;
  String dropdownValue = '';
  List<String> classificationList = []; // Initialize classification list
  late String id;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                  color:
                      const Color.fromARGB(165, 255, 255, 255).withOpacity(0.3),
                  width: 3),
              borderRadius: BorderRadius.circular(20),
              color: const Color.fromARGB(6, 255, 255, 255).withOpacity(0.22),
            ),
            width: MediaQuery.sizeOf(context).width * 0.33,
            height: double.maxFinite,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('الخدمات', style: StyleTextAdmin(20, AdminButton)),
                      Row(
                        children: [
                          TextButton(
                            onPressed: showEditButton
                                ? () async {
                                    if (ControllerName.text.isNotEmpty) {
                                      if (fileName !=
                                          "لتغيير الصورة , انقر هنا.") {
                                        await deleteImageByUrl(imageUrl);
                                        await uploadFile();
                                      }
                                      bool result = await ServiceType
                                          .updateServiceFirestore(
                                              ControllerName.text,
                                              imageUrl,
                                              ControllerId.text);

                                      setState(() {
                                        showEditButton = false;
                                      });

                                      if (result) {
                                        ControllerName.clear();
                                        ControllerId.clear();
                                        fileName = "لم يتم اختيار صورة";
                                        fileBytes = null;
                                        SuccessAlert(
                                            context, 'تم تعديل الخدمة بنجاح');
                                      } else {
                                        ErrorAlert(context, 'خطأ',
                                            'حدث خطأ, لم يتم تعديل الحدمة ');
                                      }
                                      setState(() {
                                        showEditButton = false;
                                      });
                                    } else {
                                      ErrorAlert(context, 'خطأ',
                                          'الرجاء إدخال كل البيانات المطلوبة');
                                    }
                                  }
                                : null,
                            child: Icon(Icons.edit),
                          ),
                          TextButton(
                            onPressed: showEditButton
                                ? () {
                                    setState(() {
                                      ControllerName.clear();
                                      ControllerId.clear();
                                      ControllerImage.clear();
                                      fileName = "لم يتم اختيار صورة";
                                      showEditButton = false;
                                    });
                                  }
                                : null,
                            child: Icon(Icons.clear),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'أسم الخدمة:',
                    icon: Icon(Icons.title),
                    labelStyle: StyleTextAdmin(14, AdminButton),
                  ),
                  controller: ControllerName,
                  onChanged: (value) {
                    name = value; // Update the Name variable
                    // Update the serviceType list
                  },
                ),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'يتم تعيين رقم معرّف الخدمة تلقائيًا',
                    icon: Icon(Icons.room_service),
                    labelStyle:
                        StyleTextAdmin(14, AdminButton.withOpacity(0.55)),
                  ),
                  controller: ControllerId,
                  onChanged: (value) {
                    value;
                  },
                  enabled: false,
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
                          Container(
                            width: 200,
                            child: Text(fileName,
                                style: StyleTextAdmin(
                                  18,

                                  fileBytes != null
                                      ? ColorPurple_100 // Set color to ColorPurple_100 if fileBytes is not null
                                      : Colors
                                          .grey, // Otherwise, set color to grey
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis
                                // Apply ellipsis if fileName is longer than 20 characters
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    width: 200,
                    margin: EdgeInsets.only(bottom: 90),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: const Color.fromARGB(165, 255, 255, 255)
                              .withOpacity(0.3),
                          width: 2),
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
                            child: Text('إضافة خدمة',
                                style: StyleTextAdmin(16, AdminButton)),
                            onPressed: () async {
                              setState(() {
                                showSpinner = true;
                              });
                              if (ControllerName.text.isNotEmpty &&
                                  ControllerImage.text.isNotEmpty) {
                                await uploadFile();
                                int count =
                                    await FirestoreService.getCountOfRecords(
                                        'service_types');
                                int id = count + 1;
                                ServiceType newservice = ServiceType(
                                  id: id.toString(),
                                  name: ControllerName.text,
                                  imageUrl: imageUrl,
                                );
                                String result =
                                    await newservice.saveToDatabase();
                                setState(() {
                                  showSpinner = false;
                                });

                                if (result == 'تم إضافة الخدمة بنجاح') {
                                  ControllerName.clear();
                                  ControllerId.clear();
                                  ControllerImage.clear();
                                  fileName = "لم يتم اختيار صورة";
                                  fileBytes = null;
                                  SuccessAlert(context, result);
                                } else {
                                  ErrorAlert(context, 'خطأ', result);
                                }
                              } else {
                                setState(() {
                                  showSpinner =
                                      false; // Set showSpinner to false after processing is done
                                });
                                ErrorAlert(context, 'خطأ',
                                    'الرجاء إدخال كل البيانات المطلوبة');
                              }
                            },
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: 430,
            height: double.maxFinite,
            child: ServiceScreen(),
          ),
        ),
      ],
    );
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
      ControllerImage.text = imageUrl;
    } catch (error) {
      print('Error uploading file: $error');
    } finally {
      setState(() {
        showSpinner = false;
      });
    }
  }

  Future<void> getDataById(String documentId) async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection("service_types")
        .doc(documentId)
        .get();

    // Now you can update other UI elements outside setState
    setState(() {
      imageUrl = snapshot.get('image_url');
      ControllerName.text = snapshot.get('name');
      ControllerId.text = snapshot.get('id');
      showEditButton = true;
      fileName = "لتغيير الصورة , انقر هنا.";
    });
  }

  SafeArea ServiceScreen() {
    return SafeArea(
      child: Material(
        color: ColorPink_20,
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('service_types')
              .orderBy('id')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              final eventDocs = snapshot.data!.docs;
              return GridView.builder(
                padding: EdgeInsets.all(4),
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent:
                      191, // Adjust according to your requirement
                  childAspectRatio: 1, // Ensure each item is square
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                itemCount: eventDocs.length,
                itemBuilder: (context, index) {
                  final doc = eventDocs[index];
                  return ServiceItem(
                    imageUrl: doc['image_url'].toString(),
                    id: doc.id,
                    onTapFunction: () {
                      getDataById(doc.id);
                    },
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
