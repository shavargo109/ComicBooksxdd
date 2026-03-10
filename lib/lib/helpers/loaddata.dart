import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'mathxdd.dart';
import 'webscrap.dart';
import 'package:downloadsfolder/downloadsfolder.dart';
import 'package:file_picker/file_picker.dart';

class LoadData {
  Future<String> get _appDocPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _messageFile async {
    final path = await _appDocPath;
    // print(path);
    return File('$path/interested_booksEX.json');
  }

  Future<String> get _getDownloadPath async {
    Directory downloadsfolderPath;
    downloadsfolderPath = await getDownloadDirectory();
    return downloadsfolderPath.path;
  }

  Future<Map<String, dynamic>> readMessage([File? file]) async {
    try {
      file ??= await _messageFile;
      final contents = await file.readAsString();
      final jsonData = jsonDecode(contents);
      final booksJson = jsonData['book'] as List<dynamic>;
      final books = booksJson
          .map((json) => Book.fromJson(json as Map<String, dynamic>))
          .toList();
      return {'book': books};
    } catch (e) {
      print('Error: $e');
      return {'book': <Book>[]};
    }
  }

  Future<File> writeMessage(Book book) async {
    final file = await _messageFile;
    final data = await readMessage();
    final books = data['book'] as List<Book>;
    final newBooks = Mathxdd().getWithoutRepeatedBook(books, book);
    data['book'] = newBooks.map((b) => b.toJson).toList();
    return file.writeAsString(jsonEncode(data));
  }

  Future<File> deleteMessage(int code) async {
    final file = await _messageFile;
    final data = await readMessage();
    final books = data['book'] as List<Book>;

    for (Book book in books) {
      if (book.code == code) {
        books.remove(book);
        break;
      }
    }
    data['book'] = books.map((b) => b.toJson).toList();
    return file.writeAsString(jsonEncode(data));
  }

  Future<bool> exportList() async {
    final downloadPath = await _getDownloadPath;
    final file = await _messageFile;
    if (downloadPath.isNotEmpty) {
      final destinationPath = '$downloadPath/interested_booksEX.json';
      await file.copy(destinationPath);
      return true;
    } else {
      return false;
    }
  }

  Future<bool> importList() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      final data = await readMessage(File(result.files.single.path!));
      final savedBooks = data['book'] as List<Book>;
      if (savedBooks.isEmpty) {
        return false;
      } else {
        final filepath = await _messageFile;
        await File(result.files.single.path!).copy(filepath.path);
        return true;
      }
    } else {
      return false;
    }
  }
}
