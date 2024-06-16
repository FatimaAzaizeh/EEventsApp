import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:testtapp/constants.dart';
import 'package:testtapp/models/item.dart';
import 'package:testtapp/screens/Vendor/Alert_Edit.dart';
import 'package:testtapp/screens/Vendor/Alert_Item.dart';

class VendorItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (userSnapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: Failed to fetch user data.')),
          );
        }

        final currentUser = userSnapshot.data;

        if (currentUser == null) {
          // User not logged in
          return Scaffold(
            body: Center(child: Text('User not logged in.')),
          );
        }

        return VendorItemContent(currentUser: currentUser);
      },
    );
  }
}

class VendorItemContent extends StatelessWidget {
  final User currentUser;

  const VendorItemContent({Key? key, required this.currentUser})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('item')
          .where('vendor_id',
              isEqualTo: FirebaseFirestore.instance
                  .collection('vendor')
                  .doc(currentUser.uid))
          .where('item_status_id', whereIn: [
        FirebaseFirestore.instance.collection('item_status').doc('1'),
        FirebaseFirestore.instance.collection('item_status').doc('3')
      ]).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: const Color.fromARGB(0, 255, 255, 255),
            body: Center(child: Text('Error: Failed to fetch items.')),
          );
        }

        final items = snapshot.data!.docs.map((doc) {
          final data = doc.data();
          return ItemDisplay(
            id: doc.id,
            name: data['name'] ?? '',
            itemCode: data['item_code'] ?? '',
            imageUrl: data['image_url'] ?? '',
            description: data['description'] ?? '',
            price: data['price']?.toDouble() ?? 0.0,
            capacity: data['capacity'] ?? 0,
            eventTypeId: data['event_type_id'],
            itemStatusId: data['item_status_id'],
            createdAt: (data['created_at'] as Timestamp).toDate(),
          );
        }).toList();

        return VendorItemGrid(items: items, currentUser: currentUser);
      },
    );
  }
}

class VendorItemGrid extends StatelessWidget {
  final List<ItemDisplay> items;
  final User currentUser;

  const VendorItemGrid(
      {Key? key, required this.items, required this.currentUser})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(0, 255, 255, 255),
      body: Stack(
        children: [
          // Background image
          Container(
            decoration:
                BoxDecoration(color: const Color.fromARGB(0, 255, 255, 255)),
          ),
          // Main content
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 13, 8, 8),
                  child: Container(
                    width: 230,
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: const Color.fromARGB(165, 255, 255, 255)
                              .withOpacity(0.3),
                          width: 2),
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white.withOpacity(0.3),
                    ),
                    child: TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertItem(
                            vendorId: currentUser.uid,
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.add,
                            color: ColorPurple_100,
                            size: 28,
                          ),
                          SizedBox(
                            width: 3,
                          ),
                          Text("إضافة منتج / خدمة جديدة",
                              style: StyleTextAdmin(16, Colors.black)),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: items.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'لا يوجد لديك أي منتجات',
                                style: StyleTextAdmin(16, AdminButton),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertItem(
                                      vendorId: currentUser.uid,
                                    ),
                                  );
                                },
                                child: Text('أضف منتجًا جديدًا',
                                    style: StyleTextAdmin(16, AdminButton)),
                              ),
                            ],
                          ),
                        )
                      : GridView.builder(
                          padding: EdgeInsets.all(10.0),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: 10.0,
                            mainAxisSpacing: 10.0,
                            childAspectRatio:
                                1.0, // Ensures square-shaped items
                          ),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return GestureDetector(
                              onTap: () {
                                // Handle item tap
                              },
                              child: Container(
                                width: double.maxFinite,
                                height: double.maxFinite,
                                margin: EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: const Color.fromARGB(
                                              165, 255, 255, 255)
                                          .withOpacity(0.3),
                                      width: 4),
                                  borderRadius: BorderRadius.circular(20),
                                  color: const Color.fromARGB(6, 255, 255, 255)
                                      .withOpacity(0.1),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(20),
                                        topRight: Radius.circular(20),
                                      ),
                                      child: item.imageUrl.isNotEmpty
                                          ? Image.network(
                                              item.imageUrl,
                                              width: double.maxFinite,
                                              height: 100,
                                              fit: BoxFit.cover,
                                            )
                                          : Placeholder(),
                                    ),
                                    SizedBox(
                                      height: 2,
                                    ),
                                    Text(
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      'إسم المنتج / الخدمة: ${item.name}',
                                      style: StyleTextAdmin(13, Colors.black),
                                    ),
                                    Text(
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      'الوصف: ${item.description}',
                                      style: StyleTextAdmin(12, AdminButton),
                                    ),
                                    Text(
                                      'السعر:  ${item.price}'
                                      ' د ,إ',
                                      style: StyleTextAdmin(12, Colors.green),
                                    ),
                                    Text(
                                      ' السعة:  ${item.capacity}',
                                      style: StyleTextAdmin(12, AdminButton),
                                    ),
                                    FutureBuilder(
                                      future: Future.wait([
                                        item.itemStatusId.get(),
                                        item.eventTypeId.get(),
                                      ]),
                                      builder: (context,
                                          AsyncSnapshot<List<DocumentSnapshot>>
                                              snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return Center(
                                              child:
                                                  CircularProgressIndicator());
                                        } else if (snapshot.hasError) {
                                          return Center(
                                              child: Text(
                                                  'Error: ${snapshot.error}'));
                                        } else if (!snapshot.hasData) {
                                          return Center(
                                              child: Text('No data available'));
                                        } else {
                                          var itemStatusData = snapshot.data![0]
                                                  ['description'] ??
                                              'Unknown';
                                          var eventTypeData = snapshot.data![1]
                                                  ['name'] ??
                                              'Unknown';

                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'حالة المنتج: $itemStatusData',
                                                style: StyleTextAdmin(
                                                    12,
                                                    getColorForStatus(
                                                        itemStatusData)),
                                              ),
                                              Text(
                                                'نوع الحدث: $eventTypeData',
                                                style: StyleTextAdmin(
                                                    12, AdminButton),
                                              ),
                                            ],
                                          );
                                        }
                                      },
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            Icons.edit,
                                            color: Colors.black,
                                          ),
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) =>
                                                  AlertEditItem(
                                                vendor_id: currentUser.uid,
                                                item_code: item.id,
                                              ),
                                            );
                                          },
                                          tooltip: 'تعديل',
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.delete,
                                            color: Colors.black,
                                          ),
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: Text(
                                                    "حذف المنتج",
                                                    style: StyleTextAdmin(
                                                        18, Colors.red),
                                                  ),
                                                  content: Text(
                                                      "هل أنت متأكد من حذف المنتج؟",
                                                      style: StyleTextAdmin(
                                                          16, Colors.black)),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop(); // Close the dialog
                                                      },
                                                      child: Text("الغاء",
                                                          style: StyleTextAdmin(
                                                              16,
                                                              Colors.black)),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        // Implement deletion functionality
                                                        Item.deactiveItemInFirestore(
                                                            item.id);
                                                        Navigator.of(context)
                                                            .pop(); // Close the dialog
                                                      },
                                                      child: Text("حذف",
                                                          style: StyleTextAdmin(
                                                              16, Colors.red)),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                          tooltip: 'حذف',
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                ),
              ]),
        ],
      ),
    );
  }
}

class ItemDisplay {
  final String id;
  final String name;
  final String itemCode;
  final String imageUrl;
  final String description;
  final double price;
  final int capacity;
  final DocumentReference eventTypeId;
  final DocumentReference itemStatusId;
  final DateTime createdAt;

  ItemDisplay({
    required this.id,
    required this.name,
    required this.itemCode,
    required this.imageUrl,
    required this.description,
    required this.price,
    required this.capacity,
    required this.eventTypeId,
    required this.itemStatusId,
    required this.createdAt,
  });
}
