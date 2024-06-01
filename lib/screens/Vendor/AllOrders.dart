import 'package:emailjs/emailjs.dart';
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
        title: Text('Order Table'),
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
                        FutureBuilder<DocumentSnapshot>(
                          future: vendorData['order_status_id'].get(),
                          builder: (context, statusSnapshot) {
                            if (statusSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else if (statusSnapshot.hasError) {
                              return Text('Error fetching data');
                            } else {
                              var orderStatusData = statusSnapshot.data!.data()
                                  as Map<String, dynamic>;
                              var orderStatusValue =
                                  orderStatusData['description'];

                              return FutureBuilder<QuerySnapshot>(
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
                                      return orderStatusData['description']
                                          as String;
                                    }).toList();

                                    return DropdownButton<String>(
                                      value: orderStatusValue,
                                      items:
                                          orderStatusList.map((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                      onChanged: (String? newValue) async {
                                        if (newValue != null) {
                                          int newStatusId = orderStatusList
                                                  .indexOf(newValue) +
                                              1;
                                          DocumentReference newStatusIdRef =
                                              FirebaseFirestore.instance
                                                  .collection('order_status')
                                                  .doc(newStatusId.toString());
                                          setState(() async {
                                            dropDownValues[index] = newValue;
                                            await FirebaseFirestore.instance
                                                .collection('orders')
                                                .doc(doc.id)
                                                .update({
                                              'vendors.${vendorEntry.key}.order_status_id':
                                                  newStatusIdRef,
                                            });
                                            final docSnapshot =
                                                await FirebaseFirestore.instance
                                                    .collection('users')
                                                    .doc(data['user_id'])
                                                    .get();

                                            String useremail =
                                                docSnapshot.data()?['email'];

                                            //sendEmail(useremail);
                                          });
                                        }
                                      },
                                    );
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

  static Future<void> sendEmail(String email) async {
    try {
      await EmailJS.send(
        'service_rjv9jb8',
        'template_q224g4l',
        {
          'user_email': email,
        },
        const Options(
          publicKey: 'TpYQwF1u4eoGTKps4',
          privateKey: '3gCIuEMMsyXcrE9MZAUDz',
        ),
      );
      print('SUCCESS! Email sent to $email');
    } catch (error) {
      if (error is EmailJSResponseStatus) {
        print('ERROR... ${error.status}: ${error.text}');
      }
      print(error.toString());
    }
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
