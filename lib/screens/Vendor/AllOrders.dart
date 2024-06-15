import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:testtapp/constants.dart';
import 'package:testtapp/models/Orders.dart';
import 'package:testtapp/screens/Admin/widgets_admin/imageHover.dart';
// Only import emailjs.dart once
import 'package:emailjs/emailjs.dart';

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
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/signin.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SingleChildScrollView(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('orders').snapshots(),
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
                    child: Text('لا يوجد اي طلب'),
                  );
                }

                // Filter the documents to include only those for the current vendor
                var filteredDocs = snapshot.data!.docs.where((doc) {
                  Map<String, dynamic> data =
                      doc.data() as Map<String, dynamic>;
                  Map<String, dynamic> vendors = data['vendors'] ?? {};
                  return vendors.values.any(
                      (vendor) => vendor['vendor_id'] == widget.currentUserUID);
                }).toList();

                if (filteredDocs.isEmpty) {
                  return Center(
                    child: Text('لا يوجد طلبات لهذا البائع'),
                  );
                }

                return SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
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
                          DataColumn(label: Text('رقم الطلب')),
                          DataColumn(label: Text('تايخ انشاء الطلب')),
                          DataColumn(label: Text('تاريخ توصيل الطلب')),
                          DataColumn(label: Text('حالة الطلب')),
                          DataColumn(label: Text('السعر')),
                          DataColumn(label: Text('تفاصيل المنتج')),
                        ],
                        rows: filteredDocs.asMap().entries.map((entry) {
                          var index = entry.key;
                          var doc = entry.value;
                          Map<String, dynamic> data =
                              doc.data() as Map<String, dynamic>;
                          var vendorEntry = data['vendors'].entries.firstWhere(
                                (entry) =>
                                    entry.value['vendor_id'] ==
                                    widget.currentUserUID,
                              );
                          var vendorData = vendorEntry.value;

                          return DataRow(
                            cells: [
                              DataCell(Text(data['order_id'] ?? 'N/A')),
                              DataCell(Text(
                                  _parseTimestamp(vendorData['created_at']) ??
                                      'N/A')),
                              DataCell(Text(
                                  _parseTimestamp(vendorData['deliver_at']) ??
                                      'N/A')),
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
                                      var orderStatusData = statusSnapshot.data!
                                          .data() as Map<String, dynamic>;
                                      var orderStatusValue =
                                          orderStatusData['description'];

                                      return Padding(
                                        padding: const EdgeInsets.only(
                                            top: 4, bottom: 4),
                                        child: Container(
                                          width: 120,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: const Color.fromARGB(
                                                      165, 255, 255, 255)
                                                  .withOpacity(0.5),
                                              width: 2,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            color: getColorForOrderStatus(
                                                orderStatusValue),
                                          ),
                                          child: FutureBuilder<QuerySnapshot>(
                                            future: FirebaseFirestore.instance
                                                .collection('order_status')
                                                .get(),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                                return CircularProgressIndicator();
                                              } else if (snapshot.hasError) {
                                                return Text(
                                                    'Error fetching data');
                                              } else {
                                                var documents =
                                                    snapshot.data!.docs;
                                                List<String> orderStatusList =
                                                    documents.map((doc) {
                                                  var orderStatusData = doc
                                                          .data()
                                                      as Map<String, dynamic>;
                                                  return orderStatusData[
                                                      'description'] as String;
                                                }).toList();
                                                bool isDropdownEnabled =
                                                    isOrderStatusComplete(
                                                        orderStatusValue); // Set this based on your condition
                                                return DropdownButton<String>(
                                                  alignment: Alignment.center,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          30.0),
                                                  dropdownColor: Colors.white,
                                                  style: StyleTextAdmin(
                                                      14, AdminButton),
                                                  value: orderStatusValue,
                                                  items: orderStatusList
                                                      .map((String value) {
                                                    return DropdownMenuItem<
                                                        String>(
                                                      value: value,
                                                      child: Text(value),
                                                    );
                                                  }).toList(),
                                                  onChanged: isDropdownEnabled
                                                      ? (String?
                                                          newValue) async {
                                                          if (newValue !=
                                                              null) {
                                                            int newStatusId =
                                                                orderStatusList
                                                                        .indexOf(
                                                                            newValue) +
                                                                    1;
                                                            DocumentReference
                                                                newStatusIdRef =
                                                                FirebaseFirestore
                                                                    .instance
                                                                    .collection(
                                                                        'order_status')
                                                                    .doc(newStatusId
                                                                        .toString());
                                                            setState(() async {
                                                              dropDownValues[
                                                                      index] =
                                                                  newValue;

                                                              await FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'orders')
                                                                  .doc(doc.id)
                                                                  .update({
                                                                'vendors.${vendorEntry.key}.order_status_id':
                                                                    newStatusIdRef,
                                                              });
                                                              final docSnapshot =
                                                                  await FirebaseFirestore
                                                                      .instance
                                                                      .collection(
                                                                          'users')
                                                                      .doc(data[
                                                                          'user_id'])
                                                                      .get();

                                                              String useremail =
                                                                  docSnapshot
                                                                          .data()?[
                                                                      'email'];

                                                              //sendEmail(useremail);
                                                            });
                                                          }
                                                        }
                                                      : null,
                                                );
                                              }
                                            },
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                              DataCell(Text(
                                  vendorData['price'].toString() + ' د.أ  ' ??
                                      'N/A')),
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
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text(
                                          'تفاصيل الطلب',
                                          style:
                                              StyleTextAdmin(22, ColorPink_100),
                                        ),
                                        content: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: FutureBuilder<List<DataRow>>(
                                            future: _buildItemDetails(
                                                vendorData?['vendor_id_items']),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                                return Center(
                                                    child:
                                                        CircularProgressIndicator());
                                              } else if (snapshot.hasError) {
                                                return Center(
                                                    child: Text(
                                                        'Error: ${snapshot.error}'));
                                              } else if (!snapshot.hasData ||
                                                  snapshot.data!.isEmpty) {
                                                return Center(
                                                    child: Text(
                                                        'لا يوجد بيانات لعرضها'));
                                              } else {
                                                return DataTable(
                                                  headingTextStyle:
                                                      StyleTextAdmin(
                                                          16, Colors.black),
                                                  dataTextStyle: StyleTextAdmin(
                                                      14, AdminButton),
                                                  columns: [
                                                    DataColumn(
                                                        label:
                                                            Text('رمز المنتج')),
                                                    DataColumn(
                                                        label:
                                                            Text('اسم المنتج')),
                                                    DataColumn(
                                                        label: Text('الكمية')),
                                                    DataColumn(
                                                        label: Text('الصورة')),
                                                  ],
                                                  rows: snapshot.data!,
                                                );
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                    );

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
                );
              },
            ),
          ),
        ],
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

  Future<List<DataRow>> _buildItemDetails(Map<dynamic, dynamic>? items) async {
    if (items == null || items.isEmpty) {
      return [
        DataRow(cells: [DataCell(Text('لا يوجد طلبات'))])
      ];
    }

    List<DataRow> itemRows = [];

    for (var entry in items.entries) {
      var value = entry.value;
      try {
        String imageUrl = await getImageUrl(
            value['item_code']); // Await inside async function

        // Assuming ImageHoverWidget is properly defined and used
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
      } catch (e) {
        // Handle errors if getImageUrl fails
        itemRows.add(
          DataRow(cells: [
            DataCell(Text('Error loading image')),
          ]),
        );
      }
    }

    return itemRows;
  }
}
