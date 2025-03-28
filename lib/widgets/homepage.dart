import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tutorial/helpers/loaddata.dart';
import '../helpers/webscrap.dart';
import 'bookitem.dart';
import '../main.dart';

class HomePage extends StatefulWidget {
  final bool isReadingMode;

  const HomePage({
    super.key,
    required this.isReadingMode,
  });
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<List<Book>>? _futureBooks;
  int _selectedButtonIndex =
      -1; // Variable to keep track of the selected button
  final ScrollController _scrollController = ScrollController();
  var _showScrollToTop = false; // Controls visibility of scroll-to-top button
  int _totalPage = 0;
  int _currentPage = 0;
  String _value = '';
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.offset > 30) {
        if (!_showScrollToTop) {
          setState(() => _showScrollToTop = true);
        }
      } else {
        if (_showScrollToTop) {
          setState(() => _showScrollToTop = false);
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<List<Book>> fetchBooks(bool isLatest) async {
    return await fetchLatestBooks(isLatest);
  }

  Future<List<Book>> fetchInterestedBooks(bool isLatest) async {
    final books = await fetchLatestBooks(isLatest);
    final data = await readMessage();
    final savedBooks = data['book'] as List<Book>;
    List<Book> interestedBooks = [];
    for (var book in books) {
      for (var savedBook in savedBooks) {
        if (savedBook.code == book.code) {
          interestedBooks.add(book);
          await writeMessage(book);
        }
      }
    }
    return interestedBooks;
  }

  Future<List<Book>> fetchAllTimeBooks() async {
    final data = await readMessage();
    return data['book'] as List<Book>;
  }

  Future<void> _dialogBuilder(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: TextField(
            // obscureText: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Search',
            ),
            onSubmitted: (String value) async {
              Navigator.pop(context);
              int totalpages = await searchResultPage(value);
              setState(() {
                _selectedButtonIndex = 5;
                _currentPage = 1;
                _value = value;
                _totalPage = totalpages;
                _futureBooks = searchResultContent(value, _currentPage);
              });
            },
          ),
        );
      },
    );
  }

  void _asd(int page) {
    setState(() {
      _selectedButtonIndex = 5;
      _currentPage = page;
      print(_currentPage);
      _futureBooks = searchResultContent(_value, _currentPage);
    });
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }

  void _onButtonPressed(int index) {
    setState(() {
      _selectedButtonIndex = index;
      _currentPage = 0;
      switch (index) {
        case 0:
          _futureBooks = fetchInterestedBooks(true);
          break;
        case 1:
          _futureBooks = fetchBooks(true);
          break;
        case 2:
          _futureBooks = fetchBooks(false);
          break;
        case 3:
          _futureBooks = fetchAllTimeBooks();
          break;
        case 4:
          _futureBooks = fetchInterestedBooks(false);
          break;
      }
    });
  }

  ButtonStyle _buttonStyle(int index, GlobalNotifier themeNotifier) {
    bool isSelected = _selectedButtonIndex == index;
    Color primaryColor =
        themeNotifier.isReadingMode ? Colors.green : Colors.blue;
    Color selectedColor =
        isSelected ? primaryColor : Theme.of(context).colorScheme.surface;
    Color unselectedColor =
        isSelected ? Theme.of(context).colorScheme.surface : primaryColor;

    return ButtonStyle(
      foregroundColor: WidgetStateProperty.all<Color>(unselectedColor),
      backgroundColor: WidgetStateProperty.all<Color>(selectedColor),
      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(
            color: selectedColor,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    GlobalNotifier modeNotifier = Provider.of<GlobalNotifier>(context);
    return Scaffold(
        floatingActionButton: _showScrollToTop
            ? Container(
                height: 40,
                width: 40,
                margin: const EdgeInsets.only(bottom: 25),
                child: FloatingActionButton(
                  onPressed: _scrollToTop,
                  backgroundColor: Colors.blueAccent,
                  child: const Icon(
                    Icons.arrow_upward,
                    color: Colors.white,
                    size: 20,
                  ),
                ))
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
        body: Column(
          children: [
            Expanded(
              child: _futureBooks == null
                  ? const Center(
                      child: Image(
                        image: AssetImage('assets/test.gif'),
                      ),
                      // child: Text(
                      // "XDD",
                      // style: TextStyle(
                      //   fontSize: 20.0,
                      // ),
                      // )
                    )
                  : FutureBuilder<List<Book>>(
                      future: _futureBooks,
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
                          if (_selectedButtonIndex == 0 ||
                              _selectedButtonIndex == 4) {
                            return const Center(
                                child: Text(
                                    textAlign: TextAlign.center,
                                    "No interested books saved! Please add your favourite books to the list!"));
                          } else {
                            return const Center(
                                child: Text(
                                    textAlign: TextAlign.center,
                                    "No data found!!"));
                          }
                        } else {
                          final books = snapshot.data!;
                          return ListView.builder(
                            controller: _scrollController,
                            key: ObjectKey(books[0]),
                            itemCount: books.length,
                            itemBuilder: (context, index) {
                              final book = books[index];
                              final colorCode = index % 2 == 0 ? 100 : 300;
                              if (index == books.length - 1 &&
                                  _selectedButtonIndex == 5) {
                                print('wegrthrt');
                                return Column(
                                  children: [
                                    BookItem(
                                      book: book,
                                      colorCode: colorCode,
                                      isInterested: _selectedButtonIndex == 1 ||
                                          _selectedButtonIndex == 2 ||
                                          _selectedButtonIndex == 5,
                                      isReadingMode: widget.isReadingMode,
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: IconButton(
                                              onPressed: _currentPage - 1 == 0
                                                  ? null
                                                  : () {
                                                      _asd(_currentPage - 1);
                                                    },

                                              // onPressed: () =>
                                              //     _asd(_currentPage - 1),
                                              icon:
                                                  const Icon(Icons.arrow_back)),
                                        ),
                                        Expanded(
                                          child: IconButton(
                                              onPressed: _currentPage + 1 >
                                                      _totalPage
                                                  ? null
                                                  : () {
                                                      _asd(_currentPage + 1);
                                                    },
                                              // onPressed: () =>
                                              //     _asd(_currentPage + 1),
                                              icon: const Icon(
                                                  Icons.arrow_forward)),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              } else {
                                return BookItem(
                                  book: book,
                                  colorCode: colorCode,
                                  isInterested: _selectedButtonIndex == 1 ||
                                      _selectedButtonIndex == 2 ||
                                      _selectedButtonIndex == 5,
                                  isReadingMode: widget.isReadingMode,
                                );
                              }
                            },
                          );
                        }
                      },
                    ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: IconButton.filled(
                    style: _buttonStyle(0, modeNotifier),
                    icon: const Icon(Icons.thumb_up_outlined),
                    selectedIcon: const Icon(Icons.thumb_up),
                    onPressed: () => _onButtonPressed(0),
                  ),
                ),
                Expanded(
                  child: IconButton.filled(
                    style: _buttonStyle(4, modeNotifier),
                    icon: const Icon(Icons.snowshoeing_outlined),
                    selectedIcon: const Icon(Icons.snowshoeing_outlined),
                    onPressed: () => _onButtonPressed(4),
                  ),
                ),
                Expanded(
                  child: IconButton.filled(
                    style: _buttonStyle(1, modeNotifier),
                    icon: const Icon(Icons.filter_1_outlined),
                    selectedIcon: const Icon(Icons.filter_1),
                    onPressed: () => _onButtonPressed(1),
                  ),
                ),
                Expanded(
                  child: IconButton.filled(
                    style: _buttonStyle(2, modeNotifier),
                    icon: const Icon(Icons.filter_2_outlined),
                    selectedIcon: const Icon(Icons.filter_2),
                    onPressed: () => _onButtonPressed(2),
                  ),
                ),
                Expanded(
                  child: IconButton.filled(
                    style: _buttonStyle(3, modeNotifier),
                    icon: const Icon(Icons.bookmark_added_outlined),
                    selectedIcon: const Icon(Icons.bookmark_added),
                    onPressed: () => _onButtonPressed(3),
                  ),
                ),
                Expanded(
                  child: IconButton.filled(
                    style: _buttonStyle(5, modeNotifier),
                    icon: const Icon(Icons.search),
                    selectedIcon: const Icon(Icons.search),
                    onPressed: () => _dialogBuilder(context),
                  ),
                ),
              ],
            ),
          ],
        ));
  }
}
