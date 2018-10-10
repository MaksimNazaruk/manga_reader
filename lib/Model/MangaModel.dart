import 'dart:async';
import 'package:sqflite/sqflite.dart';

class DBManager {
  static const _DB_NAME = "MangaReader.db";

  static Database db;

  static Future<void> initDatabase() async {
    var databasesPath = await getDatabasesPath();
    String path = databasesPath + "/" + _DB_NAME;

    db = await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute("CREATE TABLE ${MangaInfo.dbEntityDescription}");
    });
  }
}

abstract class DBObject {

  String tableName();
  DBObject fromDBMap(Map<String, dynamic> map);
  Map<String, dynamic> toDBMap();
}

class MangaInfo {
  String id;
  String title;
  String alias;
  String posterUrl;
  int hits;
  String author;
  String artist;
  int chaptersNumber;
  int releaseYear;
  int language;
  String description;
  bool fullInfoLoaded;
  double lastReadDate;
  List<String> get categories {
    return ["~no categories~"]; // TODO: get actual categories
  }
  List<ChapterInfo> get chapters {
    return []; // TODO: fetch actual chapters
  }

MangaInfo.fromShortMap(Map<String, dynamic> map) {
    this.id = map["i"];
    title = map["t"];
    alias = map["a"];
    posterUrl = map["im"];
    hits = map["h"];
    fullInfoLoaded = false;
  }

  MangaInfo.fromFullMap(String id, Map<String, dynamic> map) {
    this.id = id;
    title = map["title"];
    alias = map["alias"];
    posterUrl = map["image"];
    hits = map["hits"];
    author = map["author"];
    artist = map["artist"];
    chaptersNumber = map["chapters_len"];
    releaseYear = map["released"];
    language = map["language"];
    description = map["description"];
    fullInfoLoaded = true;
    // chapters = (map["chapters"] as List)
    //     .reversed
    //     .map((chapterArray) => ChapterInfo.fromArray(chapterArray))
    //     .toList();
    // categories = List<String>.from(map["categories"] as List);
  }

  // DB support
  static String _tableName = "FullMangaInfo";

  static String dbEntityDescription = '''$_tableName (
        id TEXT PRIMARY KEY, 
      title TEXT, 
      alias TEXT, 
      posterUrl TEXT, 
      hits INTEGER, 
      author TEXT, 
      artist TEXT,
      chaptersNumber INT,
      releaseYear INT,
      language INT,
      description TEXT,
      fullInfoLoaded INT,
      lastReadDate REAL)''';

  MangaInfo.fromDBMap(Map<String, dynamic> map) {
    id = map["id"];
    title = map["title"];
    alias = map["alias"];
    posterUrl = map["posterUrl"];
    hits = map["hits"];
    author = map["author"];
    artist = map["artist"];
    chaptersNumber = map["chaptersNumber"];
    releaseYear = map["releaseYear"];
    language = map["language"];
    description = map["description"];
    fullInfoLoaded = map["fullInfoLoaded"] == 1 ? true : false;
    lastReadDate = map["lastReadDate"];
  }

  Map<String, dynamic> toDBMap() {
    Map<String, dynamic> map = {};
    map["id"] = id;
    map["title"] = title;
    map["alias"] = alias;
    map["posterUrl"] = posterUrl;
    map["hits"] = hits;
    map["author"] = author;
    map["artist"] = artist;
    map["chaptersNumber"] = chaptersNumber;
    map["releaseYear"] = releaseYear;
    map["language"] = language;
    map["description"] = description;
    map["fullInfoLoaded"] = fullInfoLoaded ? 1 : 0;
    map["lastReadDate"] = lastReadDate;

    return map;
  }

  Future<void> insert(Database db) async {
    await db.insert(_tableName, toDBMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<void> insertBatch(
      Database db, List<MangaInfo> items) async {
    Batch batch = db.batch();
    items.forEach((item) {
      batch.insert(_tableName, item.toDBMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    });
    await batch.commit(noResult: true);
  }

  static Future<List<MangaInfo>> fetchAll(Database db) async {
    List fetchResult = await db.query(_tableName, orderBy: "hits DESC");
    return fetchResult.map((map) => MangaInfo.fromDBMap(map)).toList();
  }

  static Future<List<MangaInfo>> fetchByTitle(
      Database db, String title) async {
    List fetchResult = await db.query(_tableName,
        where: "title LIKE '%$title%' COLLATE NOCASE", orderBy: "hits DESC");
    return fetchResult.map((map) => MangaInfo.fromDBMap(map)).toList();
  }

  static Future<List<MangaInfo>> fetchById(
      Database db, String id) async {
    List fetchResult = await db.query(_tableName,
        where: "id = '$id'");
    return fetchResult.map((map) => MangaInfo.fromDBMap(map)).toList();
  }
  // End DB support

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
