// lib/core/database/database_service.dart
//
// Implements [F4] using an encrypted SQLCipher database.
// This service manages the local database for storing messages,
// contacts, and other application data securely.

import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class DatabaseService {
  static const _databaseName = "citadel.db";
  static const _databaseVersion = 1;

  Database? _database;

  /// Initializes the database with a password derived from the user's identity.
  /// This ensures the database can only be opened by the legitimate user.
  Future<void> init(String password) async {
    if (_database != null) {
      return;
    }
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = p.join(documentsDirectory.path, _databaseName);
    _database = await openDatabase(
      path,
      version: _databaseVersion,
      password: password,
      onCreate: _onCreate,
    );
  }

  // Creates the database tables
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE contacts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        citizenName TEXT NOT NULL UNIQUE,
        publicKey TEXT NOT NULL,
        addedAt INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        contactId INTEGER NOT NULL,
        content TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        isSentByMe INTEGER NOT NULL,
        FOREIGN KEY (contactId) REFERENCES contacts (id)
      )
    ''');
  }
  
  // Example function to add a contact
  Future<void> addContact(String citizenName, String publicKey) async {
    await _database?.insert('contacts', {
      'citizenName': citizenName,
      'publicKey': publicKey,
      'addedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  // Add more functions here for CRUD operations on your tables (getContacts, getMessages, etc.)
}
