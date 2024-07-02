import 'webscrap.dart';

List<Book> getWithoutRepeatedBook(List<Book> books, Book newBook) {
  for (var book in books) {
    if (book.code == newBook.code) {
      if (book.ep != newBook.ep) {
        // updated episode
        book.ep = newBook.ep;
      }
      // same book, no update at all
      return books;
    }
  }
  books.add(newBook);
  return books;
}
