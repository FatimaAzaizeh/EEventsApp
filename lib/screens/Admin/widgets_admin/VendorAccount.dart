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

          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // 3 containers in each row
              childAspectRatio:
                  1.5, // Aspect ratio to make the containers smaller
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
            ),
            itemCount: vendors.length,
            itemBuilder: (context, index) {
              final vendorData = vendors[index];
              return VendorCard(vendorData: vendorData);
            },
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
        width: 140, // Reduced width
        height: 180, // Reduced height
        padding: EdgeInsets.all(8), // Reduced padding
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color.fromARGB(165, 255, 255, 255).withOpacity(0.3),
            width: 3,
          ),
          borderRadius: BorderRadius.circular(20),
          color: widget.vendorData['vendor_status_id'] == VendorStatusRef
              ? Color.fromARGB(165, 255, 255, 255).withOpacity(0.2)
              : Colors.grey.withOpacity(0.2),
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  radius: 30, // Increased radius
                  backgroundImage:
                      NetworkImage(widget.vendorData['logo_url'] ?? ''),
                  backgroundColor: Colors.white,
                ),
                Switch(
                  value:
                      widget.vendorData['vendor_status_id'] == VendorStatusRef,
                  onChanged: (value) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text(
                            widget.vendorData['vendor_status_id'] ==
                                    VendorDeactive
                                ? 'تفعيل الحساب'
                                : 'تعطيل الحساب',
                            style: StyleTextAdmin(16, Colors.red),
                          ),
                          content: Text(
                            widget.vendorData['vendor_status_id'] ==
                                    VendorDeactive
                                ? 'هل أنت متأكد من رغبتك في تفعيل هذا الحساب؟'
                                : 'هل أنت متأكد من رغبتك في تعطيل هذا الحساب؟',
                            style: StyleTextAdmin(14, Colors.black),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                'لا',
                                style: StyleTextAdmin(14, Colors.black),
                              ),
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
                              child: Text(
                                'نعم',
                                style: StyleTextAdmin(14, Colors.red),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  activeColor: ColorPink_100,
                  inactiveTrackColor:
                      Colors.grey.withOpacity(0.2), // Change to light gray
                  inactiveThumbColor: Colors.white,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4), // Reduced padding
              child: Text(
                widget.vendorData['business_name'] ?? '',
                style: StyleTextAdmin(14, Colors.black), // Reduced font size
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
                          style: StyleTextAdmin(
                              10, Colors.black), // Reduced font size
                        ),
                        SizedBox(height: 4),
                        Text(
                          widget.vendorData['instagram_url'] ?? '',
                          maxLines: 4,
                          style: StyleTextAdmin(
                              10, Colors.black), // Reduced font size
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  )
                : Container(),
            SizedBox(height: 4),
            TextButton(
              onPressed: () {
                setState(() {
                  isExpanded = !isExpanded;
                });
              },
              child: Text(
                isExpanded ? 'تقليل المعلومات' : 'المزيد من المعلومات...',
                style: StyleTextAdmin(10, Colors.black), // Reduced font size
              ),
            ),
          ],
        ),
      ),
    );
  }
}
