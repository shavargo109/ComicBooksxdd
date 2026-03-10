import 'package:flutter/material.dart';
import 'episodelist.dart';
import 'package:url_launcher/url_launcher.dart';
import '../helpers/webscrap.dart';
import '../helpers/loaddata.dart';

class BookItem extends StatefulWidget {
  final Book book;
  final int colorCode;
  final bool isInterested;
  final bool isReadingMode;
  final bool isStored;

  const BookItem(
      {super.key,
      required this.book,
      required this.colorCode,
      required this.isInterested,
      required this.isReadingMode,
      required this.isStored});

  @override
  State<BookItem> createState() => _BookItemState();
}

class _BookItemState extends State<BookItem> {
  late Color? _buttonColor;
  bool _hasColorChanged = false;

  @override
  void initState() {
    super.initState();
    widget.isReadingMode
        ? _buttonColor = Colors.green[widget.colorCode]
        : _buttonColor = Colors.cyan[widget.colorCode];
  }

  @override
  void didUpdateWidget(BookItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    _resetColor();
  }

  void _resetColor() {
    if (!_hasColorChanged) {
      widget.isReadingMode
          ? _buttonColor = Colors.green[widget.colorCode]
          : _buttonColor = Colors.cyan[widget.colorCode];
    }
  }

  void _changeColor(bool isInterested) {
    if (!_hasColorChanged && isInterested) {
      setState(() {
        _buttonColor = Colors.red[widget.colorCode];
        _hasColorChanged = true;
      });
    }
  }

  void _handleTap(bool isInterested) async {
    _changeColor(isInterested);

    if (isInterested) {
      await LoadData().writeMessage(widget.book);
    } else {
      // show a dialog to confirm delete the book
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          content:
              Text("Are you sure you want to delete '${widget.book.title}'?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                "DELETE",
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
      if (confirm == null || !confirm) {
      } else if (confirm) {
        await LoadData().deleteMessage(widget.book.code);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    Color? bgColor = isDarkTheme
        ? Colors.blueGrey[widget.colorCode + 800]
        : Colors.amber[widget.colorCode];
    Color? colorcolor = isDarkTheme ? Colors.blueGrey : Colors.white;
    String text = widget.isInterested ? 'Interested!' : 'Delete';
    if (widget.isStored) {
      _changeColor(true);
    }
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
                            future: WebScrap().fetchEpisode(widget.book.code),
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
