import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'dart:io' show Platform;

class Book {
  String title;
  String ep;
  int code;

  Book({required this.title, required this.ep, required this.code});

  static String getURL(int code) {
    var codeString = code.toString();
    return Platform.isAndroid || Platform.isIOS
        ? ('https://m.manhuagui.com/comic/$codeString/')
        : ('https://tw.manhuagui.com/comic/$codeString/');
  }

  static String getCover(int code) {
    var codeString = code.toString();
    return ('https://cf.mhgui.com/cpic/h/${codeString}_10.jpg');
  }

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "ep": ep,
      "code": code,
    };
  }

  factory Book.fromJson(Map<String, dynamic> json) => Book(
        title: json['title'],
        ep: json['ep'],
        code: json['code'],
      );
}

Future<List<Book>> fetchLatestBooks(bool isLatest) async {
  try {
    final response = await http.get(
      Uri.parse('https://tw.manhuagui.com/update/'),
      headers: {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3'
      },
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      var document = parser.parse(utf8.decode(response.bodyBytes));
      var results = isLatest
          ? document.querySelectorAll('.latest-list')[0] // today
          : document.querySelectorAll('.latest-list')[1]; // yesterday
      var booksElements = results.querySelectorAll("li");
      List<Book> books = [];
      for (var element in booksElements) {
        var titleElement = element.querySelector('p.ell');
        var epElement = element.querySelector('.tt');
        var codeAttribute = element.querySelector('a')?.attributes['href'];

        if (titleElement != null &&
            epElement != null &&
            codeAttribute != null) {
          String title = titleElement.text.trim();
          String ep = epElement.text.trim();
          RegExp exp = RegExp(r'(\d+)');
          RegExpMatch? match = exp.firstMatch(codeAttribute);
          Book book = Book(title: title, ep: ep, code: int.parse(match![0]!));
          books.add(book);
        }
      }
      return books;
    } else {
      throw Exception('Failed to load page');
    }
  } catch (e) {
    print('Error: $e');
    return [];
  }
}
