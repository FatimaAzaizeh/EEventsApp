import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VendorItem extends StatefulWidget {
  @override
  State<VendorItem> createState() => _VendorItemState();
}

class _VendorItemState extends State<VendorItem> {
  late List<Item> _items;
  late bool _loading;
  late String _vendorId;

  @override
  void initState() {
    super.initState();
    _loading = true;
    _items = [];
    _vendorId = '';
    initialize();
  }

  Future<void> initialize() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      await getCurrentVendorId(currentUser);
      await getItems();
    } else {
      // Handle the case when the user is not logged in
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> getCurrentVendorId(User user) async {
    final userSnapshot = await FirebaseFirestore.instance
        .collection('vendor')
        .where('UID', isEqualTo: user.uid)
        .get();

    if (userSnapshot.docs.isNotEmpty) {
      setState(() {
        _vendorId = userSnapshot.docs.first.id;
      });
    }
  }

  Future<void> getItems() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('items')
        .where('vendor_id', isEqualTo: _vendorId)
        .get();

    setState(() {
      _items = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Item(
          id: doc.id,
          name: data['name'] ?? '',
          capacity: data['capacity'] ?? 0,
          createdAt: (data['created_at'] as Timestamp).toDate(),
          description: data['description'] ?? '',
          // Add other properties as needed
        );
      }).toList();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Items for Vendor $_vendorId'),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('You have no items.'),
                      ElevatedButton(
                        onPressed: () {
                          // Open dialog to add new item
                          _showAddItemDialog(context);
                        },
                        child: Text('Add New Item'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return Card(
                      child: ListTile(
                        title: Text(item.name),
                        subtitle: Text('Capacity: ${item.capacity}'),
                        trailing:
                            Text('Created At: ${item.createdAt.toString()}'),
                        // Display other item information as needed
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Open dialog to add new item
          _showAddItemDialog(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Future<void> _showAddItemDialog(BuildContext context) async {
    // Implement dialog to add new item here
  }
}

class Item {
  final String id;
  final String name;
  final int capacity;
  final DateTime createdAt;
  final String description;

  Item({
    required this.id,
    required this.name,
    required this.capacity,
    required this.createdAt,
    required this.description,
  });
}
