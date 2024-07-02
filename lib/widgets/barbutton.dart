import 'package:flutter/material.dart';

class BarButton extends StatefulWidget {
  final String entry;
  final int colorCode;

  const BarButton({super.key, required this.entry, required this.colorCode});
  @override
  State<BarButton> createState() => _BarButtonState();
}

class _BarButtonState extends State<BarButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      color: Colors.amber[widget.colorCode],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Center(
            child: Text('Entry $widget.entry'),
          ),
        ],
      ),
    );
  }
}
