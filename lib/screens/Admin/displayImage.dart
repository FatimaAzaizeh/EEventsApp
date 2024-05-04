import 'package:flutter/material.dart';

class DisplayImageFromFirestore extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Display Image from Firestore'),
      ),
      body: Container(
        child: Image.network(
          'https://firebasestorage.googleapis.com/v0/b/eeventsapp-183f1.appspot.com/o/uploads%2Fmocking.png?alt=media&token=3b5c8959-8ba0-477e-9cb1-c26de8237100',
        ),
      ),
    );
  }
}
