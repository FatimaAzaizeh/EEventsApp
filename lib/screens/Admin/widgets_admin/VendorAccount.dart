import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:testtapp/constants.dart';

bool state = true;

class VendorList extends StatefulWidget {
  static const String screenRoute = 'VendorAccount';
  const VendorList({Key? key}) : super(key: key);

  @override
  State<VendorList> createState() => _VendorListState();
}

class _VendorListState extends State<VendorList> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.maxFinite,
      width: double.maxFinite,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('vendor')
            .where('vendor_status_id', isEqualTo: '2')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          final vendors = snapshot.data?.docs
                  .map((doc) => doc.data() as Map<String, dynamic>)
                  .toList() ??
              [];

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: vendors.map((vendorData) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: VendorCard(vendorData: vendorData),
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
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      height: 300,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 32,
            backgroundImage: NetworkImage(widget.vendorData['logo_url'] ?? ''),
            backgroundColor: Colors.pink[100],
          ),
          Switch(
            value: state,
            onChanged: (value) {
              widget.vendorData['vendor_status_id'] = '3';
              setState(() {
                state = false;
              });
              // Handle switch change here
            },
            activeColor: ColorPink_100,
            inactiveTrackColor: Colors.grey,
            inactiveThumbColor: Colors.white,
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: Text(
              widget.vendorData['business_name'] ?? '',
              style: TextStyle(fontSize: 20, color: Colors.black),
              textAlign: TextAlign.right,
            ),
          ),
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
    );
  }
}
