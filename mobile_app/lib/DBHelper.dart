import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'Photo.dart';

class DBHelper {
  static Database? _db;
  static const String ID = 'id';
  static const String NAME = 'photoName';
  static const String LAT = 'lat';
  static const String LONG = 'long';
  static const String DATE = 'date';
  static const String USERNOTES = 'userNotes';
  static const String TABLE = 'PhotosTable';
  static const String DB_NAME = 'photos.db';

  Future<Database?> get db async {
    if (null != _db) {
      return _db;
    }
    _db = await initDB();
    return _db;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, DB_NAME);
    var db = await openDatabase(path,
        version: 1, onCreate: _onCreate, onUpgrade: _onUpgrade);
    return db;
  }

  _onCreate(Database db, int version) async {
    await db.execute(
        "CREATE TABLE $TABLE ($ID INTEGER , $NAME TEXT, $LAT REAL, $LONG REAL, $DATE TEXT, $USERNOTES TEXT)");
  }

  void _onUpgrade(Database db, int oldVersion, int newVersion) {
    // Ejecutar la migración según las versiones de la base de datos
  }

  Future<Photo> save(Photo photo) async {
    var dbClient = await db;
    photo.id = await dbClient!.insert(TABLE, photo.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return photo;
  }

  Future<List<Photo>> getPhotos() async {
    var dbClient = await db;
    List<Map<String, dynamic>> maps = await dbClient!
        .query(TABLE, columns: [ID, NAME, LAT, LONG, DATE, USERNOTES]);
    List<Photo> photos = [];
    if (maps.isNotEmpty) {
      for (int i = 0; i < maps.length; i++) {
        photos.add(Photo.fromMap(maps[i]));
      }
    }
    return photos;
  }

  Future close() async {
    var dbClient = await db;
    dbClient!.close();
  }
}
