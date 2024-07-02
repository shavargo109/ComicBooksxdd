import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../helpers/webscrap.dart';
import '../helpers/loaddata.dart';

class BookItem extends StatefulWidget {
  final Book book;
  final int colorCode;
  final bool isInterested;

  const BookItem({
    super.key,
    required this.book,
    required this.colorCode,
    required this.isInterested,
  });

  @override
  State<BookItem> createState() => _BookItemState();
}

class _BookItemState extends State<BookItem> {
  late Color? _buttonColor;
  bool _hasColorChanged = false;

  @override
  void initState() {
    super.initState();
    _buttonColor = Colors.cyan[widget.colorCode];
  }

  @override
  void didUpdateWidget(BookItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    _resetColor();
  }

  void _resetColor() {
    _buttonColor = Colors.cyan[widget.colorCode];
    _hasColorChanged = false;
  }

  void _changeColor() {
    if (!_hasColorChanged) {
      setState(() {
        _buttonColor = Colors.green[widget.colorCode];
        _hasColorChanged = true;
      });
    }
  }

  void _handleTap(bool isInterested) {
    _changeColor();
    widget.isInterested
        ? deleteMessage(widget.book.code)
        : writeMessage(widget.book);
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    Color? bgColor = isDarkTheme
        ? Colors.blueGrey[widget.colorCode + 800]
        : Colors.amber[widget.colorCode];
    String text = widget.isInterested ? 'Delete' : 'Interested!';
    return SizedBox(
      height: 101,
      child: Row(
        children: [
          Image.network(
            Book.getCover(widget.book.code),
            fit: BoxFit.fill,
          ),
          Expanded(
            child: Material(
              color: bgColor,
              child: InkWell(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      widget.book.title,
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      widget.book.ep,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                onTap: () {
                  launchUrl(Uri.parse(Book.getURL(widget.book.code)));
                },
              ),
            ),
          ),
          SizedBox(
            width: 80,
            child: Material(
              color: _buttonColor,
              child: InkWell(
                onTap: () => _handleTap(widget.isInterested),
                child: Center(
                  child: Text(
                    textAlign: TextAlign.center,
                    text,
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
// truck