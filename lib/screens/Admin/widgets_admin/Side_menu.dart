import 'package:flutter/material.dart';

class BuildListTile extends StatefulWidget {
  final String title;
  final IconData icon;
  final Function() onPress;
  final int index;

  const BuildListTile({
    Key? key,
    required this.title,
    required this.icon,
    required this.onPress,
    required this.index,
  }) : super(key: key);

  @override
  State<BuildListTile> createState() => _BuildListTileState();
}

class _BuildListTileState extends State<BuildListTile> {
  bool _isSelected = false; // Selected state for the current tile

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.all(10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      leading: Icon(
        widget.icon,
        size: 28,
        color: Colors.black,
        shadows: [BoxShadow(color: Colors.black, offset: Offset(0, 2))],
      ),
      title: Text(
        widget.title,
        style: TextStyle(fontSize: 18, color: Colors.black),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () {
        setState(() {
          _isSelected = !_isSelected; // Toggle the selected state

          widget.onPress();
        });
      },
      selected: _isSelected, // Set the selected state of the tile
      selectedTileColor: Colors.white,
      hoverColor: Colors.white,
    );
  }
}
