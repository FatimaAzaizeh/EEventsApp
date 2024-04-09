import 'package:flutter/material.dart';
import 'package:testtapp/constants.dart';

class FunDesign extends StatefulWidget {
  final String titleAppBar;
  final Widget child;

  const FunDesign({
    Key? key,
    required this.titleAppBar,
    required this.child,
  }) : super(key: key);

  @override
  State<FunDesign> createState() => _FunDesignState();
}

class _FunDesignState extends State<FunDesign> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(0, 255, 255, 255),
      appBar: CustomAppBar(
        /*   title: Text('3D AppBar Example'),
        ),(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(30.0),
            ),
          ),*/
        title: Center(
          child: Text(
            widget.titleAppBar,
            style: StyleTextAdmin(20, Colors.black),
          ),
        ),
        //  backgroundColor: kColor2
        // AdminButtonColor, // Assuming AdminButtonColor is defined
      ),
      body: Center(
          child: Container(
        width: 600,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: widget.child,
        ),
      )),
    );
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget title;

  CustomAppBar({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(topRight: Radius.circular(30.0)),
        color: kColor2, // AppBar background color
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2), // Shadow color
            spreadRadius: 4,
            blurRadius: 6,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: AppBar(
        backgroundColor: Colors.transparent, // Make AppBar transparent
        elevation: 0, // Remove AppBar's default shadow
        title: title,
        centerTitle: true,
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
