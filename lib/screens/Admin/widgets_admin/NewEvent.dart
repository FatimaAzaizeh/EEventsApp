import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:testtapp/Alert/error.dart';
import 'package:testtapp/Alert/success.dart';
import 'package:testtapp/constants.dart';
import 'package:testtapp/models/EventType.dart';
import 'package:testtapp/models/FirestoreService.dart';
import 'package:testtapp/screens/Admin/widgets_admin/TexFieldDesign.dart';
import 'package:testtapp/widgets/Event_item.dart';

class AddEvent extends StatefulWidget {
  static const String screenRoute = 'NewEvent';
  const AddEvent({Key? key}) : super(key: key);

  @override
  State<AddEvent> createState() => _AddEventState();
}

class _AddEventState extends State<AddEvent> {
  late String imageUrl;
  Uint8List? fileBytes;
  late String fileName = "لم يتم اختيار صورة";
  var controllerName = TextEditingController();
  var controllerImage = TextEditingController();
  late DocumentReference eventClassificationRef;
  var controllerId = TextEditingController();

  bool editButton = false;
  List<String> classificationList = [];
  late String name;
  bool showSpinner = false;
  late String dropdownValue;

  @override
  void initState() {
    super.initState();
    fetchClassificationsFromFirestore();
  }

  void fetchClassificationsFromFirestore() async {
    final _firestore = FirebaseFirestore.instance;
    try {
      setState(() {
        showSpinner = true;
      });
      QuerySnapshot querySnapshot =
          await _firestore.collection("event_classificaion_types").get();

      setState(() {
        classificationList.clear();
      });

      for (var docSnapshot in querySnapshot.docs) {
        classificationList.add(docSnapshot.get('description').toString());
      }
      setState(() {
        eventClassificationRef = querySnapshot.docs[0].reference;
        dropdownValue = classificationList.first;
        showSpinner = false;
      });
    } catch (e) {
      print("Error fetching classifications: $e");
      setState(() {
        showSpinner = false;
      });
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
      controllerImage.text = imageUrl;
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
            width: 500,
            height: double.maxFinite,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('المناسبات',
                          textAlign: TextAlign.center,
                          style: StyleTextAdmin(20, AdminButton)),
                      Row(
                        children: [
                          IconButton(
                            onPressed: editButton
                                ? () async {
                                    if (controllerName.text.isNotEmpty) {
                                      if (fileName !=
                                          "لتغيير الصورة , انقر هنا.") {
                                        deleteImageByUrl(imageUrl);
                                        await uploadFile();
                                      }
                                      Future<bool> editEnent =
                                          EventType.updateEventTypeFirestore(
                                              controllerName.text,
                                              imageUrl,
                                              eventClassificationRef,
                                              controllerId.text);
                                      setState(() {
                                        editButton = false;
                                      });

                                      if (await editEnent) {
                                        controllerName.clear();
                                        controllerId.clear();
                                        controllerImage.clear();
                                        fileName = "لم يتم اختيار صورة";
                                        fileBytes = null;
                                        SuccessAlert(
                                            context, 'تم تعديل المناسبة بنجاح');
                                      } else {
                                        ErrorAlert(context, 'خطأ',
                                            'حدث خطأ, لم يتم تعديل المناسبة ');
                                      }
                                    } else {
                                      ErrorAlert(context, 'خطأ',
                                          'الرجاء إدخال كل البيانات المطلوبة');
                                    }
                                  }
                                : null, // Set onPressed to null when editButton is false
                            icon: Icon(Icons.edit),
                          ),
                          TextButton(
                            onPressed: editButton
                                ? () {
                                    setState(() {
                                      controllerName.clear();
                                      controllerId.clear();
                                      controllerImage.clear();
                                      editButton = false;
                                      fileName = "لم يتم اختيار صورة";
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
                TextFieldDesign(
                  Text: 'أسم المناسبة:',
                  icon: Icons.title,
                  ControllerTextField: controllerName,
                  onChanged: (value) {
                    name = value;
                  },
                  obscureTextField: false,
                  enabled: true,
                ),
                TextFieldDesign(
                  enabled: false,
                  Text: 'يتم تعيين رقم معرّف المناسبة تلقائيًا.',
                  icon: Icons.room_service,
                  ControllerTextField: controllerId,
                  onChanged: (value) {},
                  obscureTextField: false,
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
                Center(
                  child: DropdownButton<String>(
                    value: classificationList.isNotEmpty ? dropdownValue : null,
                    icon: const Icon(Icons.arrow_downward),
                    elevation: 16,
                    style: StyleTextAdmin(14, AdminButton),
                    underline: Container(
                      height: 2,
                      color: ColorPurple_100,
                    ),
                    onChanged: (String? value) async {
                      if (value != null) {
                        setState(() {
                          dropdownValue = value;
                        });

                        QuerySnapshot querySnapshot = await FirebaseFirestore
                            .instance
                            .collection('event_classificaion_types')
                            .where('description', isEqualTo: value)
                            .get();

                        if (querySnapshot.docs.isNotEmpty) {
                          setState(() {
                            eventClassificationRef =
                                querySnapshot.docs[0].reference;
                          });
                        } else {
                          // Handle the case where no documents match the query
                          // Optionally, show a message or take other actions
                        }
                      }
                    },
                    items: classificationList
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
                Container(
                  width: 200,
                  margin: EdgeInsets.only(bottom: 90),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color.fromARGB(165, 255, 255, 255)
                          .withOpacity(0.3),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white.withOpacity(0.3),
                  ),
                  child: TextButton(
                    child: showSpinner
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'إضافة مناسبة',
                            style: StyleTextAdmin(16, AdminButton),
                          ),
                    onPressed: () async {
                      setState(() {
                        showSpinner =
                            true; // Set showSpinner to true when button is pressed
                      });
                      if (controllerName.text.isNotEmpty &&
                          controllerImage.text.isNotEmpty) {
                        await uploadFile();
                        int count = await FirestoreService.getCountOfRecords(
                            'event_types');
                        int id = count + 1;
                        EventType newEvent = EventType(
                          id: id.toString(),
                          name: controllerName.text,
                          imageUrl: imageUrl,
                          event_classificaion_types: eventClassificationRef,
                        );

                        // Add the event to Firestore and wait for the result
                        String result = await newEvent.addToFirestore();

                        // Clear text controllers regardless of the result

                        // Update UI based on the result

                        // If addition was successful, show success message
                        if (result == 'تم إضافة المناسبة بنجاح') {
                          controllerName.clear();
                          controllerId.clear();
                          controllerImage.clear();
                          fileName = "لم يتم اختيار صورة";
                          fileBytes = null;
                          SuccessAlert(context, result);
                        } else {
                          ErrorAlert(context, 'خطأ', result);
                        }
                        setState(() {
                          showSpinner =
                              false; // Set showSpinner to false after processing is done
                        });
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
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: 400,
            height: double.maxFinite,
            child: EventScreen(),
          ),
        ),
      ],
    );
  }

  Future<void> getDataById(String documentId) async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('event_types')
        .doc(documentId)
        .get();

    if (snapshot.exists) {
      // Retrieve the reference to 'event_classificaion_types'
      DocumentReference? eventClassificationRef =
          snapshot.get('event_classificaion_types');

      // Check if the reference exists
      if (eventClassificationRef != null) {
        // Get the referenced document
        DocumentSnapshot eventDocSnapshot = await eventClassificationRef.get();

        // Check if the referenced document exists
        if (eventDocSnapshot.exists) {
          // Retrieve the data
          Map<String, dynamic> eventData =
              eventDocSnapshot.data() as Map<String, dynamic>;

          // Now you can access the data using the field name
          setState(() {
            dropdownValue = eventData['description'].toString();
          });
        } else {
          // Handle the case where the referenced document doesn't exist
        }
      } else {
        // Handle the case where the reference is null
      }

      // Now you can update other UI elements outside setState
      setState(() {
        imageUrl = snapshot.get('image_url');
        controllerName.text = snapshot.get('name');
        controllerId.text = snapshot.get('id');
        editButton = true;
        fileName = "لتغيير الصورة , انقر هنا.";
      });
    }
  }

//display the event type exist
  SafeArea EventScreen() {
    return SafeArea(
      child: Material(
        color: ColorPink_20,
        child: StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance.collection('event_types').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              final eventDocs = snapshot.data!.docs;
              return GridView.builder(
                padding: EdgeInsets.all(10),
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200,
                  childAspectRatio: 7 / 8,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                itemCount: eventDocs.length,
                itemBuilder: (context, index) {
                  final doc = eventDocs[index];
                  return EventItemDisplay(
                    title: doc['name'].toString(),
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
