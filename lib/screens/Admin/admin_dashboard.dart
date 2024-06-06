import 'package:flutter/material.dart';
import 'package:testtapp/constants.dart';

class HomePageAdmin extends StatefulWidget {
  @override
  _HomePageAdminState createState() => _HomePageAdminState();
}

class _HomePageAdminState extends State<HomePageAdmin> {
  List<String> _buttonTexts = ['نظره عامه', 'مهام الاداره', 'Eevents نصيحة'];
  List<String> _messages = [
    ' ماذا يعني ان تكون مسؤول في تطبيقنا :'
        ' هو ان تكون المنظم للمناسبه حسب الخدمه التي يريدها الزبون عن طريق استخدام تطبيقنا الذي يتيح الابداع لتصميم مناسبه فريده من نوعها ',
    'سوف تكون مسؤول عن تنظيم شكل التطبيق لدى المستخدم واعطاء اذونات للبائعين بستخدام التطبيق او لا',
    'نظم المناسبات بشغف'
  ];

  String _displayText =
      'هو ان تكون المنظم للمناسبه حسب الخدمه التي يريدها الزبون عن طريق استخدام تطبيقنا الذي يتيح الابداع لتصميم مناسبه فريده من نوعها :ماذا يعني ان تكون مسؤول في تطبيقنا';

  void _updateText(int index) {
    setState(() {
      _displayText = _messages[index];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(15, 240, 238, 238),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_buttonTexts.length, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      _updateText(index);
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(ColorPink_100),
                      padding: MaterialStateProperty.all<EdgeInsets>(
                          EdgeInsets.symmetric(
                              vertical: 16.0, horizontal: 24.0)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                    ),
                    child: Text(
                      _buttonTexts[index],
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }),
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Color.fromARGB(255, 235, 181, 163)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _displayText,
                style: TextStyle(fontSize: 24),
              ),
            ),
            SizedBox(height: 30),
            Container(
              width: 500,
              height: 200,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/Vendor.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
