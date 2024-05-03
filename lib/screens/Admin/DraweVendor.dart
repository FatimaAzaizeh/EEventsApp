import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:testtapp/constants.dart';
import 'package:testtapp/models/Vendor.dart';
import 'package:testtapp/widgets/textfield_design.dart';

class DrawerVendor extends StatefulWidget {
  const DrawerVendor({super.key});

  @override
  State<DrawerVendor> createState() => _DrawerVendorState();
}

final TextEditingController _emailController = TextEditingController();

final TextEditingController _passwordController = TextEditingController();
final TextEditingController _commercialName = TextEditingController();
final TextEditingController _socialMedia = TextEditingController();
final TextEditingController _description = TextEditingController();
late String email;
late String socialMedia;
late String CommercialName;
late String description;
late String password;
bool showSpinner = false;

class _DrawerVendorState extends State<DrawerVendor> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ModalProgressHUD(
      inAsyncCall: showSpinner,
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          // Important: Remove any padding from the ListView.

          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color.fromARGB(255, 239, 182, 178),
                    Color.fromARGB(255, 242, 207, 137),
                  ],
                ),
              ),
              child: Text(
                'هل تود تسجيل الدخول كمنظم؟',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                    CustomTextField(
                      hintText: 'الإسم التجاري',
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (value) {
                        CommercialName = value;
                      },
                      obscureText: false,
                      TextController: _commercialName,
                    ),
                    SizedBox(height: 8),
                    CustomTextField(
                      hintText: 'ادخال البريد الالكتروني',
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (value) {
                        email = value;
                      },
                      obscureText: false,
                      TextController: _emailController,
                    ),
                    SizedBox(height: 8),
                    CustomTextField(
                      hintText: 'رابط التواصل الاجتماعي',
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (value) {
                        socialMedia = value;
                      },
                      obscureText: false,
                      TextController: _socialMedia,
                    ),
                    SizedBox(height: 8),
                    CustomTextField(
                      hintText: 'أدخال كلمة المرور',
                      keyboardType: TextInputType.visiblePassword,
                      onChanged: (value) {
                        password = value;
                      },
                      obscureText: true,
                      TextController: _passwordController,
                    ),
                    SizedBox(height: 8),
                    CustomTextField(
                      hintText: 'كيف تعتقد أن عملك سيضيف قيمة إلى إييفينتس؟',
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (value) {
                        description = value;
                      },
                      obscureText: false,
                      TextController: _description,
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      child: Text('تحميل صور'),
                    ),
                    SizedBox(height: 20),
                    SizedBox(height: 8),
                    Container(
                      width: double.maxFinite,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              kColor1), // Set background color
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  20.0), // Set border radius
                            ),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            showSpinner = true;
                          });
                          // Handle sign up logic

                          Vendor vendorNew = new Vendor(
                              CommercialName: _commercialName.text,
                              email: _emailController.text,
                              socialMedia: _socialMedia.text,
                              description: _description.text,
                              state: false);
                          vendorNew.addToFirestore();

                          _commercialName.clear();
                          _emailController.clear();
                          _passwordController.clear();
                          _socialMedia.clear();
                          _description.clear();
                          setState(() {
                            showSpinner = false;
                          });
                        },
                        child: Text('تقديم الطلب '),
                      ),
                    ),
                  ])),
            ),
            Positioned(
              bottom: 0,
              child: Container(
                height: 150,
                width: double.maxFinite,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/Vendor.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            )
          ]),
    ));
  }
}
