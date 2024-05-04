import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ImageListScreen extends StatefulWidget {
  @override
  _ImageListScreenState createState() => _ImageListScreenState();
}

class _ImageListScreenState extends State<ImageListScreen> {
  List<String> imageUrls = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchImages();
  }

  Future<void> _fetchImages() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Initialize Firebase Storage instance
      final FirebaseStorage storage = FirebaseStorage.instance;

      // Reference to the root directory of Firebase Storage
      final Reference ref = storage.ref().child('uploads');
      // List all items (files and sub-directories) in Firebase Storage root directory
      final ListResult result = await ref.listAll();

      // Iterate through each item in the result
      for (final Reference itemRef in result.items) {
        // Get download URL for each image
        final String url = await itemRef.getDownloadURL();
        setState(() {
          imageUrls.add(url);
        });
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching images: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image List'),
      ),
      body: isLoading
          ? Center(
              child: SpinKitCircle(
                color: Colors.blue,
                size: 50.0,
              ),
            )
          : ListView.builder(
              itemCount: imageUrls.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Image.network(imageUrls[index]),
                );
              },
            ),
    );
  }
}
