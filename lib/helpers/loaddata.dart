import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'mathxdd.dart';
import 'webscrap.dart';

Future<String> get _appDocPath async {
  final directory = await getApplicationDocumentsDirectory();
  return directory.path;
}

Future<File> get _messageFile async {
  final path = await _appDocPath;
  return File('$path/interested_booksEX.json');
}

Future<Map<String, dynamic>> readMessage() async {
  try {
    final file = await _messageFile;
    final contents = await file.readAsString();
    final jsonData = jsonDecode(contents);
    final booksJson = jsonData['book'] as List<dynamic>;
    final books = booksJson
        .map((json) => Book.fromJson(json as Map<String, dynamic>))
        .toList();
    return {'book': books};
  } catch (e) {
    return {'book': <Book>[]};
  }
}

Future<File> writeMessage(Book book) async {
  final file = await _messageFile;
  final data = await readMessage();
  final books = data['book'] as List<Book>;
  final newBooks = getWithoutRepeatedBook(books, book);
  data['book'] = newBooks;
  return file.writeAsString(jsonEncode(data));
}

Future<File> deleteMessage(int code) async {
  final file = await _messageFile;
  final data = await readMessage();
  final books = data['book'] as List<Book>;

  for (var book in books) {
    if (book.code == code) {
      books.remove(book);
      break;
    }
  }
  data['book'] = books;
  return file.writeAsString(jsonEncode(data));
}
