import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:testtapp/constants.dart';
import 'package:testtapp/models/Vendor.dart';

class VendorList extends StatelessWidget {
  const VendorList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: kDefaultPadding),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('Vendors').snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            final List<Vendor> vendors = snapshot.data!.docs.map((doc) {
              return Vendor(
                CommercialName: doc['CommercialName'],
                email: doc['Email'],
                description: doc['Description'],
                socialMedia: doc['SocialMedia'],
                state: doc['State'] ?? false,
              );
            }).toList();

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: vendors.map((vendor) {
                  return Padding(
                    padding: const EdgeInsets.only(right: kDefaultPadding),
                    child: VendorCard(
                      vendor: vendor,
                    ),
                  );
                }).toList(),
              ),
            );
          },
        ),
      ],
    );
  }
}

class VendorCard extends StatefulWidget {
  final Vendor vendor;

  const VendorCard({
    Key? key,
    required this.vendor,
  }) : super(key: key);

  @override
  State<VendorCard> createState() => _VendorCardState();
}

class _VendorCardState extends State<VendorCard> {
  late bool _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.vendor.state ?? false;
  }

  void _updateValue(bool newValue) async {
    setState(() {
      _currentValue = newValue;
    });

    try {
      await FirebaseFirestore.instance
          .collection('Vendors')
          .doc(widget.vendor
              .id) // Assuming you have an 'id' field in your Vendor model
          .update({'State': newValue});

      print('Vendor state updated successfully!');
    } catch (error) {
      print('Error updating vendor state: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      height: 300,
      padding: EdgeInsets.all(kDefaultPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 4,
            blurRadius: 3,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                radius: 32,
                backgroundImage: NetworkImage(widget.vendor.email ?? ''),
                backgroundColor: AdminColor,
              ),
              Switch(
                value: _currentValue,
                onChanged: (value) {
                  setState(() {
                    QuickAlert.show(
                      width: 300,
                      context: context,
                      type: QuickAlertType.confirm,
                      barrierDismissible: false,
                      title: _currentValue
                          ? 'هل أنت متأكد من إلغاء نشاط هذا الحساب؟'
                          : 'هل أنت متأكد من إعادة تنشيط هذا الحساب؟',
                      confirmBtnText: 'نعم',
                      confirmBtnTextStyle:
                          TextStyle(fontSize: 16, color: Colors.white),
                      cancelBtnTextStyle:
                          TextStyle(fontSize: 16, color: Colors.grey),
                      cancelBtnText: 'لا',
                      confirmBtnColor: AdminColor,
                      customAsset: 'assets/images/logo.png',
                      onConfirmBtnTap: () {
                        _updateValue(value);
                        Navigator.of(context).pop();
                      },
                      onCancelBtnTap: () {
                        Navigator.of(context).pop();
                      },
                    );
                  });
                },
                activeColor: AdminColor,
                inactiveTrackColor: Colors.grey,
                inactiveThumbColor: Colors.white,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: Text(
              widget.vendor.CommercialName ?? '',
              style: TextStyle(fontSize: 20, color: Colors.black),
              textAlign: TextAlign.right,
            ),
          ),
          Text(
            widget.vendor.description ?? '',
            style: TextStyle(fontSize: 15, color: Colors.black),
          ),
          SizedBox(height: kDefaultPadding / 2),
          Text(
            widget.vendor.description ?? '',
            maxLines: 4,
            style: TextStyle(fontSize: 14, color: Colors.black),
            overflow: TextOverflow.ellipsis,
          ),
          TextButton(
            onPressed: () {},
            child: Text(
              ' المزيد من المعلومات ...',
              style: TextStyle(fontSize: 12, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
