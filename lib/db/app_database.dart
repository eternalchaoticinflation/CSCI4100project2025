import 'dart:async';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../main.dart' show User, Book; // you already have these classes

class AppDatabase {
  AppDatabase._internal();
  static final AppDatabase instance = AppDatabase._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(docsDir.path, 'campus_bookshare.db');

    return openDatabase(
      dbPath,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // USERS TABLE
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        photo_url TEXT,
        credits INTEGER NOT NULL DEFAULT 1000,
        bio TEXT
      );
    ''');

    // BOOKS TABLE
    await db.execute('''
      CREATE TABLE books (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        isbn TEXT NOT NULL,
        title TEXT NOT NULL,
        author TEXT NOT NULL,
        uploader_id INTEGER NOT NULL,
        borrower_id INTEGER,
        borrow_status TEXT NOT NULL DEFAULT 'available', -- available | borrowed
        signed_out_date TEXT,
        due_date TEXT,
        condition TEXT NOT NULL,
        photo_url TEXT,
        notes TEXT,
        FOREIGN KEY (uploader_id) REFERENCES users (id),
        FOREIGN KEY (borrower_id) REFERENCES users (id)
      );
    ''');
  }

  // ───── USER QUERIES ─────

  Future<int> insertUser(User user, String password) async {
    final db = await database;
    return db.insert(
      'users',
      {
        'name': user.name,
        'email': user.email,
        'password': password,
        'photo_url': user.photoUrl,
        'credits': user.credits,
        'bio': user.bio,
      },
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<User?> getUserByEmailAndPassword(
      String email, String password) async {
    final db = await database;
    final rows = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    if (rows.isEmpty) return null;
    final row = rows.first;
    return User(
      name: row['name'] as String,
      email: row['email'] as String,
      photoUrl: row['photo_url'] as String?,
      credits: row['credits'] as int,
      bio: row['bio'] as String?,
    );
  }

  // ───── BOOK QUERIES ─────

  Future<int> insertBook({
    required String isbn,
    required String title,
    required String author,
    required int uploaderId,
    required String condition,
    String? photoUrl,
    String? notes,
  }) async {
    final db = await database;
    return db.insert('books', {
      'isbn': isbn,
      'title': title,
      'author': author,
      'uploader_id': uploaderId,
      'condition': condition,
      'photo_url': photoUrl,
      'notes': notes,
      'borrow_status': 'available',
    });
  }

  Future<List<Map<String, dynamic>>> getAllBooks() async {
    final db = await database;
    return db.query('books', orderBy: 'id DESC');
  }

  Future<void> markBookBorrowed({
    required int bookId,
    required int borrowerId,
    required DateTime signedOut,
    required DateTime dueDate,
  }) async {
    final db = await database;
    await db.update(
      'books',
      {
        'borrower_id': borrowerId,
        'borrow_status': 'borrowed',
        'signed_out_date': signedOut.toIso8601String(),
        'due_date': dueDate.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [bookId],
    );
  }

  Future<void> markBookReturned(int bookId) async {
    final db = await database;
    await db.update(
      'books',
      {
        'borrower_id': null,
        'borrow_status': 'available',
        'signed_out_date': null,
        'due_date': null,
      },
      where: 'id = ?',
      whereArgs: [bookId],
    );
  }
}
