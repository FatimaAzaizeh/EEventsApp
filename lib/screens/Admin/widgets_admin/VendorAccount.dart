import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:testtapp/constants.dart';
import 'package:testtapp/models/Vendor.dart';

class VendorList extends StatefulWidget {
  const VendorList({Key? key}) : super(key: key);

  @override
  State<VendorList> createState() => _VendorListState();
}

class _VendorListState extends State<VendorList> {
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
                id: doc.id,
                name: doc['name'],
                image: doc['image'],
                source: doc['source'],
                text: doc['text'],
                state:
                    doc['state'] ?? false, // Default to false if state is null
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
    _currentValue = widget.vendor.state ??
        false; // Initialize with the current state from Firestore
  }

  void _updateValue(bool newValue) async {
    setState(() {
      _currentValue = newValue;
    });

    try {
      // Update the 'state' field of the vendor in Firestore
      await FirebaseFirestore.instance
          .collection('Vendors')
          .doc(widget.vendor.id)
          .update({'state': newValue});

      print('Vendor state updated successfully!');
    } catch (error) {
      print('Error updating vendor state: $error');
      // Handle error appropriately (e.g., show a snackbar)
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
          borderRadius: BorderRadius.circular(10), // Rounded corners
          boxShadow: [
            BoxShadow(
              color: Colors.grey
                  .withOpacity(0.1), // Color of the shadow with opacity
              spreadRadius: 4, // Amount of spreading of the shadow
              blurRadius: 3, // Amount of blurring of the shadow
              offset: Offset(0, 3),
              // Position of the shadow (horizontal, vertical)
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
                      backgroundImage: NetworkImage(widget.vendor.image ?? ''),
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
                                  StyleTextAdmin(16, Colors.white),
                              cancelBtnTextStyle:
                                  StyleTextAdmin(16, Colors.grey),
                              cancelBtnText: 'لا',
                              confirmBtnColor: AdminColor,
                              customAsset: 'assets/images/logo.png',
                              onConfirmBtnTap: () {
                                _updateValue(value);
                                Navigator.of(context).pop();
                              },
                              onCancelBtnTap: () {
                                // Handle cancellation action here
                                // For example, you can dismiss the dialog or perform any other action.
                                Navigator.of(context)
                                    .pop(); // Dismiss the dialog
                              });
                        });
                      },
                      activeColor: AdminColor,
                      inactiveTrackColor: Colors.grey,
                      inactiveThumbColor: Colors.white,
                    ), // Spacing
                  ]),
              Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: Text(
                  widget.vendor.name ?? '',
                  style: StyleTextAdmin(20, Colors.black),
                  textAlign: TextAlign.right,
                ),
              ),
              Text(
                widget.vendor.source ?? '',
                style: StyleTextAdmin(15, Colors.black),
              ),
              SizedBox(height: kDefaultPadding / 2),
              Text(
                widget.vendor.text ?? '',
                maxLines: 4,
                style: StyleTextAdmin(14, Colors.black),
                overflow: TextOverflow.ellipsis,
              ),
              TextButton(
                  onPressed: () {},
                  child: Text(
                    ' المزيد من المعلومات ...',
                    style: StyleTextAdmin(12, Colors.black),
                  ))
            ]));
  }
}
