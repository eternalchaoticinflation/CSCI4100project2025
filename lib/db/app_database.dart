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
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
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

    // ───── SEED DEMO USERS ─────
    final johnId = await db.insert('users', {
      'name': 'John Smith',
      'email': 'john.smith@example.com',
      'password': 'demo',
      'photo_url': null,
      'credits': 1000,
      'bio': 'CS student and textbook hoarder',
    });

    final sarahId = await db.insert('users', {
      'name': 'Sarah Lee',
      'email': 'sarah.lee@example.com',
      'password': 'demo',
      'photo_url': null,
      'credits': 1000,
      'bio': 'Loves clean code',
    });

    final mikeId = await db.insert('users', {
      'name': 'Mike Johnson',
      'email': 'mike.johnson@example.com',
      'password': 'demo',
      'photo_url': null,
      'credits': 1000,
      'bio': 'Algorithms fan',
    });

    // ───── SEED DEMO BOOKS (original mockBooks) ─────
    await db.insert('books', {
      'isbn': '9780134685991',
      'title': 'Effective Java',
      'author': 'Joshua Bloch',
      'uploader_id': johnId,
      'condition': 'Good',
      'photo_url': null,
      'notes': 'Slight wear on cover',
    });

    await db.insert('books', {
      'isbn': '9780132350884',
      'title': 'Clean Code',
      'author': 'Robert Martin',
      'uploader_id': sarahId,
      'condition': 'Like New',
      'photo_url': null,
      'notes': 'No marks or highlights',
    });

    await db.insert('books', {
      'isbn': '9780262033848',
      'title': 'Introduction to Algorithms',
      'author': 'Cormen, Leiserson, Rivest',
      'uploader_id': mikeId,
      'condition': 'Fair',
      'photo_url': null,
      'notes': 'Some highlighting',
    });
  }


  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // destructive upgrade, but simple
    await db.execute('DROP TABLE IF EXISTS books;');
    await db.execute('DROP TABLE IF EXISTS users;');
    await _onCreate(db, newVersion);
  }

  // ───── USER QUERIES ─────

  Future<User> insertUser(User user, String password) async {
    final db = await database;
    final id = await db.insert(
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
    return User(
      id: id,
      name: user.name,
      email: user.email,
      photoUrl: user.photoUrl,
      credits: user.credits,
      bio: user.bio,
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
      id: row['id'] as int,
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
    return db.rawQuery('''
    SELECT books.*, users.name AS owner_name
    FROM books
    JOIN users ON books.uploader_id = users.id
    ORDER BY books.id DESC
  ''');
  }

  Future<List<Map<String, dynamic>>> searchBooks(String query) async {
    final db = await database;

    if (query.isEmpty) {
      return getAllBooks();
    }

    final pattern = '%$query%';
    return db.rawQuery('''
    SELECT books.*, users.name AS owner_name
    FROM books
    JOIN users ON books.uploader_id = users.id
    WHERE books.title LIKE ? OR books.author LIKE ? OR books.isbn LIKE ?
    ORDER BY books.id DESC
  ''', [pattern, pattern, pattern]);
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
