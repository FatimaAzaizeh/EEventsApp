/*
import 'package:flutter/material.dart';

class ImageScroll extends StatefulWidget {
  @override
  _ImageScrollState createState() => _ImageScrollState();
}

class _ImageScrollState extends State<ImageScroll> {
  // final FirebaseStorage _storage = FirebaseStorage.instance;
  List<String> imageUrls = [];

  @override
  void initState() {
    super.initState();
    _loadImageUrls();
  }

  Future<void> _loadImageUrls() async {
    List<String> urls = await _getImageUrlsFromFirebase();
    setState(() {
      imageUrls = urls;
    });
  }

  Future<List<String>> _getImageUrlsFromFirebase() async {
    try {
      //Reference storageRef = _storage.ref();
      // ListResult result = await storageRef.listAll();
  List<String> urls = await Future.wait(
          //result.items.map((item) => item.getDownloadURL()),
          );      return urls;
    } catch (e) {
      print('Error loading images: $e');
      return []; // Return empty list in case of error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Firebase Image Gallery'),
      ),
      body: Container(
        height: 200,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(imageUrls.length, (index) {
              double parallaxOffset = 0.5; // Adjust parallax effect speed
              return Padding(
                padding: EdgeInsets.all(8.0),
                child: Transform.translate(
                  offset: Offset(3, 4),
                  child: Image.network(
                    imageUrls[index],
                    width: 300,
                    fit: BoxFit.cover,
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
*/