import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:testtapp/constants.dart';
import 'package:testtapp/models/EventType.dart';
import 'package:testtapp/screens/Admin/widgets_admin/TexFieldDesign.dart';
import 'package:testtapp/widgets/Event_item.dart';

// Other import statements and code

final _firestore = FirebaseFirestore.instance;

class AddEvent extends StatefulWidget {
  static const String screenRoute = 'NewEvent';
  const AddEvent({Key? key}) : super(key: key);

  @override
  State<AddEvent> createState() => _AddEventState();
}

class _AddEventState extends State<AddEvent> {
  var ControllerName = TextEditingController();
  var ControllerImage = TextEditingController();
  var ControllerSer = TextEditingController();
  bool showEditButton = false;
  final _auth = FirebaseAuth.instance;
  late String name; // Name of the Event
  late String classification = ''; // Classification of the Event
  late List<String> serviceType = []; // Services related to the event
  late String ImageUrl;
  bool showSpinner = false;
  late String dropdownValue;
  List<String> classificationList = []; // Initialize classification list
  late String id;
  bool isButtonEnabled = false;

  // Method to fetch classifications from Firestore
  void fetchClassificationsFromFirestore() async {
    try {
      setState(() {
        showSpinner = true; // Show spinner when fetching data
      });
      QuerySnapshot querySnapshot =
          await _firestore.collection("Classifications").get();

      setState(() {
        classificationList.clear(); // Clear the list before adding new data
      });

      for (var docSnapshot in querySnapshot.docs) {
        classificationList.add(docSnapshot.get('Name').toString());
      }
      setState(() {
        dropdownValue = classificationList.first;
        showSpinner = false; // Hide spinner after fetching data
      });
    } catch (e) {
      print("Error fetching classifications: $e");
      setState(() {
        showSpinner = false; // Hide spinner if there's an error
      });
    }
  }

//edit
  Future<void> getDataById(String documentId) async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('EventType')
        .doc(documentId) // Use document ID directly
        .get();

    if (snapshot.exists) {
      setState(() {
        // Document with the provided ID exists
        ControllerName.text = snapshot.get('Name');
        ControllerSer.text = snapshot.get('ServiceType').toString();
        ControllerImage.text = snapshot.get('imageUrl');
        //  dropdownValue = snapshot.get('Classification');
        showEditButton = true;
        id = documentId;
        isButtonEnabled = true;
      });
    } else {
      // Document with the provided ID does not exist
      print("Document not found for ID: $documentId");
    }
  }

  void EditEvent(String documentId) {
    setState(() {
      var docRef =
          FirebaseFirestore.instance.collection('EventType').doc(documentId);

      docRef.update({
        'Name': ControllerName.text,
        'ServiceType': ControllerSer.text,
        'imageUrl': ControllerImage.text,
      }).then((_) {
        print("Document updated successfully.");
      }).catchError((error) {
        print("Failed to update document: $error");
      });
      showEditButton = false;
      ControllerName.clear();
      ControllerSer.clear();
      ControllerImage.clear();
      QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
      );
    });
  }

  void DelEvent(String documentId) {
    setState(() {
      QuickAlert.show(
          context: context,
          type: QuickAlertType.confirm,
          text: 'Do you want to logout?',
          confirmBtnText: 'Yes',
          cancelBtnText: 'No',
          confirmBtnColor: Colors.green,
          onConfirmBtnTap: () {
            var docRef = FirebaseFirestore.instance
                .collection('EventType')
                .doc(documentId)
                .delete();
            Navigator.of(context).pop();
          },
          onCancelBtnTap: () {
            // Handle cancellation action here
            // For example, you can dismiss the dialog or perform any other action.
            Navigator.of(context).pop(); // Dismiss the dialog
          });
    });
  }

  @override
  void initState() {
    super.initState();
    fetchClassificationsFromFirestore(); // Fetch classifications when widget is initialized
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment
          .spaceAround, // Distributes space evenly between the children
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Color.fromARGB(221, 255, 255, 255)),
            width: 500,
            height: double.maxFinite,
            child: Column(
              children: [
                Container(
                  width: double.maxFinite,
                  height: 70,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30))),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Text('المناسبات',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontFamily: 'Amiri',
                                fontSize: 28,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 60, 19, 60))),
                        SizedBox(
                          width: 220,
                        ),
                        TextButton(
                          onPressed: isButtonEnabled
                              ? () {
                                  EditEvent(id);
                                  isButtonEnabled = false;
                                }
                              : null,
                          child: Icon(Icons.edit),
                        ),
                        TextButton(
                            onPressed: isButtonEnabled
                                ? () {
                                    DelEvent(id);
                                    isButtonEnabled = false;
                                  }
                                : null,
                            child: Icon(Icons.delete)),
                        TextButton(
                            onPressed: () {
                              ControllerName.clear();
                              ControllerSer.clear();
                              ControllerImage.clear();
                              isButtonEnabled = false;
                            },
                            child: Icon(Icons.clear)),
                      ],
                    ),
                  ),
                ),

                TextFieldDesign(
                    Text: 'أسم المناسبة:',
                    icon: Icons.title,
                    ControllerTextField: ControllerName,
                    onChanged: (value) {
                      name = value; // Update the Name variable
                      // Update the serviceType list
                    },
                    obscureTextField: false),

                // Call the buildClassificationDropdown method where you want to display the dropdown

                DropdownButton<String>(
                  value: classificationList.isNotEmpty ? dropdownValue : null,
                  icon: const Icon(Icons.arrow_downward),
                  elevation: 16,
                  style: const TextStyle(color: Colors.deepPurple),
                  underline: Container(
                    height: 2,
                    color: Colors.deepPurpleAccent,
                  ),
                  onChanged: (String? value) {
                    // This is called when the user selects an item.
                    setState(() {
                      classification = value!;
                      dropdownValue = value;
                    });
                  },
                  items: classificationList
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),

                TextFieldDesign(
                    Text: 'الخدمات المتعلقة بالمناسبة:',
                    icon: Icons.room_service,
                    ControllerTextField: ControllerSer,
                    onChanged: (value) {
                      serviceType =
                          value.split(','); // Update the serviceType list
                    },
                    obscureTextField: false),
                TextFieldDesign(
                    Text: 'إضافة صورة:',
                    icon: Icons.image,
                    ControllerTextField: ControllerImage,
                    onChanged: (value) {
                      ImageUrl = value;
                    },
                    obscureTextField: false),

                Container(
                    width: double.maxFinite,
                    margin: EdgeInsets.only(bottom: 90),
                    child: FloatingActionButton(
                      backgroundColor: kColor1,
                      child: Text('إضافة مناسبة',
                          style: TextStyle(
                              fontFamily: 'Amiri',
                              fontSize: 18,
                              fontStyle: FontStyle.italic,
                              color: Colors.white)),
                      onPressed: () {
                        setState(() async {
                          // Perform Firestore query based on the selected dropdown value
                          QuerySnapshot<Map<String, dynamic>> querySnapshot =
                              await FirebaseFirestore.instance
                                  .collection('Classifications')
                                  .where('Name', isEqualTo: classification)
                                  .get();

                          EventType newEvent = EventType(
                              Name: name,
                              ServiceType: serviceType,
                              Classification: classification,
                              imageUrl: ImageUrl);
                          newEvent.addToFirestore();

                          ControllerName.clear();
                          ControllerSer.clear();
                          ControllerImage.clear();
                          QuickAlert.show(
                            context: context,
                            type: QuickAlertType.success,
                          );
                        });
                      },
                    )),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: Colors.white,
            ),
            width: 400,
            height: double.maxFinite,
            child: EventScreen(),
          ),
        ),
      ],
    );
  }

  SafeArea EventScreen() {
    return SafeArea(
      child: Material(
        child: StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance.collection('EventType').snapshots(),
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
                  return TextButton(
                    onPressed: () {
                      setState(() {
                        getDataById(doc.id);
                      });
                    },
                    child: EventItemDisplay(
                      title: doc['Name'].toString(),
                      imageUrl: doc['imageUrl'].toString(),
                      id: doc.id,
                    ),
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
