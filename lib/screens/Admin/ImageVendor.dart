import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ImageReaderScreen extends StatefulWidget {
  @override
  _ImageReaderScreenState createState() => _ImageReaderScreenState();
}

class _ImageReaderScreenState extends State<ImageReaderScreen> {
  List<String> imageUrls = [];

  @override
  void initState() {
    super.initState();
    fetchImageUrls();
  }

  Future<void> fetchImageUrls() async {
    try {
      final ListResult result = await FirebaseStorage.instance.ref().listAll();

      for (final Reference ref in result.items) {
        final imageUrl = await ref.getDownloadURL();
        setState(() {
          imageUrls.add(imageUrl);
        });
      }
    } catch (e) {
      print('Error fetching image URLs: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Reader'),
      ),
      body: ListView.builder(
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.network(
              imageUrls[index],
              width: 300,
              height: 300,
              fit: BoxFit.cover,
            ),
          );
        },
      ),
    );
  }
}
