import 'package:flutter/material.dart';
import 'package:testtapp/constants.dart';
import 'package:testtapp/screens/Admin/widgets_admin/AlertAddAdmin.dart';
import 'package:testtapp/screens/Admin/widgets_admin/AllAdminView.dart';

class AddItem extends StatefulWidget {
  static const String screenRoute = 'Add_Item';

  @override
  _AddItemState createState() => _AddItemState();
}

class _AddItemState extends State<AddItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      height: double.maxFinite,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'التنظيمات',
                  style: TextStyle(fontSize: 22, color: AdminButton),
                  textDirection: TextDirection.rtl,
                ),
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertAddAdmin(),
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.add,
                        size: 34,
                        color: ColorPurple_100,
                      ),
                      SizedBox(width: 10), // Adjust spacing between icon and text
                      Text(
                        'اضافة تنظيم',
                        style: TextStyle(fontSize: 18, color: AdminButton),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: AllAdminView(),
          ),
        ],
      ),
    );
  }
}
