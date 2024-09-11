import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tutorial/helpers/loaddata.dart';
import 'helpers/webscrap.dart';
import 'widgets/bookitem.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: const MyApp(),
    ),
  );
}

class ThemeNotifier extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    if (_themeMode != ThemeMode.light) {
      _themeMode = ThemeMode.light;
    } else {
      _themeMode = ThemeMode.dark;
    }
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return MaterialApp(
          theme: ThemeData(),
          darkTheme: ThemeData.dark(),
          themeMode: themeNotifier.themeMode,
          home: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.blue,
              actions: [
                IconButton(
                  icon: Icon(
                    themeNotifier.themeMode == ThemeMode.dark
                        ? Icons.dark_mode
                        : Icons.light_mode,
                    color: Colors.white,
                  ),
                  onPressed: () => themeNotifier.toggleTheme(),
                ),
              ],
            ),
            drawer: Drawer(
              child: Container(
                color: Colors.green, // 深綠色背景
                child: const Center(
                  child: Text("側邊欄", style: TextStyle(color: Colors.white)),
                ),
              ),
            ),
            body: const HomePage(),
          ),
        );
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<List<Book>>? _futureBooks;
  int _selectedButtonIndex =
      -1; // Variable to keep track of the selected button

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

  void _onButtonPressed(int index) {
    setState(() {
      _selectedButtonIndex = index;

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

  ButtonStyle _buttonStyle(int index) {
    bool isSelected = _selectedButtonIndex == index;
    return ButtonStyle(
      foregroundColor: MaterialStateProperty.all<Color>(
        isSelected ? Theme.of(context).colorScheme.background : Colors.blue,
      ),
      backgroundColor: MaterialStateProperty.all<Color>(
        isSelected ? Colors.blue : Theme.of(context).colorScheme.background,
      ),
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(
            color: isSelected
                ? Colors.blue
                : Theme.of(context).colorScheme.background,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: _futureBooks == null
              ? const Center(
                  child: Text(
                  "XDD",
                  style: TextStyle(
                    fontSize: 20.0,
                  ),
                ))
              : FutureBuilder<List<Book>>(
                  future: _futureBooks,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                          child: Text(
                              textAlign: TextAlign.center,
                              "No interested books saved! Please go to 'Today' to update your list!"));
                    } else {
                      final books = snapshot.data!;
                      return ListView.builder(
                        key: ObjectKey(books[0]),
                        itemCount: books.length,
                        itemBuilder: (context, index) {
                          final book = books[index];
                          final colorCode = index % 2 == 0 ? 100 : 300;
                          return BookItem(
                            book: book,
                            colorCode: colorCode,
                            isInterested: _selectedButtonIndex == 0 ||
                                _selectedButtonIndex == 3,
                          );
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
                style: _buttonStyle(0),
                icon: const Icon(Icons.thumb_up_outlined),
                selectedIcon: const Icon(Icons.thumb_up),
                onPressed: () => _onButtonPressed(0),
              ),
            ),
            Expanded(
              child: IconButton.filled(
                style: _buttonStyle(4),
                icon: const Icon(Icons.snowshoeing_outlined),
                selectedIcon: const Icon(Icons.snowshoeing_outlined),
                onPressed: () => _onButtonPressed(4),
              ),
            ),
            Expanded(
              child: IconButton.filled(
                style: _buttonStyle(1),
                icon: const Icon(Icons.filter_1_outlined),
                selectedIcon: const Icon(Icons.filter_1),
                onPressed: () => _onButtonPressed(1),
              ),
            ),
            Expanded(
              child: IconButton.filled(
                style: _buttonStyle(2),
                icon: const Icon(Icons.filter_2_outlined),
                selectedIcon: const Icon(Icons.filter_2),
                onPressed: () => _onButtonPressed(2),
              ),
            ),
            Expanded(
              child: IconButton.filled(
                style: _buttonStyle(3),
                icon: const Icon(Icons.bookmark_added_outlined),
                selectedIcon: const Icon(Icons.bookmark_added),
                onPressed: () => _onButtonPressed(3),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
