import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:testtapp/Alert/error.dart';
import 'package:testtapp/Alert/info.dart';
import 'package:testtapp/Alert/success.dart';
import 'package:testtapp/constants.dart';
import 'package:testtapp/models/Wizard.dart';
import 'package:testtapp/screens/Admin/widgets_admin/wizard/WizardSteps.dart';
import 'package:flutter/services.dart';

String id = '';

class Wizard extends StatefulWidget {
  static const String screenRoute = 'WizardScreen';
  final String EventName;
  const Wizard({Key? key, required this.EventName}) : super(key: key);

  @override
  State<Wizard> createState() => _WizardState();
}

class _WizardState extends State<Wizard> {
  List<String> serviceNames = [];
  List<String> serviceImages = [];
  List<DocumentReference> serviceIds = []; // Store DocumentReferences
  bool isLoading = false;

  int activeStep = 0;
  double progress = 0.2;

  @override
  void initState() {
    super.initState();
    _showPopupMessage();
  }

  Future<void> _showPopupMessage() async {
    await Future.delayed(
        Duration.zero); // Ensures the dialog shows after the first frame

    InfoAlert(context, 'تنبيه',
        'جميع المناسبات جاهزة للعرض للمستخدم. عند الضغط على أي واحدة سيتم تغييرها تلقائيًا بدون رجوع.');
  }

  Future<void> readData(String id) async {
    try {
      setState(() {
        isLoading = true;
      });

      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('event_wizard')
          .doc(id)
          .get();

      if (!snapshot.exists) {
        throw Exception("Document does not exist");
      }

      Map<String, dynamic>? servicesData =
          snapshot.get('services') as Map<String, dynamic>?;

      if (servicesData != null) {
        serviceNames.clear();
        serviceImages.clear();
        serviceIds.clear();
        servicesData.forEach((key, service) {
          serviceNames.add(service['servicename'].toString());
          serviceImages.add(service['serviceimage'].toString());
          serviceIds.add(service['serviceId']);
        });
      } else {
        throw Exception("Services data is null or not in the expected format");
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print("Error reading data: $e");
      // Handle error state or show an error message
    }
  }

//the main Section of the page
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(0, 255, 255, 255),
      body: Container(
        decoration: BoxDecoration(
          border: Border.all(
              color: const Color.fromARGB(165, 255, 255, 255).withOpacity(0.3),
              width: 3),
          borderRadius: BorderRadius.circular(20),
          color: const Color.fromARGB(6, 255, 255, 255).withOpacity(0.22),
        ),
        width: double.maxFinite,
        height: double.maxFinite,
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 0, 8),
              child: CreateEventWizard(EventName: widget.EventName),
            ),
            Expanded(
              flex: 1,
              child: Container(
                color: ColorPink_20,
                height: double.maxFinite,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          widget.EventName,
                          style: StyleTextAdmin(18, AdminButton),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
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
                        child: TextButton(
                            onPressed: () async {
                              if (id != '') {
                                await readData(id);
                              }
                            },
                            child: Text('عرض مراحل المناسبة',
                                style: StyleTextAdmin(14, AdminButton))),
                      ),
                      if (isLoading)
                        CircularProgressIndicator() // Show spinner while loading
                      else if (serviceNames.isNotEmpty &&
                          serviceImages.isNotEmpty)
                        SingleChildScrollView(
                          child: Container(
                            width: 500,
                            child: WizardSteps(
                              activeStep: activeStep,
                              imagePaths: serviceImages,
                              titles: serviceNames,
                              pages: serviceIds,
                              onStepTapped: (int value) {},
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CreateEventWizard extends StatefulWidget {
  final String EventName;
  const CreateEventWizard({Key? key, required this.EventName})
      : super(key: key);

  @override
  State<CreateEventWizard> createState() => _CreateEventWizardState();
}

class _CreateEventWizardState extends State<CreateEventWizard> {
  List<Map<String, dynamic>> _checkboxData = [];
  late Map<int, Map<String, dynamic>> services = {};
  List<int> enteredValues = [];
  bool showSpinner = false;

  @override
  void initState() {
    super.initState();
    loadCheckboxData();
  }

  Future<void> loadCheckboxData() async {
    List<Map<String, dynamic>> data = await readFirestoreCollection();
    setState(() {
      _checkboxData = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.maxFinite,
      width: MediaQuery.of(context).size.width * 0.3,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: ListView.builder(
                itemCount: _checkboxData.length,
                itemBuilder: (context, index) {
                  Map<String, dynamic> checkboxRecord = _checkboxData[index];
                  return Column(
                    children: [
                      CheckboxListTile(
                        activeColor: Colors.black,
                        title: Text(checkboxRecord['name'] ?? '',
                            style: StyleTextAdmin(14, AdminButton)),
                        value: checkboxRecord['checked'] ?? false,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        side: BorderSide(
                          width: 0.7,
                          color: AdminButton,
                        ),
                        onChanged: (newValue) {
                          setState(() {
                            checkboxRecord['checked'] = newValue;

                            if (newValue != null) {
                              checkboxRecord['checked'] = newValue;
                              if (!newValue) {
                                // Remove service if checkbox is unchecked
                                services.removeWhere((key, value) =>
                                    value['servicename'] ==
                                    checkboxRecord['name']);
                                enteredValues.removeWhere(
                                    (value) => services.keys.contains(value));
                                enteredValues.last = enteredValues.last - 1;
                              }
                            }
                          });
                        },
                      ),
                      if (checkboxRecord['checked'] ?? false)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'أدخل رقم ترتيب هذه الخدمة',
                              hintStyle: StyleTextAdmin(
                                  14, AdminButton.withOpacity(0.6)),
                            ),
                            keyboardType: TextInputType.number,
                            style: StyleTextAdmin(
                                14, AdminButton.withOpacity(0.9)),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            onChanged: (value) async {
                              if (value.isEmpty) {
                                return;
                              }

                              int enteredNumber;
                              try {
                                enteredNumber = int.parse(value);
                              } catch (e) {
                                return;
                              }

                              if (enteredValues.isEmpty ||
                                  enteredValues.last + 1 == enteredNumber) {
                                enteredValues.add(enteredNumber);
                                enteredValues
                                    .sort(); // Ensure the list is sorted

                                String serviceName = checkboxRecord['name'];
                                QuerySnapshot snapshot = await FirebaseFirestore
                                    .instance
                                    .collection('service_types')
                                    .where('name', isEqualTo: serviceName)
                                    .get();

                                if (snapshot.docs.isNotEmpty) {
                                  // Assuming only one document with the same name exists
                                  DocumentReference serviceId =
                                      snapshot.docs[0].reference;
                                  String serviceImage =
                                      snapshot.docs[0].get('image_url');

                                  setState(() {
                                    services[enteredNumber] = {
                                      'servicename': serviceName,
                                      'serviceimage': serviceImage,
                                      'serviceId':
                                          serviceId, // Storing the DocumentReference
                                    };
                                  });
                                }
                              } else {
                                // Notify the user that the numbers should be consecutive
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: Colors.white,
                                    content: Center(
                                      child: Text(
                                        "يجب أن تكون الأرقام متتالية. الرقم التالي يجب أن يكون ${enteredValues.last + 1}",
                                        style: StyleTextAdmin(14, Colors.black),
                                      ),
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      Divider(),
                    ],
                  );
                },
              ),
            ),
          ),
          if (showSpinner) // Render spinner only when showSpinner is true
            Positioned.fill(
              child: Center(
                child:
                    CircularProgressIndicator(), // Customize spinner as needed
              ),
            ),
          Container(
            width: 200,
            margin: EdgeInsets.only(bottom: 90),
            decoration: BoxDecoration(
              border: Border.all(
                  color:
                      const Color.fromARGB(165, 255, 255, 255).withOpacity(0.3),
                  width: 2),
              borderRadius: BorderRadius.circular(20),
              color: Colors.white.withOpacity(0.3),
            ),
            child: TextButton(
              onPressed: () async {
                setState(() {
                  showSpinner = true;
                });

                QuerySnapshot snapshot = await FirebaseFirestore.instance
                    .collection('event_types')
                    .where('name', isEqualTo: widget.EventName)
                    .get();

                if (snapshot.docs.isNotEmpty) {
                  String eventTypeId = snapshot.docs[0].id;
                  id = eventTypeId;
                  EventWizard event = EventWizard(
                    services: services,
                    event_type_id: eventTypeId,
                  );

                  String message = await event.uploadToFirebase();
                  setState(() {
                    showSpinner = false;
                  });
                  SuccessAlert(context, message);
                } else {
                  // Handle the case where no matching event type is found

                  ErrorAlert(context, 'خطأ', ' المناسبة غير موجودة');
                }
              },
              child: Text(
                'انشئ مراحل المناسبة',
                style: StyleTextAdmin(16, AdminButton),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<List<Map<String, dynamic>>> readFirestoreCollection() async {
    final QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance.collection('service_types').get();
    return querySnapshot.docs
        .map((doc) => {'name': doc['name'] ?? '', 'checked': false})
        .toList();
  }
}
