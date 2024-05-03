import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VendorPanelScreen extends StatefulWidget {
  @override
  _VendorPanelScreenState createState() => _VendorPanelScreenState();
}

class _VendorPanelScreenState extends State<VendorPanelScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _discController = TextEditingController();
  File? _imageFile;

  Future<void> _getImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadProduct() async {
    final productName = _nameController.text.trim();
    final productDisc = double.parse(_discController.text.trim());

    if (productName.isEmpty || productDisc <= 0 || _imageFile == null) {
      // Handle invalid input
      return;
    }

    final storage = FirebaseStorage.instance;
    final ref = storage.ref().child('product_images').child('${DateTime.now().millisecondsSinceEpoch}.jpg');

    try {
      await ref.putFile(_imageFile!);
      final imageUrl = await ref.getDownloadURL();

      final productsRef = FirebaseFirestore.instance.collection('products');
      await productsRef.add({
        'name': productName,
        'disc': productDisc,
        'imageUrl': imageUrl,
      });

      // Reset fields after successful upload
      _nameController.clear();
      _discController.clear();
      setState(() {
        _imageFile = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Product added successfully')));
    } catch (e) {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add product')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('vindor Panel - Add Product'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Product Name'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _discController,
              decoration: InputDecoration(labelText: 'Product discrption'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16.0),
            _imageFile == null
                ? ElevatedButton(
                    onPressed: () => _getImage(ImageSource.gallery),
                    child: Text('Select Image'),
                  )
                : Image.file(_imageFile!),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () => _uploadProduct(),
              child: Text('Add Product'),
            ),
          ],
        ),
      ),
    );
  }
}
