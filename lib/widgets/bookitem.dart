import 'package:flutter/material.dart';
import 'package:tutorial/widgets/episodelist.dart';
import 'package:url_launcher/url_launcher.dart';
import '../helpers/webscrap.dart';
import '../helpers/loaddata.dart';

class BookItem extends StatefulWidget {
  final Book book;
  final int colorCode;
  final bool isInterested;
  final bool isReadingMode;

  const BookItem({
    super.key,
    required this.book,
    required this.colorCode,
    required this.isInterested,
    required this.isReadingMode,
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
    Color? colorcolor = isDarkTheme ? Colors.blueGrey : Colors.white;
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
                  if (widget.isReadingMode) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Scaffold(
                          backgroundColor: colorcolor,
                          body: FutureBuilder(
                            future: fetchEpisode(widget.book.code),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              } else if (snapshot.hasError) {
                                return Center(
                                    child: Text("Error: ${snapshot.error}"));
                              } else if (!snapshot.hasData ||
                                  snapshot.data!.isEmpty) {
                                return const Center(
                                    child: Text(
                                        textAlign: TextAlign.center,
                                        "No episode data found."));
                              } else {
                                final episodes = snapshot.data!;
                                return ListView.builder(
                                  key: ObjectKey((episodes[0])),
                                  itemCount: episodes.length,
                                  itemBuilder: (context, index) {
                                    final episode = episodes[index];
                                    final colorCode =
                                        index % 2 == 0 ? 100 : 300;
                                    return Episodelist(
                                        colorCode: colorCode,
                                        episode: episode.episode,
                                        link: episode.link,
                                        em: episode.em);
                                  },
                                );
                              }
                            },
                          ),
                        ),
                      ),
                    );
                  } else {
                    launchUrl(Uri.parse(Book.getURL(widget.book.code)));
                  }
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