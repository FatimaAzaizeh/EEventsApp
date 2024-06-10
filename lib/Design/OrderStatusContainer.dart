import 'package:flutter/material.dart';
import 'package:testtapp/constants.dart';

class OrderStatusContainer extends StatelessWidget {
  final String orderStatusValue;

  const OrderStatusContainer({Key? key, required this.orderStatusValue})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color containerColor;

    switch (orderStatusValue) {
      case "في الانتظار":
        containerColor = Color.fromARGB(255, 251, 231, 198).withOpacity(0.5);
        break;
      case "تم القبول":
        containerColor = Color.fromARGB(255, 180, 248, 201).withOpacity(0.3);
        break;
      case "تم الرفض":
        containerColor = Color.fromARGB(255, 185, 92, 80).withOpacity(0.9);
        break;
      case "تم الإلغاء":
        containerColor = Color.fromARGB(255, 185, 92, 80).withOpacity(0.6);
        break;
      case "خارج للتوصيل":
        containerColor = Color.fromARGB(255, 255, 216, 152).withOpacity(0.3);
        break;
      case "تم التوصيل":
        containerColor = Color.fromARGB(255, 255, 174, 187).withOpacity(0.3);
        break;
      default:
        containerColor = Colors.white.withOpacity(0.3);
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black.withOpacity(0.7),
          width: 0.5,
        ),
        borderRadius: BorderRadius.circular(20),
        color: containerColor,
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
