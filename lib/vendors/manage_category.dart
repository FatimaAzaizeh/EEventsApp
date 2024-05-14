import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class ManageCategories extends StatefulWidget {
  static const String id = "manage-category";

  @override
  _ManageCategoriesState createState() => _ManageCategoriesState();
}

class _ManageCategoriesState extends State<ManageCategories> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _catName = TextEditingController();
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

  Future<void> _saveCategory() async {
    if (_formKey.currentState!.validate() && _imageBytes != null) {
      try {
        String categoryName = _catName.text.trim();

        // Upload image to Firebase Storage (not implemented here)

        // Save category info to Firestore
        await FirebaseFirestore.instance.collection('categories').add({
          'name': categoryName,
          'image': _fileName, // Store the image filename or URL
        }
        );

        // Reset form after saving
        _catName.clear();
        setState(() {
          _imageBytes = null;
          _fileName = '';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Category saved successfully!'),
            duration: Duration(seconds: 2),
          ),
        );
      } catch (e) {
        print('Error saving category: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save category. Please try again.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Add Category:",
              style: TextStyle(
                color: Colors.blue,
                fontSize: 30,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Row(
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
                  SizedBox(
                    width: 10,
                  ),
                  Column(
                    children: [
                      Container(
                        width: 200,
                        child: TextFormField(
                          controller: _catName,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Enter category Name";
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: "Enter category name",
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          TextButton(
                            onPressed: _saveCategory,
                            child: Text("Save"),
                          ),
                          TextButton(
                            onPressed: () {
                              _catName.clear();
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
