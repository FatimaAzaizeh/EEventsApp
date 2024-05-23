import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DisplayAllOrders extends StatefulWidget {
  const DisplayAllOrders({Key? key}) : super(key: key);

  @override
  State<DisplayAllOrders> createState() => _DisplayAllOrdersState();
}

class _DisplayAllOrdersState extends State<DisplayAllOrders> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Table'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('orders').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No orders found.'),
            );
          }

          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Order ID')),
                  DataColumn(label: Text('User ID')),
                  DataColumn(label: Text('Order Details')),
                ],
                rows: snapshot.data!.docs.map<DataRow>((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final orderId = data['order_id'] ?? 'N/A';
                  final userId = data['user_id'] ?? 'N/A';
                  final vendors = data['vendors'] as Map<String, dynamic>?;

                  return DataRow(
                    cells: [
                      DataCell(Text(orderId)),
                      DataCell(Text(userId)),
                      DataCell(ElevatedButton(
                        onPressed: () =>
                            _showOrderDialog(context, orderId, userId, vendors),
                        child: const Text('View Details'),
                      )),
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

  Future<void> _showOrderDialog(BuildContext context, String orderId,
      String userId, Map<String, dynamic>? vendors) async {
    List<Widget> content = [
      Text('Order ID: $orderId'),
      Text('User ID: $userId'),
    ];

    if (vendors == null || vendors.isEmpty) {
      content.add(const Text('No vendors associated with this order.'));
    } else {
      try {
        content.add(await _buildVendorDetails(vendors));
      } catch (e) {
        content.add(Text('Error loading vendor details: $e'));
      }
    }

    _showDialog(context, 'Order Details', content);
  }

  Widget _buildVendorDetails(Map<String, dynamic>? vendors) {
    if (vendors == null || vendors.isEmpty) {
      return const Text('No vendors associated with this order.');
    }

    List<Widget> vendorWidgets = [];
    vendors.forEach((key, value) {
      vendorWidgets.add(
        DataTable(
          columns: const [
            DataColumn(label: Text('Field')),
            DataColumn(label: Text('Value')),
          ],
          rows: [
            DataRow(cells: [
              DataCell(Text('Vendor ID')),
              DataCell(Text(value['vendor_id'].toString())),
            ]),
            DataRow(cells: [
              DataCell(Text('Price')),
              DataCell(Text(value['price'].toString())),
            ]),
            DataRow(cells: [
              DataCell(Text('Order Status')),
              DataCell(Text(value['order_status_id'].toString())),
            ]),
            DataRow(cells: [
              DataCell(Text('Created At')),
              DataCell(Text(_parseTimestamp(value['created_at']))),
            ]),
            DataRow(cells: [
              DataCell(Text('Deliver At')),
              DataCell(Text(_parseTimestamp(value['deliver_at']))),
            ]),
          ],
        ),
      );

      if (value['vendor_id_items'] != null) {
        vendorWidgets.add(const Text('Vendor Items:'));
        vendorWidgets.add(_buildVendorItems(value['vendor_id_items']));
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: vendorWidgets,
    );
  }

  Widget _buildVendorItems(Map<String, dynamic> vendorItems) {
    List<DataRow> itemRows = [];
    vendorItems.forEach((key, value) {
      itemRows.add(
        DataRow(cells: [
          DataCell(Text(value['item_code'].toString())),
          DataCell(Text(value['item_name'].toString())),
          DataCell(Text(value['amount'].toString())),
        ]),
      );
    });

    return DataTable(
      columns: const [
        DataColumn(label: Text('Item Code')),
        DataColumn(label: Text('Item Name')),
        DataColumn(label: Text('Amount')),
      ],
      rows: itemRows,
    );
  }

  String _parseTimestamp(Timestamp? timestamp) {
    if (timestamp == null) {
      return 'N/A';
    }
    final date = timestamp.toDate();
    return '${date.day}-${date.month}-${date.year}';
  }

  void _showDialog(BuildContext context, String title, List<Widget> content) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: content,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
