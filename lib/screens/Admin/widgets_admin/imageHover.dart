import 'package:flutter/material.dart';

class ImageHoverWidget extends StatefulWidget {
  final String imageUrl;

  const ImageHoverWidget({Key? key, required this.imageUrl}) : super(key: key);

  @override
  _ImageHoverWidgetState createState() => _ImageHoverWidgetState();
}

class _ImageHoverWidgetState extends State<ImageHoverWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _isHovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          _isHovered = false;
        });
      },
      child: SizedBox(
        width: 100,
        height: 100,
        child: GestureDetector(
          onTap: _isHovered
              ? () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        content: SizedBox(
                          width: 200,
                          height: 200,
                          child: Image.network(
                            widget.imageUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  );
                }
              : null,
          child: Image.network(
            widget.imageUrl,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
