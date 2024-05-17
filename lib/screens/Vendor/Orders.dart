import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderTableScreen extends StatelessWidget {
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

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: DataTable(
                columns: [
                  DataColumn(label: Text('Order ID')),
                  DataColumn(label: Text('User ID')),
                  DataColumn(label: Text('Vendor ID')),
                  DataColumn(label: Text('Created At')),
                  DataColumn(label: Text('Deliver At')),
                  DataColumn(label: Text('Order Status ID')),
                  DataColumn(label: Text('Price')),
                  DataColumn(label: Text('Item Name')),
                  DataColumn(label: Text('Amount')),
                  DataColumn(label: Text('Item Code')),
                ],
                rows: snapshot.data!.docs.map((doc) {
                  Map<String, dynamic> data =
                      doc.data() as Map<String, dynamic>;
                  return DataRow(
                    cells: [
                      DataCell(Text(data['order_id'] ?? 'N/A')),
                      DataCell(Text(data['user_id'] ?? 'N/A')),
                      DataCell(Text(
                          data['vendors']['vendor_id']?.toString() ?? 'N/A')),
                      DataCell(Text(
                          _parseTimestamp(data['vendors']['created_at']) ??
                              'N/A')),
                      DataCell(Text(
                          _parseTimestamp(data['vendors']['deliver_at']) ??
                              'N/A')),
                      DataCell(FutureBuilder<QuerySnapshot>(
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
                            List<String> orderStatusList = [];
                            documents.forEach((doc) {
                              var orderStatusData =
                                  doc.data() as Map<String, dynamic>;
                              var orderStatusValue =
                                  orderStatusData['description'];
                              orderStatusList.add(orderStatusValue);
                            });

                            return DropdownButton<String>(
                              value: orderStatusList.isNotEmpty
                                  ? orderStatusList.first
                                  : null,
                              items: orderStatusList.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                // Handle dropdown value change
                                print(newValue);
                              },
                            );
                          }
                        },
                      )),
                      DataCell(
                          Text(data['vendors']['price']?.toString() ?? 'N/A')),
                      DataCell(Text(data['vendors']['vendor_id_items']
                              ['item_name'] ??
                          'N/A')),
                      DataCell(Text(data['vendors']['vendor_id_items']['amount']
                              ?.toString() ??
                          'N/A')),
                      DataCell(Text(data['vendors']['vendor_id_items']
                              ['item_code'] ??
                          'N/A')),
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

    // Check if it's a Timestamp object
    if (timestamp is Timestamp) {
      return timestamp.toDate().toString();
    }

    // If not a Timestamp, return null or handle other cases as needed
    return null;
  }
}

void main() {
  runApp(MaterialApp(
    home: OrderTableScreen(),
  ));
}
