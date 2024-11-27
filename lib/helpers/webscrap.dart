import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'dart:io';
import 'package:lzstring/lzstring.dart';
import '../constant/constant.dart';

class Episode {
  String episode;
  String link;
  String em;
  Episode({required this.episode, required this.link, required this.em});
}

class Book {
  String title;
  String ep;
  int code;

  Book({required this.title, required this.ep, required this.code});

  static String getURL(int code) {
    final codeString = code.toString();
    return Platform.isAndroid || Platform.isIOS
        ? ('https://m.manhuagui.com/comic/$codeString/')
        : ('https://tw.manhuagui.com/comic/$codeString/');
  }

  static String getCover(int code) {
    final codeString = code.toString();
    return ('https://cf.mhgui.com/cpic/h/$codeString.jpg');
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

Future<http.Response> _getReponse(String url) async {
  final response = await http
      .get(
        Uri.parse(url),
        headers: header,
      )
      .timeout(const Duration(seconds: 10));
  return response;
}

Future<List<Book>> fetchLatestBooks(bool isLatest) async {
  try {
    final response = await _getReponse('https://tw.manhuagui.com/update/');

    if (response.statusCode == 200) {
      final document = parser.parse(utf8.decode(response.bodyBytes));
      var results = isLatest
          ? document.querySelectorAll('.latest-list')[0] // today
          : document.querySelectorAll('.latest-list')[1]; // yesterday
      final booksElements = results.querySelectorAll("li");
      List<Book> books = [];
      for (var element in booksElements) {
        final titleElement = element.querySelector('p.ell');
        final epElement = element.querySelector('.tt');
        final codeAttribute = element.querySelector('a')?.attributes['href'];

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

Future<List<Episode>> fetchEpisode(int code) async {
  final codeString = code.toString();
  List<Episode> episodeArray = [];
  try {
    final response =
        await _getReponse('https://tw.manhuagui.com/comic/$codeString/');

    if (response.statusCode == 200) {
      final document = parser.parse(utf8.decode(response.bodyBytes));
      final warning = document.querySelector('.warning-bar');
      var results = document.querySelectorAll('.chapter-list.cf.mt10');
      // if there is warning content blocked, decode it to process
      if (warning != null) {
        final encodedData =
            document.querySelectorAll('input').last.attributes['value'];
        final decompressedData =
            await LZString.decompressFromBase64(encodedData);
        final fakeDocument = parser.parse(decompressedData);
        results = fakeDocument.querySelectorAll('.chapter-list.cf.mt10');
      }

      for (final epiArray in results) {
        final epiBlocks = epiArray.querySelectorAll('ul');
        for (final epiBlock in epiBlocks.reversed) {
          final epi = epiBlock.querySelectorAll('li');
          for (final book in epi) {
            final ep = book.querySelector('a')?.attributes['title'];
            final link = book.querySelector('a')?.attributes['href'];
            final em = book.querySelector('em')?.attributes['class'];
            if (ep != null && link != null) {
              Episode episode = em != null
                  ? Episode(episode: ep, link: link, em: em)
                  : Episode(episode: ep, link: link, em: 'old');
              episodeArray.add(episode);
              // print('$ep,$link,$em');
            }
          }
        }
      }
      return episodeArray;
    }
  } catch (e) {
    print('Error: $e');
  }
  return [];
}

Future<Map<String, dynamic>> getEpsiodeImage(String link) async {
  // final episodeURL = await fetchEpisode(code, true);
  final res = await _getReponse("https://tw.manhuagui.com$link");
  final regex = RegExp(r"""^.*\}\('(.*)',(\d*),(\d*),'([\w|\+|\/|=]*)'.*$""");
  final match = regex.firstMatch(res.body);

  if (match != null) {
    final function = match.group(1) ?? '';
    final a = int.parse(match.group(2) ?? '0');
    final c = int.parse(match.group(3) ?? '0');
    final compressedData = match.group(4) ?? '';

    // print("Raw Compressed Data: $compressedData");

    final decompressedData =
        await LZString.decompressFromBase64(compressedData);
    // print("Decompressed Data: $decompressedData");

    if (decompressedData != null) {
      final episodeData = _decode(function, a, c, decompressedData.split('|'));
      return episodeData;
    }
  }
  return {};
}

Map<String, dynamic> _decode(String function, int a, int c, List<String> data) {
  String itr(int value, int num) {
    const chars =
        '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
    return value <= 0 ? '' : itr(value ~/ num, num) + chars[value % num];
  }

  String tr(int value, int num) {
    final result = itr(value, num);
    return result.isEmpty ? '0' : result;
  }

  String e(int c) {
    return (c < a ? '' : e(c ~/ a)) +
        (c % a > 35 ? String.fromCharCode(c % a + 29) : tr(c % a, 36));
  }

  // Generate dictionary mapping
  c -= 1;
  final d = <String, String>{};
  while (c + 1 > 0) {
    final key = e(c);
    d[key] = data[c].isEmpty ? key : data[c]; // Decode each entry
    c -= 1;
  }

  final substitutedFunction = function.replaceAllMapped(
    RegExp(r'\b\w+\b'),
    (match) => d[match.group(0) ?? ''] ?? match.group(0)!,
  );
  final jsonMatch = RegExp(r'(\{.*\})').firstMatch(substitutedFunction);
  if (jsonMatch != null) {
    try {
      return jsonDecode(jsonMatch.group(1)!);
    } catch (e) {
      print("JSON Decoding Error: $e");
    }
  }
  return {};
}

Stream<Uint8List> getImagedataStream(Map<String, dynamic> episodeData) async* {
  final path = episodeData['path'];
  for (final url in episodeData['files']) {
    String pgUrl = "https://i.hamreus.com$path$url";
    final Map<String, String> params = {
      'e': episodeData['sl']['e'].toString(),
      'm': episodeData['sl']['m'],
    };
    try {
      final uri = Uri.parse(pgUrl).replace(queryParameters: params);
      await Future.delayed(const Duration(milliseconds: 500));
      final response = await http.get(uri, headers: header);
      if (response.statusCode == 200) {
        yield response.bodyBytes; // Emit each image immediately
      }
    } catch (e) {
      print('Error fetching image: $e');
    }
  }
}

Future<List<Book>> searchResult(String keyword) async {
  List<Book> books = [];
  late int page;

  try {
    final response =
        await _getReponse('https://tw.manhuagui.com/s/${keyword}_p1.html');
    if (response.statusCode == 200) {
      // get total searched page, then loop each page to get all the result
      final document = parser.parse(utf8.decode(response.bodyBytes));
      final pagee =
          document.querySelector('.pager')?.children.last.attributes['href'];
      RegExp exp = RegExp(r'(\d+)');
      RegExpMatch? match = exp.firstMatch(pagee!);
      page = int.parse(match![0]!);
    }
    await Future.delayed(const Duration(seconds: 1));
  } catch (e) {
    print('Error in getting pages: $e');
    return [];
  }
  page = page > 10
      ? 10
      : page; // prevent large amount of search, need to fix when search result is too large
  for (var i = 1; i <= page; i++) {
    await Future.delayed(const Duration(seconds: 2));
    try {
      final p = i.toString();
      final res =
          await _getReponse('https://tw.manhuagui.com/s/${keyword}_p$p.html');

      if (res.statusCode == 200) {
        final document = parser.parse(utf8.decode(res.bodyBytes));
        final searchResult = document.querySelectorAll('.book-detail');

        for (final book in searchResult) {
          final title = book.querySelector('dt')?.children.first.text.trim();
          final asd =
              book.querySelector('span')?.querySelector('span')?.text.trim();
          final ep1 =
              book.querySelector('span')?.querySelector('a')?.text.trim();
          final ep = '$asd$ep1';
          final href =
              book.querySelector('dt')?.children.first.attributes['href'];
          RegExp exp = RegExp(r'(\d+)');
          RegExpMatch? match = exp.firstMatch(href!);
          final code = int.parse(match![0]!);
          // print('$title,$ep,$code');
          Book booked = Book(title: title!, ep: ep, code: code);
          books.add(booked);
        }
        // await Future.delayed(const Duration(seconds: 1));
      }
    } catch (e) {
      print('Error in searching $page: $e');
      return [];
    }
  }
  return books;
}
