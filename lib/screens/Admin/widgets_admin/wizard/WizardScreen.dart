import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:testtapp/models/Wizard.dart';
import 'package:testtapp/screens/Admin/widgets_admin/Service/DisplayService.dart';
import 'package:testtapp/screens/Admin/widgets_admin/wizard/WizardSteps.dart';

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
  List<DocumentReference> serviceIds = [];
  bool isLoading = false;
  int activeStep = 0;

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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CreateEventWizard(EventName: widget.EventName),
          ),
          Expanded(
            flex: 1,
            child: Container(
              height: double.maxFinite,
              width: MediaQuery.of(context).size.width * 0.7,
              child: Column(
                children: [
                  Text(widget.EventName),
                  ElevatedButton(
                    onPressed: () async {
                      if (id != '') {
                        await readData(id);
                      }
                    },
                    child: Text(' تحميل البينات'),
                  ),
                  if (isLoading)
                    CircularProgressIndicator()
                  else if (serviceNames.isNotEmpty && serviceImages.isNotEmpty)
                    Expanded(
                      child: WizardStepsContainer(
                        activeStep: activeStep,
                        imagePaths: serviceImages,
                        titles: serviceNames,
                        pages: serviceIds,
                        onStepTapped: (int value) {
                          setState(() {
                            activeStep = value;
                          });
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
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
    return Expanded(
      flex: 1,
      child: Container(
        color: Colors.white.withOpacity(0.5),
        height: double.maxFinite,
        width: MediaQuery.of(context).size.width * 0.3,
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 40),
                child: ListView.builder(
                  itemCount: _checkboxData.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> checkboxRecord = _checkboxData[index];
                    return Column(
                      children: [
                        CheckboxListTile(
                          title: Text(checkboxRecord['name'] ?? ''),
                          value: checkboxRecord['checked'] ?? false,
                          onChanged: (newValue) {
                            setState(() {
                              checkboxRecord['checked'] = newValue;
                            });
                          },
                        ),
                        if (checkboxRecord['checked'] ?? false)
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Enter number',
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (value) async {
                                String serviceName = checkboxRecord['name'];
                                QuerySnapshot snapshot = await FirebaseFirestore
                                    .instance
                                    .collection('service_types')
                                    .where('name', isEqualTo: serviceName)
                                    .get();

                                if (snapshot.docs.isNotEmpty) {
                                  DocumentReference serviceId =
                                      snapshot.docs[0].reference;
                                  String serviceImage =
                                      snapshot.docs[0].get('image_url');

                                  services[int.parse(value)] = {
                                    'servicename': serviceName,
                                    'serviceimage': serviceImage,
                                    'serviceId': serviceId,
                                  };
                                }
                              },
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
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

                  QuickAlert.show(
                    context: context,
                    customAsset: 'assets/images/Completionanimation.gif',
                    width: 300,
                    title: '$message',
                    type: QuickAlertType.success,
                    confirmBtnText: 'إغلاق',
                  );
                } else {
                  QuickAlert.show(
                    context: context,
                    title: 'Event not found',
                    type: QuickAlertType.error,
                    confirmBtnText: 'Close',
                  );
                }
              },
              child: Text('انشئ مراحل المناسبة'),
            ),
          ],
        ),
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

class EventWizard {
  final Map<int, Map<String, dynamic>> services;
  final String event_type_id;

  EventWizard({required this.services, required this.event_type_id});

  Future<String> uploadToFirebase() async {
    // Implement your logic to upload event wizard data to Firebase
    // You can use the services and event_type_id to upload the data
    await Future.delayed(Duration(seconds: 2)); // Simulating upload process

    return 'Event wizard data uploaded successfully!';
  }
}
