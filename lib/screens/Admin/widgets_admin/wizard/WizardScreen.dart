import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:testtapp/models/Wizard.dart';
import 'package:testtapp/screens/Admin/widgets_admin/wizard/WizardSteps.dart';

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
  bool isLoading = false;
  int activeStep = 0;
  double progress = 0.2;

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
        servicesData.forEach((key, service) {
          serviceNames.add(service['servicename'].toString());
          serviceImages.add(service['serviceimage'].toString());
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
                    onPressed: () {
                      readData('3');
                    },
                    child: Text('Load Data'),
                  ),
                  if (isLoading)
                    CircularProgressIndicator() // Show spinner while loading
                  else if (serviceNames.isNotEmpty && serviceImages.isNotEmpty)
                    WizardStepsContainer(
                      activeStep: activeStep,
                      imagePaths: serviceImages,
                      titles: serviceNames,
                      pages: [
                        Container(
                          color: Colors.blue,
                          width: 200,
                          height: 100,
                        ),
                        Container(
                          color: Colors.amber,
                          width: 200,
                          height: 100,
                        ),
                        Container(
                          color: Colors.amber,
                          width: 200,
                          height: 100,
                        )
                      ],
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
                                  // Assuming only one document with the same name exists
                                  String serviceimage =
                                      snapshot.docs[0].get('image_url');

                                  services[int.parse(value)] = {
                                    'servicename': checkboxRecord['name'],
                                    'serviceimage': serviceimage,
                                  };
                                }
                                // Handle text field changes
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
              onPressed: () {
                setState(() async {
                  QuerySnapshot snapshot = await FirebaseFirestore.instance
                      .collection('event_types')
                      .where('name', isEqualTo: widget.EventName)
                      .get();

                  String event_type_id = snapshot.docs[0].get('id');
                  EventWizard event = EventWizard(
                    services: services,
                    event_type_id: event_type_id,
                  );

                  event.uploadToFirebase();
                });
              },
              child: Text('انشئ مراجل المناسبة'),
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
