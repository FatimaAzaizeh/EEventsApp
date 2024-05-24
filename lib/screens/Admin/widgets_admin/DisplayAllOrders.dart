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
        title: const Text('جدول الطلبات'),
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
              child: Text('خطأ: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('لا توجد طلبات.'),
            );
          }

          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('رقم تعريف الطلب')),
                  DataColumn(label: Text('رقم تعريف المستخدم')),
                  DataColumn(label: Text('تفاصيل الطلب')),
                ],
                rows: snapshot.data!.docs.map<DataRow>((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final orderId = data['order_id'] ?? 'غير متاح';
                  final userId = data['user_id'] ?? 'غير متاح';
                  final vendors = data['vendors'] as Map<String, dynamic>?;

                  return DataRow(
                    cells: [
                      DataCell(Text(orderId)),
                      DataCell(Text(userId)),
                      DataCell(ElevatedButton(
                        onPressed: () =>
                            _showOrderDialog(context, orderId, userId, vendors),
                        child: const Text('عرض التفاصيل'),
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
      Text('رقم تعريف الطلب: $orderId'),
      Text('رقم تعريف المستخدم: $userId'),
    ];

    if (vendors == null || vendors.isEmpty) {
      content.add(const Text('لا توجد بائعين مرتبطين بهذا الطلب.'));
    } else {
      try {
        content.add(await _buildVendorDetails(vendors));
      } catch (e) {
        content.add(Text('حدث خطأ أثناء تحميل تفاصيل البائع: $e'));
      }
    }

    _showDialog(context, 'تفاصيل الطلب', content);
  }

  Widget _buildVendorDetails(Map<String, dynamic>? vendors) {
    if (vendors == null || vendors.isEmpty) {
      return const Text('لا توجد بائعين مرتبطين بهذا الطلب.');
    }

    List<Widget> vendorWidgets = [];
    vendors.forEach((key, value) {
      vendorWidgets.add(
        DataTable(
          columns: const [
            DataColumn(label: Text('الحقل')),
            DataColumn(label: Text('القيمة')),
          ],
          rows: [
            DataRow(cells: [
              DataCell(Text('رقم تعريف البائع')),
              DataCell(Text(value['vendor_id'].toString())),
            ]),
            DataRow(cells: [
              DataCell(Text('السعر')),
              DataCell(Text(value['price'].toString())),
            ]),
            DataRow(cells: [
              DataCell(Text('حالة الطلب')),
              DataCell(FutureBuilder<DocumentSnapshot>(
                future: value['order_status_id'].get(),
                builder: (context, statusSnapshot) {
                  if (statusSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (statusSnapshot.hasError) {
                    return Text('Error fetching data');
                  } else {
                    var orderStatusData =
                        statusSnapshot.data!.data() as Map<String, dynamic>;
                    var orderStatusValue = orderStatusData['description'];
                    return Text(orderStatusValue);
                  }
                },
              )),
            ]),
            DataRow(cells: [
              DataCell(Text('تاريخ الإنشاء')),
              DataCell(Text(_parseTimestamp(value['created_at']))),
            ]),
            DataRow(cells: [
              DataCell(Text('تاريخ التسليم')),
              DataCell(Text(_parseTimestamp(value['deliver_at']))),
            ]),
          ],
        ),
      );

      if (value['vendor_id_items'] != null) {
        vendorWidgets.add(const Text('عناصر البائع:'));
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
        DataColumn(label: Text('رمز العنصر')),
        DataColumn(label: Text('اسم العنصر')),
        DataColumn(label: Text('الكمية')),
      ],
      rows: itemRows,
    );
  }

  String _parseTimestamp(Timestamp? timestamp) {
    if (timestamp == null) {
      return 'غير متاح';
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
              child: const Text('إغلاق'),
            ),
          ],
        );
      },
    );
  }
}
