import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:testtapp/models/Orders.dart';

class VendorOrders extends StatefulWidget {
  final String currentUserUID;

  VendorOrders({required this.currentUserUID});

  @override
  State<VendorOrders> createState() => _VendorOrdersState();
}

class _VendorOrdersState extends State<VendorOrders> {
  late Map<int, String?>
      dropDownValues; // Map to store dropdown values for each row

  @override
  void initState() {
    super.initState();
    dropDownValues = {}; // Initialize the map
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text('Order Table'),
            TextButton(
              onPressed: () {
                Orders order = Orders(
                  orderId: '123456', // Replace with your order ID
                  userId: 'user123', // Replace with your user ID
                  vendors: {
                    1: {
                      'created_at': DateTime.now(),
                      'deliver_at': DateTime.now().add(Duration(days: 7)),
                      'order_status_id': 1,
                      'price': 50.0,
                      'vendor_id_items': {
                        'item1': {
                          'amount': 2,
                          'item_code': 'ABC123',
                          'item_name': 'Item 1',
                        },
                        'item2': {
                          'amount': 1,
                          'item_code': 'DEF456',
                          'item_name': 'Item 2',
                        },
                      },
                    },
                    2: {
                      'created_at': DateTime.now(),
                      'deliver_at': DateTime.now().add(Duration(days: 5)),
                      'order_status_id': 1,
                      'price': 70.0,
                      'vendor_id_items': {
                        'item3': {
                          'amount': 3,
                          'item_code': 'GHI789',
                          'item_name': 'Item 3',
                        },
                      },
                    },
                  },
                );

                // Save the order to Firebase Firestore
                order.uploadToFirebase();
              },
              child: Text('اضافه طلب'),
            ),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('orders').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('No orders found.'),
            );
          }

          // Filter the documents to include only those for the current vendor
          var filteredDocs = snapshot.data!.docs.where((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            Map<String, dynamic> vendors = data['vendors'] ?? {};
            return vendors.values
                .any((vendor) => vendor['vendor_id'] == widget.currentUserUID);
          }).toList();

          if (filteredDocs.isEmpty) {
            return Center(
              child: Text('No orders found for this vendor.'),
            );
          }

          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                  DataColumn(label: Text('Order ID')),
                  DataColumn(label: Text('Created At')),
                  DataColumn(label: Text('Deliver At')),
                  DataColumn(label: Text('Order Status')),
                  DataColumn(label: Text('Price')),
                  DataColumn(label: Text('Item Details')),
                ],
                rows: filteredDocs.asMap().entries.map((entry) {
                  var index = entry.key;
                  var doc = entry.value;
                  Map<String, dynamic> data =
                      doc.data() as Map<String, dynamic>;
                  var vendorEntry = data['vendors'].entries.firstWhere(
                        (entry) =>
                            entry.value['vendor_id'] == widget.currentUserUID,
                      );
                  var vendorData = vendorEntry.value;

                  return DataRow(
                    cells: [
                      DataCell(Text(data['order_id'] ?? 'N/A')),
                      DataCell(Text(
                          _parseTimestamp(vendorData['created_at']) ?? 'N/A')),
                      DataCell(Text(
                          _parseTimestamp(vendorData['deliver_at']) ?? 'N/A')),
                      DataCell(
                        FutureBuilder<QuerySnapshot>(
                          future: FirebaseFirestore.instance
                              .collection('order_status')
                              .get(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('Error fetching data');
                            } else {
                              var documents = snapshot.data!.docs;
                              List<String> orderStatusList =
                                  documents.map((doc) {
                                var orderStatusData =
                                    doc.data() as Map<String, dynamic>;
                                return orderStatusData['description'] as String;
                              }).toList();

                              // Fetch the initial value for DropDownValue asynchronously
                              void fetchInitialDropDownValue() async {
                                try {
                                  // Fetch the vendor's order status ID from the document reference
                                  var orderStatusIdRef = vendorData['vendor']
                                          ['order_status_id']
                                      .toString();

                                  // Fetch the specific document using the order status ID
                                  DocumentSnapshot docSnapshot =
                                      await FirebaseFirestore.instance
                                          .collection('order_status')
                                          .doc(orderStatusIdRef)
                                          .get();

                                  // Extract the data from the fetched document
                                  var orderStatusData = docSnapshot.data()
                                      as Map<String, dynamic>;
                                  var initialDropDownValue =
                                      orderStatusData['description'] ??
                                          'Unknown';

                                  // Update the state with the initial dropdown value
                                  setState(() {
                                    dropDownValues = initialDropDownValue;
                                  });
                                } catch (error) {
                                  print('Error fetching order status: $error');
                                }
                              }

                              // Fetch initial value if not already set
                              if (dropDownValues[index] == null) {
                                fetchInitialDropDownValue();
                              }

                              return DropdownButton<String>(
                                value: dropDownValues[index],
                                items: orderStatusList.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) async {
                                  if (newValue != null) {
                                    int newStatusId =
                                        orderStatusList.indexOf(newValue) + 1;
                                    DocumentReference newStatusIdRef =
                                        FirebaseFirestore.instance
                                            .collection('order_status')
                                            .doc(newStatusId.toString());
                                    setState(() {
                                      dropDownValues[index] = newValue;
                                    });
                                    await FirebaseFirestore.instance
                                        .collection('orders')
                                        .doc(doc.id)
                                        .update({
                                      'vendors.${vendorEntry.key}.order_status_id':
                                          newStatusIdRef,
                                    });
                                  }
                                },
                              );
                            }
                          },
                        ),
                      ),
                      DataCell(Text(vendorData['price']?.toString() ?? 'N/A')),
                      DataCell(
                        ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Item Details'),
                                content: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: _buildItemDetails(
                                      vendorData['vendor_id_items']),
                                ),
                              ),
                            );
                          },
                          child: Text('View Details'),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }

  String? _parseTimestamp(dynamic timestamp) {
    if (timestamp == null) return null;
    if (timestamp is Timestamp) {
      return timestamp.toDate().toString();
    }
    return null;
  }

  List<Widget> _buildItemDetails(Map<dynamic, dynamic>? items) {
    if (items == null) return [Text('No items')];
    return items.entries.map((entry) {
      if (entry.value is Map<String, dynamic>) {
        var item = entry.value as Map<String, dynamic>;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Item Code: ${item['item_code']}'),
              Text('Item Name: ${item['item_name']}'),
              Text('Amount: ${item['amount']}'),
            ],
          ),
        );
      } else {
        return Text('Invalid item details');
      }
    }).toList();
  }
}
