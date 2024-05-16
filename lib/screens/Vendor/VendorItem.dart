import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
          return Scaffold(
            appBar: AppBar(title: Text('Items')),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (userSnapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: Text('Items')),
            body: Center(child: Text('Error: ${userSnapshot.error}')),
          );
        }

        final currentUser = userSnapshot.data;

        if (currentUser == null) {
          // User not logged in
          return Scaffold(
            appBar: AppBar(title: Text('Items')),
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
          .where('item_status_id',
              isEqualTo:
                  FirebaseFirestore.instance.collection('item_status').doc('1'))
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: Text('Items')),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: Text('Items')),
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        final items = snapshot.data!.docs.map((doc) {
          final data = doc.data();
          return ItemDisplay(
            id: doc.id,
            name: data['name'] ?? '',
            capacity: data['capacity'] ?? 0,
            createdAt: (data['created_at'] as Timestamp).toDate(),
            description: data['description'] ?? '',
          );
        }).toList();

        return VendorItemList(items: items, currentUser: currentUser);
      },
    );
  }
}

class VendorItemList extends StatelessWidget {
  final List<ItemDisplay> items;
  final User currentUser;

  const VendorItemList(
      {Key? key, required this.items, required this.currentUser})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Items for Vendor ${currentUser.uid}'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertItem(
                  vendor_id: currentUser.uid,
                ),
              );
            },
          ),
        ],
      ),
      body: items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('You have no items.'),
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertItem(
                          vendor_id: currentUser.uid,
                        ),
                      );
                    },
                    child: Text('Add New Item'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Card(
                  child: ListTile(
                    title: Text(item.name),
                    subtitle: Text('Capacity: ${item.capacity}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertEditItem(
                                vendor_id: currentUser.uid,
                                item_code: item.id,
                              ),
                            );
                            // Implement editing functionality
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            // Implement deletion functionality
                            Item.deactiveItemInFirestore(item.id);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class ItemDisplay {
  final String id;
  final String name;
  final int capacity;
  final DateTime createdAt;
  final String description;

  ItemDisplay({
    required this.id,
    required this.name,
    required this.capacity,
    required this.createdAt,
    required this.description,
  });
}
