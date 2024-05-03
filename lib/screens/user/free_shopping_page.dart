import 'package:flutter/material.dart';

class FreeShopping extends StatelessWidget {
  static const String screenRoute = 'free_shopping';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: SafeArea(
          child: SingleChildScrollView(
            // Allows scrolling if content overflows
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.stretch, // Stretches children horizontally
              children: [
                GridView.count(
                  // Creates a grid layout with specified column count
                  crossAxisCount: 3,
                  shrinkWrap:
                      true, // Allows the GridView to shrink-wrap its content
                  physics:
                      const NeverScrollableScrollPhysics(), // Disables scrolling within the GridView
                  children: const [
                    CustomNeonButton(
                      icon: Icons.place,
                      title: 'اماكن',
                      color: Colors.blue,
                    ),
                    CustomNeonButton(
                      icon: Icons.home,
                      title: 'ديكور',
                      color: Colors.orange,
                    ),
                    CustomNeonButton(
                      icon: Icons.camera_alt,
                      title: 'تصوير',
                      color: Colors.purple,
                    ),
                    CustomNeonButton(
                      icon: Icons.restaurant,
                      title: 'طعام',
                      color: Colors.green,
                    ),
                    CustomNeonButton(
                      icon: Icons.card_giftcard,
                      title: 'دعوات',
                      color: Colors.yellow,
                    ),
                    CustomNeonButton(
                      icon: Icons.cake,
                      title: 'حفلات',
                      color: Colors.pink,
                    ),
                    CustomNeonButton(
                      icon: Icons.format_paint,
                      title: 'تنسيق',
                      color: Colors.teal,
                    ),
                    CustomNeonButton(
                      icon: Icons.people,
                      title: 'جلسات',
                      color: Colors.red,
                    ),
                    CustomNeonButton(
                      icon: Icons.add,
                      title: 'ضايفة',
                      color: Colors.cyan,
                    ),
                    CustomNeonButton(
                      icon: Icons.videogame_asset,
                      title: 'العاب',
                      color: Colors.deepOrange,
                    ),
                    CustomNeonButton(
                      icon: Icons.music_note,
                      title: 'زفة',
                      color: Colors.indigo,
                    ),
                    CustomNeonButton(
                      icon: Icons.cake,
                      title: 'حلويات',
                      color: Color.fromARGB(255, 170, 125, 192),
                    ),
                    CustomNeonButton(
                      icon: Icons.cake,
                      title: 'كيك',
                      color: Color.fromARGB(255, 121, 169, 197),
                    ),
                    CustomNeonButton(
                      icon: Icons.card_giftcard,
                      title: 'توزيعات',
                      color: Colors.amber,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomNeonButton extends StatefulWidget {
  final IconData icon; // Icon for the button
  final String title; // Title or label for the button
  final Color color; // Color for the button

  const CustomNeonButton({
    Key? key,
    required this.icon,
    required this.title,
    required this.color,
  }) : super(key: key);

  @override
  _CustomNeonButtonState createState() =>
      _CustomNeonButtonState(); // Creates state for the CustomNeonButton
}

class _CustomNeonButtonState extends State<CustomNeonButton> {
  bool _isPressed = false; // State variable to track button press state

  @override
  Widget build(BuildContext context) {
    // Builds the visual representation of the CustomNeonButton
    return InkWell(
      // InkWell for tap interaction
      onTap: () => setState(() =>
          _isPressed = !_isPressed), // Toggles _isPressed state when tapped
      child: Container(
        decoration: BoxDecoration(
          // Decoration for the button container
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
              color: widget
                  .color), // Border color based on widget's color property
        ),
        padding: const EdgeInsets.all(8.0), // Padding for the button content
        margin: const EdgeInsets.all(4.0), // Margin around the button
        child: Column(
          // Organizes content vertically within the button
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              // Icon widget for the button
              widget.icon, // Icon based on widget's icon property
              color: _isPressed
                  ? Colors.white
                  : widget.color, // Icon color changes when pressed
              size: 24.0,
            ),
            const SizedBox(height: 4.0), // Vertical spacing
            Text(
              // Text widget for the button
              widget.title, // Text based on widget's title property
              style: TextStyle(
                fontSize: 12.0,
                color: _isPressed
                    ? Colors.white
                    : widget.color, // Text color changes when pressed
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      splashColor: widget.color.withOpacity(1), // Splash color when tapped
      borderRadius:
          BorderRadius.circular(10.0), // Border radius for the InkWell
    );
  }
}
