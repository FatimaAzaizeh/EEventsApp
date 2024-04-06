import 'package:flutter/material.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';

class ImageScroll extends StatelessWidget {
  const ImageScroll({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: double.maxFinite,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: const Color.fromARGB(255, 249, 249, 248)),
        height: 50,
        child: ImageSlideshow(
          /// Width of the [ImageSlideshow].
          width: 10,

          /// Height of the [ImageSlideshow].
          height: 5,

          /// The page to show when first creating the [ImageSlideshow].
          initialPage: 0,

          /// The color to paint the indicator.
          indicatorColor: Colors.blue,

          /// The color to paint behind th indicator.
          indicatorBackgroundColor: Colors.grey,

          /// The widgets to display in the [ImageSlideshow].
          /// Add the sample image file into the images folder
          children: [
            Container(
              child: Image.asset(
                'assets/images/bunnyy.png',
                // fit: BoxFit.fill,
              ),
            ),
            Image.asset(
              'assets/images/bunnyy.png',
              //fit: BoxFit.fill,
            ),
            Image.asset(
              'assets/images/bunnyy.png',
              //fit: BoxFit.fill,
            ),
          ],

          /// Called whenever the page in the center of the viewport changes.
          onPageChanged: (value) {
            print('Page changed: $value');
          },

          /// Auto scroll interval.
          /// Do not auto scroll with null or 0.
          autoPlayInterval: 0,

          /// Loops back to first slide.
          isLoop: false,
        ),
      ),
    );
  }
}
