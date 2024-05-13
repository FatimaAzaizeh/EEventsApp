import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:testtapp/constants.dart';
import 'package:testtapp/models/Vendor.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'قائمة البائعين',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('قائمة البائعين'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'البائعين',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Expanded(
                child: VendorList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VendorList extends StatefulWidget {
  static const String screenRoute = 'VendorAccount';
  const VendorList({Key? key}) : super(key: key);

  @override
  State<VendorList> createState() => _VendorListState();
}

DocumentReference VendorStatusRef =
    FirebaseFirestore.instance.collection('vendor_status').doc('2');
DocumentReference VendorDeactive =
    FirebaseFirestore.instance.collection('vendor_status').doc('3');

class _VendorListState extends State<VendorList> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('vendor').where(
            'vendor_status_id',
            whereIn: [VendorStatusRef, VendorDeactive]).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Text('خطأ: ${snapshot.error}');
          }
          final vendors = snapshot.data?.docs
                  .map((doc) => doc.data() as Map<String, dynamic>)
                  .toList() ??
              [];

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start, // Align to the left
              children: vendors.map((vendorData) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: 250, // Fixed width
                    height: 250, // Fixed height to make it a square
                    child: VendorCard(vendorData: vendorData),
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}

class VendorCard extends StatefulWidget {
  final Map<String, dynamic> vendorData;

  const VendorCard({Key? key, required this.vendorData}) : super(key: key);

  @override
  State<VendorCard> createState() => _VendorCardState();
}

class _VendorCardState extends State<VendorCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isExpanded = !isExpanded;
        });
      },
      child: Container(
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: widget.vendorData['vendor_status_id'] == VendorStatusRef
              ? Colors.white.withOpacity(0.8)
              : Colors.grey,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.4),
              spreadRadius: 8,
              blurRadius: 7,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundImage:
                      NetworkImage(widget.vendorData['logo_url'] ?? ''),
                  backgroundColor: Colors.pink[100],
                ),
                Switch(
                  value:
                      widget.vendorData['vendor_status_id'] == VendorStatusRef,
                  onChanged: (value) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text(widget.vendorData['vendor_status_id'] ==
                                  VendorDeactive
                              ? 'تفعيل الحساب'
                              : 'تعطيل الحساب'),
                          content: Text(widget.vendorData['vendor_status_id'] ==
                                  VendorDeactive
                              ? 'هل أنت متأكد من رغبتك في تفعيل هذا الحساب؟'
                              : 'هل أنت متأكد من رغبتك في تعطيل هذا الحساب؟'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('لا'),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  if (widget.vendorData['vendor_status_id'] ==
                                      VendorStatusRef) {
                                    Vendor.updateStatusIdInFirestore(
                                        VendorDeactive,
                                        widget.vendorData['UID']);
                                  } else {
                                    Vendor.updateStatusIdInFirestore(
                                        VendorStatusRef,
                                        widget.vendorData['UID']);
                                  }
                                });
                                Navigator.of(context).pop();
                              },
                              child: Text('نعم'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  activeColor: ColorPink_100,
                  inactiveTrackColor: Colors.grey[300], // Change to light gray
                  inactiveThumbColor: Colors.white,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                widget.vendorData['business_name'] ?? '',
                style: TextStyle(fontSize: 20, color: Colors.black),
                textAlign: TextAlign.right,
              ),
            ),
            isExpanded
                ? SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.vendorData['bio'] ?? '',
                          style: TextStyle(fontSize: 15, color: Colors.black),
                        ),
                        SizedBox(height: 8),
                        Text(
                          widget.vendorData['instagram_url'] ?? '',
                          maxLines: 4,
                          style: TextStyle(fontSize: 14, color: Colors.black),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  )
                : Container(),
            SizedBox(height: 8),
            TextButton(
              onPressed: () {
                setState(() {
                  isExpanded = !isExpanded;
                });
              },
              child: Text(
                isExpanded ? 'تقليل المعلومات' : 'المزيد من المعلومات...',
                style: TextStyle(fontSize: 12, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
