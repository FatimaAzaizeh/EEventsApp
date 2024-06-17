import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

//The colors to be used in the app and the required padding space.
//"The main color of the app."
//Purple
const ColorPurple_100 = Color.fromARGB(255, 189, 140, 177);
Color ColorPurple_70 = Color.fromARGB(255, 189, 140, 177).withOpacity(0.7);
Color ColorPurple_50 = Color.fromARGB(255, 189, 140, 177).withOpacity(0.5);
Color ColorPurple_20 = Color.fromARGB(255, 189, 140, 177).withOpacity(0.2);

//Pink
const ColorPink_100 = Color.fromARGB(255, 214, 170, 173);
Color ColorPink_70 = Color.fromARGB(255, 214, 170, 173).withOpacity(0.7);
Color ColorPink_50 = Color.fromARGB(255, 214, 170, 173).withOpacity(0.5);
Color ColorPink_20 = Color.fromARGB(255, 214, 170, 173).withOpacity(0.2);

//Cream
const ColorCream_100 = Color.fromARGB(255, 225, 189, 158);
Color ColorCream_70 = Color.fromARGB(255, 225, 189, 158).withOpacity(0.7);
Color ColorCream_50 = Color.fromARGB(255, 225, 189, 158).withOpacity(0.5);
Color ColorCream_20 = Color.fromARGB(255, 225, 189, 158).withOpacity(0.2);
//"The secondary color of the app."

const kDefaultPadding = 20.0;
//Main color for admin page.

//admin/Vendor  color
const kColorBack = Color.fromARGB(255, 245, 246, 248);
const AdminMenu = Color(0xFFFFFF);
const Color iconColor = Color.fromARGB(255, 194, 207, 224);

const kColorPress = Color.fromARGB(255, 231, 195, 189);
const kColorIcon = Color.fromARGB(255, 222, 164, 162);

const AdminButton = Color.fromARGB(255, 68, 67, 67);

const Color activeColor = Color(0xFF09126C);
const Color textColor1 = Color.fromARGB(255, 104, 118, 125);
const Color textColor2 = Color.fromARGB(255, 106, 124, 125);
const Color googleColor = Color(0xFFDE4B39);
TextStyle StyleTextAdmin(double SizeText, Color colorText) {
  return TextStyle(
      fontFamily: 'Marhey',
      fontSize: SizeText,
      fontWeight: FontWeight.w600,
      color: colorText);
}

Future<void> deleteImageByUrl(String imageUrl) async {
  try {
    // Extract the path from the URL
    final RegExp regExp = RegExp(r'(?<=o/)(.*)(?=\?alt=media)');
    final Match? match = regExp.firstMatch(imageUrl);

    if (match != null) {
      final String imagePath = Uri.decodeFull(match[0]!);

      // Create a reference to the file to delete
      Reference storageReference =
          FirebaseStorage.instance.ref().child(imagePath);

      // Delete the file
      await storageReference.delete();

      print("Image successfully deleted");
    } else {
      print("Invalid image URL");
    }
  } catch (e) {
    print("Error occurred while deleting image: $e");
  }
}

Future<String> getImageUrl(String itemCode, DocumentReference vendorId) async {
  QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
      .instance
      .collection('item')
      .where('item_code', isEqualTo: itemCode)
      .where('vendor_id', isEqualTo: vendorId)
      .get();

  if (snapshot.docs.isNotEmpty) {
    return snapshot.docs.first.data()['image_url'];
  } else {
    return 'https://example.com/default_image.jpg';
  }
}

Color getColorForOrderStatus(String orderStatusValue) {
  Color containerColor;

  switch (orderStatusValue) {
    case "في الانتظار":
      containerColor = Color.fromARGB(255, 210, 105, 30).withOpacity(0.3);
      break;
    case "تم القبول":
      containerColor = Colors.green.withOpacity(0.3);
      break;
    case "تم الرفض":
      containerColor = Colors.red.withOpacity(0.3);
      break;
    case "تم الإلغاء":
      containerColor = Color.fromARGB(255, 185, 92, 80).withOpacity(0.3);
      break;
    case "خارج للتوصيل":
      containerColor = Color.fromARGB(255, 0, 100, 0).withOpacity(0.3);
      break;
    case "تم التوصيل":
      containerColor = Colors.blue.shade200.withOpacity(0.3);
      break;
    default:
      containerColor = Colors.white.withOpacity(0.3).withOpacity(0.3);
  }

  return containerColor;
}

bool isOrderStatusComplete(String orderStatusValue) {
  switch (orderStatusValue) {
    case "في الانتظار":
    case "خارج للتوصيل":
    case "تم القبول":
      return true;
    case "تم الرفض":
    case "تم الإلغاء":
    case "تم التوصيل":
      return false; // Complete
    default:
      return false; // Default to false if status is unknown
  }
}

Color getColorForStatus(String orderStatusValue) {
  Color textColor;

  switch (orderStatusValue) {
    case "فعال":
      textColor = Colors.green;
      break;
    case "نفذ من المخزن":
      textColor = Colors.red;
      break;
    default:
      // Handle any other cases or provide a default color
      textColor = Colors.black; // Example of default color
  }

  return textColor;
}
