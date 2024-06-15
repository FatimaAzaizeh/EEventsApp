import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:testtapp/constants.dart';

class OrderStatusContainer extends StatelessWidget {
  final String orderStatusValue;

  const OrderStatusContainer({
    Key? key,
    required this.orderStatusValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black.withOpacity(0.7),
          width: 0.5,
        ),
        borderRadius: BorderRadius.circular(20),
        color: getColorForOrderStatus(orderStatusValue),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          orderStatusValue,
          style:
              StyleTextAdmin(12, Colors.black), // Customize the text style here
        ),
      ),
    );
  }
}
