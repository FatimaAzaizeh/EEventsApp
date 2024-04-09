import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:testtapp/constants.dart';
import 'package:testtapp/models/Vendor.dart';
import 'package:testtapp/screens/Admin/widgets_admin/DesignFun.dart';

class VendorList extends StatefulWidget {
  const VendorList({Key? key}) : super(key: key);

  @override
  State<VendorList> createState() => _VendorListState();
}

class _VendorListState extends State<VendorList> {
  @override
  Widget build(BuildContext context) {
    return FunDesign(
      titleAppBar: 'إدارة حسابات الشركاء',
      child: Column(
        children: [
          SizedBox(height: kDefaultPadding),
          StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance.collection('Vendors').snapshots(),
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
                  state: doc['state'] ??
                      false, // Default to false if state is null
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
      ),
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
      width: 400,
      padding: EdgeInsets.all(kDefaultPadding),
      decoration: BoxDecoration(
        color: kColor2,
        borderRadius: BorderRadius.circular(10), // Rounded corners
        border: Border.all(
          color: Colors.grey.shade300, // Border color
          width: 1.5, // Border width
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(widget.vendor.image ?? ''),
          ),
          SizedBox(width: kDefaultPadding), // Spacing
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.vendor.name ?? '',
                  style: Theme.of(context).textTheme.subtitle2,
                ),
                Text(
                  widget.vendor.source ?? '',
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                SizedBox(height: kDefaultPadding / 2),
                Text(
                  widget.vendor.text ?? '',
                  maxLines: 4,
                  style: TextStyle(height: 1.5),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: kDefaultPadding), // Spacing
          Switch(
            value: _currentValue,
            onChanged: (value) {
              _updateValue(value);
            },
            activeColor: Colors.white,
            inactiveThumbColor: Colors.grey,
          ),
        ],
      ),
    );
  }
}
