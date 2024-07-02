import 'package:flutter/material.dart';

class EntryItem extends StatelessWidget {
  final String entry;
  final int colorCode;

  const EntryItem({super.key, required this.entry, required this.colorCode});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      color: Colors.amber[colorCode],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Center(
            child: Text('Entry $entry'),
          ),
        ],
      ),
    );
  }
}
