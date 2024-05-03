import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:firebase_storage/firebase_storage.dart';

class VendorPanelScreen extends StatefulWidget {
  static const String screenRoute = 'VendorPanelScreen';

  @override
  _VendorPanelScreenState createState() => _VendorPanelScreenState();
}

class _VendorPanelScreenState extends State<VendorPanelScreen> {
  Uint8List? _selectedImage;
  String? _imageName; // Store the original file name here
  String? _imageUrl;

  Future<void> _pickImage() async {
    final mediaData = await ImagePickerWeb.getImageInfo;

    if (mediaData != null) {
      setState(() {
        _selectedImage = mediaData.data!;
        _imageName = mediaData.fileName; // Get the original file name
      });

      // Upload the selected image to Firebase Storage
      await _uploadImageToFirebase(mediaData.data!);
    }
  }

  Future<void> _uploadImageToFirebase(Uint8List imageBytes) async {
    if (_imageName == null) {
      print('Image name is null, cannot upload');
      return;
    }

    try {
      final storageRef = FirebaseStorage.instance.ref('images/$_imageName');

      await storageRef.putData(imageBytes);

      final downloadUrl = await storageRef.getDownloadURL();
      setState(() {
        _imageUrl = downloadUrl;
      });

      print('Image uploaded to Firebase Storage: $_imageUrl');

      // Here you can save the _imageUrl to Firestore or perform other operations
      // For example:
      // FirebaseFirestore.instance.collection('images').add({
      //   'imageUrl': _imageUrl,
      //   'imageName': _imageName,
      // });
    } catch (e) {
      print('Error uploading image to Firebase Storage: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Picker and Uploader'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (_selectedImage != null)
              Image.memory(
                _selectedImage!,
                width: 300,
                height: 300,
                fit: BoxFit.contain,
              )
            else
              Text('No image selected'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Select Image'),
            ),
            SizedBox(height: 20),
            if (_imageUrl != null)
              Column(
                children: [
                  Text('Uploaded Image:'),
                  SizedBox(height: 10),
                  Image.network(
                    _imageUrl!,
                    width: 300,
                    height: 300,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
