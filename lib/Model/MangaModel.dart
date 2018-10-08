import 'dart:async';
import 'package:sqflite/sqflite.dart';

class DBManager {
  static const _DB_NAME = "MangaReader.db";

  static Database db;

  static Future<void> initDatabase() async {
    var databasesPath = await getDatabasesPath();
    String path = databasesPath + "/" + _DB_NAME;

    db = await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute("CREATE TABLE ${ShortMangaInfo.dbEntityDescription}");
    });
  }
}

class ShortMangaInfo {
  final String id;
  final String title;
  final String alias;
  final String posterUrl;
  final int hits;

  // DB support
  static String _tableName = "ShortMangaInfo";

  static String dbEntityDescription =
      "$_tableName (id TEXT PRIMARY KEY, title TEXT, alias TEXT, posterUrl TEXT, hits INTEGER)";

  Future<void> insert(Database db) async {
    await db.insert(_tableName, toDBMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  static Future<void> insertBatch(
      Database db, List<ShortMangaInfo> items) async {
    Batch batch = db.batch();
    items.forEach((item) {
      batch.insert(_tableName, item.toDBMap(),
          conflictAlgorithm: ConflictAlgorithm.ignore);
    });
    await batch.commit(noResult: true);
  }

  static Future<List<ShortMangaInfo>> fetchAll(Database db) async {
    List fetchResult = await db.query(_tableName);
    return fetchResult.map((map) => ShortMangaInfo.fromDBMap(map)).toList();
  }

  static Future<List<ShortMangaInfo>> fetchByTitle(
      Database db, String title) async {
    List fetchResult =
        await db.query(_tableName, where: "title = ?", whereArgs: [title]);
    return fetchResult.map((map) => ShortMangaInfo.fromDBMap(map)).toList();
  }
  // End DB support

  ShortMangaInfo(this.id, this.title, this.alias, this.posterUrl, this.hits);

  factory ShortMangaInfo.fromMap(Map<String, dynamic> map) {
    return ShortMangaInfo(map["i"], map["t"], map["a"], map["im"], map["h"]);
  }

  factory ShortMangaInfo.fromDBMap(Map<String, dynamic> map) {
    return ShortMangaInfo(
        map["id"], map["title"], map["alias"], map["posterUrl"], map["hits"]);
  }

  Map<String, dynamic> toDBMap() {
    return {
      "id": id,
      "title": title,
      "alias": alias,
      "posterUrl": posterUrl,
      "hits": hits
    };
  }
}

class FullMangaInfo {
  String id;
  String title;
  String posterUrl;
  // String artist;
  String author;
  String description;
  List<String> categories;
  List<ChapterInfo> chapters;

  // Manga(this.id, this.title, this.alias, List<dynamic> chapters) {
  //   this.chapters = chapters.map((chapterArray) => Chapter(chapterArray)).toList();
  // }

  // FullMangaInfo(this.id, this.title, this.akaTitle, this.alias, this.posterUrl);

  FullMangaInfo.fromMap(String id, Map<String, dynamic> map) {
    this.id = id;
    title = map["title"];
    author = map["author"];
    description = map["description"];
    chapters = (map["chapters"] as List)
        .reversed
        .map((chapterArray) => ChapterInfo.fromArray(chapterArray))
        .toList();
  }
}

class ChapterInfo {
  final double number;
  final double date;
  final String title;
  final String id;

  ChapterInfo(this.number, this.date, this.title, this.id);

  factory ChapterInfo.fromArray(List<dynamic> array) {
    return ChapterInfo(
        (array[0] as num).toDouble(), array[1], array[2], array[3]);
  }
}

class MangaImageInfo {
  final double index;
  final String url;
  final int width;
  final int height;

  MangaImageInfo(this.index, this.url, this.width, this.height);

  factory MangaImageInfo.fromArray(List<dynamic> array) {
    return MangaImageInfo(
        (array[0] as num).toDouble(), array[1], array[2], array[3]);
  }
}
