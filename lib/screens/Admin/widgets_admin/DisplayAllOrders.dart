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
        content.addAll(await _buildVendorDetails(vendors));
      } catch (e) {
        content.add(Text('Error loading vendor details: $e'));
      }
    }

    _showDialog(context, 'Order Details', content);
  }

  Future<List<Widget>> _buildVendorDetails(Map<String, dynamic> vendors) async {
    List<Widget> details = [];
    for (var vendorId in vendors.keys) {
      var vendorData = vendors[vendorId] as Map<String, dynamic>;
      var VendorId = vendorData['vendor_id'].toString();
      details.add(Text('Vendor ID: $VendorId'));
      var price = vendorData['price'].toString();
      details.add(Text('Price: $price'));
      if (vendorData['vendor_id_items'] != null) {
        details.add(const Text('Vendor Items:'));
        for (var item in (vendorData['vendor_id_items'] as Map).values) {
          details.add(Text('  Item Code: ${item['item_code']}'));
          details.add(Text('  Item Name: ${item['item_name']}'));
          details.add(Text('  Amount: ${item['amount']}'));
        }
      }

      if (vendorData['order_status_id'] != null) {
        try {
          var statusSnapshot = await vendorData['order_status_id'].get();
          var orderStatusData = statusSnapshot.data() as Map<String, dynamic>;
          var orderStatusValue = orderStatusData['description'].toString();
          details.add(Text('Order Status: $orderStatusValue'));
        } catch (e) {
          details.add(Text('Error loading order status: $e'));
        }
      }

      details.add(
          Text('Created At: ${_parseTimestamp(vendorData['created_at'])}'));
      details.add(
          Text('Deliver At: ${_parseTimestamp(vendorData['deliver_at'])}'));
    }
    return details;
  }

  String _parseTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'N/A';
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
