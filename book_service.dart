import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:libraryapp/modles/book.dart'; // Corrected import path assuming 'models' is the correct folder name

abstract class DatabaseHelper {
  factory DatabaseHelper() {
    if (kIsWeb) {
      return WebDatabaseHelper();
    } else {
      return MobileDatabaseHelper();
    }
  }

  Future<void> initDB();
  Future<int> insertBook(Book book);
  Future<List<Book>> getAllBooks({String? sortBy, bool ascending = true});
  Future<Book?> getBook(int id);
  Future<int> updateBook(Book book);
  Future<int> deleteBook(int id);
  Future<List<Book>> searchBook(String title); // Corrected return type
  Future<void> close();
  Future<void> initPreferences(); // Define in both Mobile and Web implementations
}

class MobileDatabaseHelper implements DatabaseHelper {
  static late MobileDatabaseHelper _instance;
  static Database? _database;

  MobileDatabaseHelper._internal();

  factory MobileDatabaseHelper() {
    _instance = MobileDatabaseHelper._internal();
    return _instance;
  }

  @override
  Future<Database?> get database async {
    if (_database != null) return _database;
    await initDB();
    return _database;
  }

  @override
  Future<void> initDB() async {
    // Initialize SQLite database for mobile
    _database = await openDatabase(
      'books.db',
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE books (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            author TEXT,
            year INTEGER,
            isbn TEXT,
            isRead INTEGER,
            rating INTEGER
          )
        ''');
      },
    );
  }

  @override
  Future<int> insertBook(Book book) async {
    final db = await database;
    return await db!.insert('books', {
      'id': book.id,
      'title': book.title,
      'author': book.author,
      'year': book.year,
      'isbn': book.isbn,
      'isRead': book.isRead ? 1 : 0,
      'rating': book.rating,
    });
  }

  @override
  Future<List<Book>> getAllBooks({String? sortBy, bool ascending = true}) async {
    final db = await database;
    String orderByClause = _getOrderByClause(sortBy, ascending);
    final result = await db!.query('books', orderBy: orderByClause);
    return result.map((json) => Book.fromJson(json)).toList();
  }

  String _getOrderByClause(String? sortBy, bool ascending) {
    if (sortBy == 'author') {
      return ascending ? 'author ASC' : 'author DESC';
    } else if (sortBy == 'rating') {
      return ascending ? 'rating DESC' : 'rating ASC';
    } else {
      return ascending ? 'title ASC' : 'title DESC';
    }
  }

  @override
  Future<Book?> getBook(int id) async {
    final db = await database;
    final result = await db!.query(
      'books',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (result.isNotEmpty) {
      return Book.fromJson(result.first);
    } else {
      return null;
    }
  }

  @override
  Future<int> updateBook(Book book) async {
    final db = await database;
    return await db!.update(
      'books',
      {
        'title': book.title,
        'author': book.author,
        'year': book.year,
        'isbn': book.isbn,
        'isRead': book.isRead ? 1 : 0,
        'rating': book.rating,
      },
      where: 'id = ?',
      whereArgs: [book.id],
    );
  }

  @override
  Future<int> deleteBook(int id) async {
    final db = await database;
    return await db!.delete(
      'books',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> close() async {
    final db = await database;
    await db!.close();
  }

  @override
  Future<void> initPreferences() async {
    // Example implementation for mobile preferences initialization
    final prefs = await SharedPreferences.getInstance();
    // Perform any initialization specific to preferences
  }

  @override
  Future<List<Book>> searchBook(String title) async {
    final db = await database;
    final result = await db!.query(
      'books',
      where: 'title LIKE ?',
      whereArgs: ['%$title%'],
    );
    if (result.isNotEmpty) {
      return result.map((json) => Book.fromJson(json)).toList();
    } else {
      return [];
    }
  }
}

class WebDatabaseHelper implements DatabaseHelper {
  static late WebDatabaseHelper _instance;
  static const String storageKey = 'books_db';

  WebDatabaseHelper._internal();

  factory WebDatabaseHelper() {
    _instance = WebDatabaseHelper._internal();
    return _instance;
  }

  @override
  Future<void> initDB() async {
    // No initialization needed for web storage
  }

  @override
  Future<int> insertBook(Book book) async {
    List<Book> books = await getAllBooks();
    int newId = books.isEmpty
        ? 1
        : (books
                .map((b) => b.id ?? 0)
                .reduce((max, id) => id > max ? id : max)) +
            1;
    final newBook = Book(
      id: newId,
      title: book.title,
      author: book.author,
      year: book.year,
      isbn: book.isbn,
      rating: book.rating,
      isRead: book.isRead,
    );
    books.add(newBook);
    await _saveBooks(books);
    return newId;
  }

  @override
  Future<List<Book>> getAllBooks({String? sortBy, bool ascending = true}) async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString(storageKey);
    if (jsonString == null) return [];
    List<dynamic> jsonList = json.decode(jsonString);
    List<Book> books = jsonList.map((json) => Book.fromJson(json)).toList();
    String orderByClause = _getOrderByClause(sortBy, ascending);
    switch (sortBy) {
      case 'author':
        books.sort((a, b) => ascending
            ? a.author.compareTo(b.author)
            : b.author.compareTo(a.author));
        break;
      case 'rating':
        books.sort((a, b) => ascending
            ? (a.rating ?? 0).compareTo(b.rating ?? 0)
            : (b.rating ?? 0).compareTo(a.rating ?? 0));
        break;
      default:
        books.sort((a, b) =>
            ascending ? a.title.compareTo(b.title) : b.title.compareTo(a.title));
        break;
    }
    return books;
  }

  String _getOrderByClause(String? sortBy, bool ascending) {
    if (sortBy == 'author') {
      return ascending ? 'author ASC' : 'author DESC';
    } else if (sortBy == 'rating') {
      return ascending ? 'rating DESC' : 'rating ASC';
    } else {
      return ascending ? 'title ASC' : 'title DESC';
    }
  }

  @override
  Future<Book?> getBook(int id) async {
    List<Book> books = await getAllBooks();
    try {
      return books.firstWhere((book) => book.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<int> updateBook(Book book) async {
    List<Book> books = await getAllBooks();
    int index = books.indexWhere((b) => b.id == book.id);
    if (index != -1) {
      books[index] = book;
      await _saveBooks(books);
      return 1;
    }
    return 0;
  }

  @override
  Future<int> deleteBook(int id) async {
    List<Book> books = await getAllBooks();
    int initialLength = books.length;
    books.removeWhere((book) => book.id == id);
    if (books.length < initialLength) {
      await _saveBooks(books);
      return 1;
    }
    return 0;
  }

  Future<void> _saveBooks(List<Book> books) async {
    final prefs = await SharedPreferences.getInstance();
    String jsonString = json.encode(books.map((book) => book.toJson()).toList());
    await prefs.setString(storageKey, jsonString);
  }

  @override
  Future<void> close() async {
    // No need to close anything for web storage
  }

  @override
  Future<void> initPreferences() async {
    // Example: Initialize default preferences if not already set
    final prefs = await SharedPreferences.getInstance();
    bool isFirstRun = prefs.getBool('firstRun') ?? true;
    if (isFirstRun) {
      await prefs.setBool('firstRun', false);
      await prefs.setInt('someSetting', 1);
      await prefs.setString('initialData', '{"key": "value"}');
      // Initialize other preferences as needed
    }
    // Perform any other initialization specific to preferences
  }

  @override
  Future<List<Book>> searchBook(String title) async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString(storageKey);
    if (jsonString == null) return [];
    List<dynamic> jsonList = json.decode(jsonString);
    List<Book> books = jsonList.map((json) => Book.fromJson(json)).toList();
    books = books.where((book) => book.title.contains(title)).toList();
    return books;
  }
}
