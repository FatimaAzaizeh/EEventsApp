import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:testtapp/constants.dart';
import 'package:testtapp/screens/Vendor/DropdownList.dart';
import 'package:testtapp/screens/Vendor/VendorProfile.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String _selectedItem = ''; // Declare _selectedItem as late
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchInitialStatus(); // Fetch initial status from Firebase
  }

  Future<void> fetchInitialStatus() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('UID', isEqualTo: _auth.currentUser!.uid.toString())
          .get();

      // Check if any documents match the query
      if (querySnapshot.docs.isNotEmpty) {
        // Get the first document (assuming id is unique)
        DocumentSnapshot userSnapshot = querySnapshot.docs.first;

        // Get the initial status from Firebase
        bool isActive = userSnapshot['is_active'] ?? false;
        _selectedItem = isActive ? 'متاح' : 'مغلق';
      } else {
        // User document does not exist
        print(
            'User document with ID ${_auth.currentUser!.uid} does not exist.');
        // Set default value if user document does not exist
        _selectedItem = 'متاح';
      }
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      print('Error fetching initial status: $error');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error fetching data';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      height: double.maxFinite,
      decoration: BoxDecoration(
        border: Border.all(
            color: const Color.fromARGB(165, 255, 255, 255).withOpacity(0.1),
            width: 3),
        borderRadius: BorderRadius.circular(20),
        color: const Color.fromARGB(6, 255, 255, 255).withOpacity(0.22),
      ),
      child: _isLoading
          ? Center(
              child: CircularProgressIndicator()) // Show loader while loading
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage)) // Show error message if any
              : Column(
                  children: [
                    IgnorePointer(
                      ignoring: true,
                      child: Center(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          height: MediaQuery.sizeOf(context).height * 0.8,
                          width: double.maxFinite,
                          child: VendorProfile(),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "الحالة :  ",
                            style: StyleTextAdmin(17, Colors.black),
                          ),
                          DropdownButton<String>(
                            style: StyleTextAdmin(16, Colors.black),
                            value: _selectedItem,
                            borderRadius: BorderRadius.circular(30),
                            onChanged: (String? newValue) async {
                              setState(() {
                                _selectedItem = newValue!;
                              });

                              try {
                                QuerySnapshot querySnapshot =
                                    await FirebaseFirestore.instance
                                        .collection('users')
                                        .where('UID',
                                            isEqualTo: _auth.currentUser!.uid
                                                .toString())
                                        .get();

                                // Check if any documents match the query
                                if (querySnapshot.docs.isNotEmpty) {
                                  // Get the first document (assuming id is unique)
                                  DocumentSnapshot userSnapshot =
                                      querySnapshot.docs.first;

                                  // Check if the vendor_status_id reference matches the expected reference
                                  if (newValue == 'متاح')
                                    userSnapshot.reference
                                        .update({'is_active': true});
                                  else
                                    userSnapshot.reference
                                        .update({'is_active': false});
                                } else {
                                  // User document does not exist
                                  print(
                                      'User document with ID ${_auth.currentUser!.uid} does not exist.');
                                }
                              } catch (error) {
                                print(
                                    'Error checking user type reference validity: $error');
                              }
                            },
                            items: <String>['متاح', 'مغلق']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}
