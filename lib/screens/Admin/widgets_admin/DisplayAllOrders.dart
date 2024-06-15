import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:testtapp/Design/OrderStatusContainer.dart';
import 'package:testtapp/constants.dart';
import 'package:flutter/widgets.dart';
import 'package:testtapp/screens/Admin/widgets_admin/imageHover.dart';

class DisplayAllOrders extends StatefulWidget {
  const DisplayAllOrders({Key? key}) : super(key: key);

  @override
  State<DisplayAllOrders> createState() => _DisplayAllOrdersState();
}

class _DisplayAllOrdersState extends State<DisplayAllOrders> {
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.maxFinite,
      width: double.maxFinite,
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color.fromARGB(165, 255, 255, 255).withOpacity(0.3),
          width: 3,
        ),
        borderRadius: BorderRadius.circular(20),
        color: const Color.fromARGB(6, 255, 255, 255).withOpacity(0.22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              'جدول الطلبات',
              style: StyleTextAdmin(20, AdminButton),
            ),
          ),
          StreamBuilder<QuerySnapshot>(
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

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DataTable(
                        columnSpacing: 40,
                        headingTextStyle: StyleTextAdmin(15, Colors.black),
                        border: TableBorder.all(
                          color: Color.fromARGB(137, 255, 255, 255),
                          width: 2,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        decoration: BoxDecoration(color: ColorPink_20),
                        dataTextStyle: StyleTextAdmin(12, AdminButton),
                        columns: [
                          DataColumn(
                            label: Text(
                              'رقم تعريف الطلب',
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'رقم تعريف المستخدم',
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'إسم المستخدم',
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'رقم الهاتف ',
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'العنوان ',
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'قيمة الطلب ',
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'تفاصيل الطلب',
                            ),
                          ),
                        ],
                        rows: snapshot.data!.docs.map<DataRow>((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final orderId = data['order_id'] ?? 'غير متاح';
                          final userId = data['user_id'] ?? 'غير متاح';
                          final vendors =
                              data['vendors'] as Map<String, dynamic>?;
                          final total = data['total_price'].toString();

                          return DataRow(
                            cells: [
                              DataCell(Text(orderId)),
                              DataCell(Text(userId)),
                              DataCell(
                                FutureBuilder<DocumentSnapshot>(
                                  future: FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(userId)
                                      .get(),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<DocumentSnapshot>
                                          snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return CircularProgressIndicator();
                                    } else if (snapshot.hasError) {
                                      return Text('Error: ${snapshot.error}');
                                    } else if (snapshot.hasData &&
                                        snapshot.data!.exists) {
                                      String username =
                                          snapshot.data!.get('name');
                                      return Text('$username');
                                    } else {
                                      return Text('المستخدم غير موجود');
                                    }
                                  },
                                ),
                              ),
                              DataCell(
                                FutureBuilder<DocumentSnapshot>(
                                  future: FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(userId)
                                      .get(),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<DocumentSnapshot>
                                          snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return CircularProgressIndicator();
                                    } else if (snapshot.hasError) {
                                      return Text('Error: ${snapshot.error}');
                                    } else if (snapshot.hasData &&
                                        snapshot.data!.exists) {
                                      String phoneNumber =
                                          snapshot.data!.get('phone');
                                      return Text('$phoneNumber');
                                    } else {
                                      return Text('المستخدم غير موجود');
                                    }
                                  },
                                ),
                              ),
                              DataCell(
                                FutureBuilder<DocumentSnapshot>(
                                  future: FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(userId)
                                      .get(),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<DocumentSnapshot>
                                          snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return CircularProgressIndicator();
                                    } else if (snapshot.hasError) {
                                      return Text('Error: ${snapshot.error}');
                                    } else if (snapshot.hasData &&
                                        snapshot.data!.exists) {
                                      String address =
                                          snapshot.data!.get('address');
                                      return Text('$address');
                                    } else {
                                      return Text('المستخدم غير موجود');
                                    }
                                  },
                                ),
                              ),
                              DataCell(Text(total + ' د.إ   ')),
                              DataCell(Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color:
                                        const Color.fromARGB(165, 255, 255, 255)
                                            .withOpacity(0.3),
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.white.withOpacity(0.3),
                                ),
                                child: TextButton(
                                  onPressed: () {
                                    _showOrderDialog(
                                        context, orderId, userId, vendors);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor: Colors.white,
                                        content: Center(
                                          child: Text(
                                            "يتم تحميل تفاصيل الطلب , إنتظر قليلا",
                                            style: StyleTextAdmin(
                                                14, Colors.black),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  child: Text('عرض التفاصيل',
                                      style: StyleTextAdmin(12, AdminButton)),
                                ),
                              )),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Future<String> getImageUrl(String itemCode) async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('item')
        .where('item_code', isEqualTo: itemCode)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first.data()['image_url'];
    } else {
      return 'https://example.com/default_image.jpg';
    }
  }

  Future<void> _showOrderDialog(BuildContext context, String orderId,
      String userId, Map<String, dynamic>? vendors) async {
    List<Widget> content = [
      Text('رقم تعريف الطلب: $orderId',
          style: StyleTextAdmin(15, Colors.black)),
      SizedBox(height: 10),
      Text('رقم تعريف المستخدم: $userId',
          style: StyleTextAdmin(15, Colors.black)),
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

  Future<Widget> _buildVendorDetails(Map<String, dynamic>? vendors) async {
    if (vendors == null || vendors.isEmpty) {
      return const Text('لا توجد بائعين مرتبطين بهذا الطلب.');
    }

    List<Widget> vendorWidgets = [];
    for (var value in vendors.values) {
      vendorWidgets.add(
        DataTable(
          headingTextStyle: StyleTextAdmin(16, Colors.black),
          dataTextStyle: StyleTextAdmin(12, Colors.black),
          columns: [
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
                    return OrderStatusContainer(
                      orderStatusValue: orderStatusValue,
                    );
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
        vendorWidgets.add(Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text('عناصر البائع:', style: StyleTextAdmin(15, Colors.black)),
        ));
        vendorWidgets.add(await _buildVendorItems(value['vendor_id_items']));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: vendorWidgets,
    );
  }

  Future<Widget> _buildVendorItems(Map<String, dynamic> vendorItems) async {
    List<DataRow> itemRows = [];
    for (var value in vendorItems.values) {
      String imageUrl = await getImageUrl(value['item_code']);
      ImageHoverWidget imageWidget = ImageHoverWidget(
        imageUrl: imageUrl,
      );

      itemRows.add(
        DataRow(cells: [
          DataCell(Text(value['item_code'].toString())),
          DataCell(Text(value['item_name'].toString())),
          DataCell(Text(value['amount'].toString())),
          DataCell(Padding(
            padding: const EdgeInsets.all(8.0),
            child: imageWidget,
          )),
        ]),
      );
    }

    return DataTable(
      headingTextStyle: StyleTextAdmin(15, Colors.black),
      dataTextStyle: StyleTextAdmin(12, Colors.black),
      columns: [
        DataColumn(label: Text('رمز العنصر')),
        DataColumn(label: Text('اسم العنصر')),
        DataColumn(label: Text('الكمية')),
        DataColumn(label: Text('صورة')),
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
          title: Text(
            title,
            style: StyleTextAdmin(24, ColorPink_100),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: content,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Center(
                child: Text(
                  'إغلاق',
                  style: StyleTextAdmin(20, ColorPink_100),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
