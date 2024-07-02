import 'package:flutter/material.dart';
import 'package:tutorial/helpers/loaddata.dart';
import 'helpers/webscrap.dart';
import 'widgets/bookitem.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Center(
            child: Text(
              style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
              'test',
            ),
          ),
          backgroundColor: Colors.blue,
        ),
        body: const HomePage(),
      ),
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
        // separatorBuilder: (context, index) => const Divider(), for listview.seprated
      );
    });
  }

  void interestedBook() async {
    final books = await fetchLatestBooks(true);
    // final data = await ddx();
    final data = await readMessage();
    final codes = List<int>.from(data['book']['code_list']);
    print(codes);
    List<Book> interestedBooks = [];
    for (var book in books) {
      for (var code in codes) {
        if (code == book.code) {
          interestedBooks.add(book);
        }
      }
    }
    print(interestedBooks.length);
    String text = '';
    if (codes.isEmpty) {
      text =
          "No interested books saved! Please go to 'Today's updated' to update your list!";
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: content,
        ),
        const SizedBox(height: 10), // Add spacing between content and buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: ElevatedButton(
                style: ButtonStyle(
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.blue),
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.white),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                            side: BorderSide(color: Colors.white)))),
                onPressed: () => _web(true),
                child: const Text("Today's update"),
              ),
            ),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _web(false),
                child: const Text("Yesterday's update"),
              ),
            ),
            Expanded(
              child: ElevatedButton(
                onPressed: interestedBook,
                child: const Text('Interested'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10), // Add padding at the bottom
      ],
    );
  }
}
