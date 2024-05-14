import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class ManageItemScreen extends StatefulWidget {
  static const String id = "manage-item";

  @override
  _ManageItemScreenState createState() => _ManageItemScreenState();
}

class _ManageItemScreenState extends State<ManageItemScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _productDescriptionController = TextEditingController();
  final TextEditingController _productPriceController = TextEditingController();
  String _selectedCategory = '';
  Uint8List? _imageBytes;
  late String _fileName = '';

  Future<void> pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null) {
      setState(() {
        _imageBytes = result.files.first.bytes;
        _fileName = result.files.first.name ?? '';
      });
    } else {
      print("No image selected");
    }
  }

  Future<void> _saveProductToFirebase() async {
    if (_formKey.currentState!.validate() && _imageBytes != null && _selectedCategory.isNotEmpty) {
      try {
        String productName = _productNameController.text.trim();
        String productDescription = _productDescriptionController.text.trim();
        double productPrice = double.parse(_productPriceController.text.trim());

        // Upload image to Firebase Storage
        Reference storageRef = FirebaseStorage.instance.ref().child('product_images').child(_fileName);
        UploadTask uploadTask = storageRef.putData(_imageBytes!);
        TaskSnapshot taskSnapshot = await uploadTask;
        String imageUrl = await taskSnapshot.ref.getDownloadURL();

        // Save product info to Firestore
        await FirebaseFirestore.instance.collection('products').add({
          'name': productName,
          'description': productDescription,
          'price': productPrice,
          'category': _selectedCategory,
          'image_url': imageUrl,
          'timestamp': Timestamp.now(),
        });

        // Reset form after saving
        _productNameController.clear();
        _productDescriptionController.clear();
        _productPriceController.clear();
        _selectedCategory = '';
        setState(() {
          _imageBytes = null;
          _fileName = '';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Product saved successfully!'),
            duration: Duration(seconds: 2),
          ),
        );
      } catch (e) {
        print('Error saving product: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save product. Please try again.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Product'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              GestureDetector(
                onTap: pickImage,
                child: Container(
                  height: 200,
                  width: 200,
                  decoration: BoxDecoration(
                    color: Colors.blueGrey,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue, width: 2),
                  ),
                  child: _imageBytes != null
                      ? Image.memory(
                          _imageBytes!,
                          fit: BoxFit.cover,
                        )
                      : Center(
                          child: Icon(
                            Icons.file_upload,
                          ),
                        ),
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _productNameController,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Enter product name";
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: "Product Name",
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _productDescriptionController,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Enter product description";
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: "Description",
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _productPriceController,
                validator: (value) {
                  if (value!.isEmpty || double.tryParse(value) == null) {
                    return "Enter valid product price";
                  }
                  return null;
                },
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: "Price",
                ),
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                onChanged: (newValue) {
                  setState(() {
                    _selectedCategory = newValue!;
                  });
                },
                items: <String>['Category A', 'Category B', 'Category C'] // Replace with your category list
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: "Category",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Select a category";
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _saveProductToFirebase,
                    child: Text("Save"),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      _productNameController.clear();
                      _productDescriptionController.clear();
                      _productPriceController.clear();
                      _selectedCategory = '';
                      setState(() {
                        _imageBytes = null;
                        _fileName = '';
                      });
                    },
                    child: Text("Cancel"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
