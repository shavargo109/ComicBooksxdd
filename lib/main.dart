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
    if (_themeMode == ThemeMode.light) {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.light;
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
              // title: const Center(
              //   child: Text(
              //     'test',
              //     style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
              //   ),
              // ),
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
  Widget content = Container();
  int _selectedButtonIndex =
      -1; // Variable to keep track of the selected button

  void _web(bool isLatest) async {
    final books = await fetchLatestBooks(isLatest);
    setState(() {
      content = ListView.builder(
        key: ObjectKey(books[0]),
        itemCount: books.length,
        itemBuilder: (context, index) {
          final book = books[index];
          final colorCode = index % 2 == 0 ? 100 : 300;
          return BookItem(
            book: book,
            colorCode: colorCode,
            isInterested: false,
          );
        },
      );
    });
  }

  void interestedBook() async {
    final books = await fetchLatestBooks(true);
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
    String text = '';
    if (savedBooks.isEmpty) {
      text =
          "No interested books saved! Please go to 'Today' to update your list!";
    } else if (interestedBooks.isEmpty) {
      text = "No interested books updated!";
    }

    setState(() {
      content = text.isEmpty
          ? ListView.builder(
              key: ObjectKey(books[0]),
              itemCount: interestedBooks.length,
              itemBuilder: (context, index) {
                final book = interestedBooks[index];
                final colorCode = index % 2 == 0 ? 100 : 300;
                return BookItem(
                  book: book,
                  colorCode: colorCode,
                  isInterested: true,
                );
              },
            )
          : Flex(
              direction: Axis.horizontal,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Text(
                    textAlign: TextAlign.center,
                    text,
                  ),
                ),
              ],
            );
    });
  }

  void allTime() async {
    final data = await readMessage();
    final books = data['book'] as List<Book>;
    String text = '';
    if (books.isEmpty) {
      text =
          "No interested books saved! Please go to 'Today' to update your list!";
    }
    setState(() {
      content = text.isEmpty
          ? ListView.builder(
              key: ObjectKey(books[0]),
              itemCount: books.length,
              itemBuilder: (context, index) {
                final book = books[index];
                final colorCode = index % 2 == 0 ? 100 : 300;
                return BookItem(
                  book: book,
                  colorCode: colorCode,
                  isInterested: true,
                );
              },
            )
          : Flex(
              direction: Axis.horizontal,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Text(
                    textAlign: TextAlign.center,
                    text,
                  ),
                ),
              ],
            );
    });
  }

  void _onButtonPressed(int index) {
    setState(() {
      _selectedButtonIndex = index;
    });

    switch (index) {
      case 0:
        interestedBook();
        break;
      case 1:
        _web(true);
        break;
      case 2:
        _web(false);
        break;
      case 3:
        allTime();
        break;
    }
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
          child: content,
        ),
        // const SizedBox(height: 10), // Add spacing between content and buttons
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
        // const SizedBox(height: 5), // Add padding at the bottom
      ],
    );
  }
}
