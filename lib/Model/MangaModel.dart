import 'package:manga_reader/Model/DBModel.dart';
import 'package:manga_reader/Model/DBProvider.dart';

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

  Future<List<ChapterInfo>> get chapters async {
    return await DBProvider.dbManager
        .fetchWithPredicate(ChapterInfoDescription(), "mangaId = '$id'");
  }

  MangaInfo();

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

    List<ChapterInfo> chapters = (map["chapters"] as List)
        .reversed
        .map((chapterArray) => ChapterInfo.fromArray(id, chapterArray))
        .toList();
    DBProvider.dbManager
        .insertBatch(description: ChapterInfoDescription(), entities: chapters).then((_){
          print("!@! saved chapters for $title");
        });
    // categories = List<String>.from(map["categories"] as List);
  }
}

class MangaInfoDescription extends DBEntityDescription<MangaInfo> {
  @override
  String get tableName => "MangaInfo";

  @override
  MangaInfo fromDBMap(Map<String, dynamic> map) {
    MangaInfo entity = MangaInfo();
    entity
      ..id = map["id"]
      ..title = map["title"]
      ..alias = map["alias"]
      ..posterUrl = map["posterUrl"]
      ..hits = map["hits"]
      ..author = map["author"]
      ..artist = map["artist"]
      ..chaptersNumber = map["chaptersNumber"]
      ..releaseYear = map["releaseYear"]
      ..language = map["language"]
      ..description = map["description"]
      ..fullInfoLoaded = map["fullInfoLoaded"] == 1 ? true : false
      ..lastReadDate = map["lastReadDate"];

    return entity;
  }

  @override
  Map<String, dynamic> toDBMap(MangaInfo entity) {
    Map<String, dynamic> map = {};
    map["id"] = entity.id;
    map["title"] = entity.title;
    map["alias"] = entity.alias;
    map["posterUrl"] = entity.posterUrl;
    map["hits"] = entity.hits;
    map["author"] = entity.author;
    map["artist"] = entity.artist;
    map["chaptersNumber"] = entity.chaptersNumber;
    map["releaseYear"] = entity.releaseYear;
    map["language"] = entity.language;
    map["description"] = entity.description;
    map["fullInfoLoaded"] = entity.fullInfoLoaded ? 1 : 0;
    map["lastReadDate"] = entity.lastReadDate;

    return map;
  }

  @override
  List<DBEntityField> get fields => [
        DBEntityField(
            name: "id", type: DBEntityFieldType.text, isPrimary: true),
        DBEntityField(name: "title", type: DBEntityFieldType.text),
        DBEntityField(name: "alias", type: DBEntityFieldType.text),
        DBEntityField(name: "posterUrl", type: DBEntityFieldType.text),
        DBEntityField(name: "hits", type: DBEntityFieldType.int),
        DBEntityField(name: "author", type: DBEntityFieldType.text),
        DBEntityField(name: "artist", type: DBEntityFieldType.text),
        DBEntityField(name: "chaptersNumber", type: DBEntityFieldType.int),
        DBEntityField(name: "releaseYear", type: DBEntityFieldType.int),
        DBEntityField(name: "language", type: DBEntityFieldType.int),
        DBEntityField(name: "description", type: DBEntityFieldType.text),
        DBEntityField(name: "fullInfoLoaded", type: DBEntityFieldType.int),
        DBEntityField(name: "lastReadDate", type: DBEntityFieldType.real),
      ];
}

class ChapterInfo {
  final String mangaId;
  final double number;
  final double date;
  final String title;
  final String id;

  ChapterInfo(this.mangaId, this.number, this.date, this.title, this.id);

  factory ChapterInfo.fromArray(String mangaId, List<dynamic> array) {
    return ChapterInfo(
        mangaId, (array[0] as num).toDouble(), array[1], array[2], array[3]);
  }
}

class ChapterInfoDescription extends DBEntityDescription<ChapterInfo> {
  @override
  String get tableName => "ChapterInfo";

  @override
  ChapterInfo fromDBMap(Map<String, dynamic> map) {
    ChapterInfo entity = ChapterInfo(
        map["mangaId"], map["number"], map["date"], map["title"], map["id"]);
    return entity;
  }

  @override
  Map<String, dynamic> toDBMap(ChapterInfo entity) {
    Map<String, dynamic> map = {};
    map["id"] = entity.id;
    map["title"] = entity.title;
    map["number"] = entity.number;
    map["date"] = entity.date;
    map["mangaId"] = entity.mangaId;

    return map;
  }

  @override
  List<DBEntityField> get fields => [
        DBEntityField(
            name: "id", type: DBEntityFieldType.text, isPrimary: true),
        DBEntityField(name: "title", type: DBEntityFieldType.text),
        DBEntityField(name: "number", type: DBEntityFieldType.real),
        DBEntityField(name: "date", type: DBEntityFieldType.real),
        DBEntityField(name: "mangaId", type: DBEntityFieldType.text),
      ];
}

class MangaImageInfo {
  final String chapterId;
  final double index;
  final String url;
  final int width;
  final int height;

  MangaImageInfo(this.chapterId, this.index, this.url, this.width, this.height);

  factory MangaImageInfo.fromArray(String chapterId, List<dynamic> array) {
    return MangaImageInfo(
        chapterId, (array[0] as num).toDouble(), array[1], array[2], array[3]);
  }
}

class MangaImageInfoDescription extends DBEntityDescription<MangaImageInfo> {
  @override
  String get tableName => "MangaImageInfo";

  @override
  MangaImageInfo fromDBMap(Map<String, dynamic> map) {
    MangaImageInfo entity = MangaImageInfo(map["chapterId"], (map["indexNumber"] as num).toDouble(),
        map["url"], map["width"], map["height"]);
    return entity;
  }

  @override
  Map<String, dynamic> toDBMap(MangaImageInfo entity) {
    Map<String, dynamic> map = {};
    map["chapterId"] = entity.chapterId;
    map["indexNumber"] = entity.index;
    map["url"] = entity.url;
    map["width"] = entity.width;
    map["height"] = entity.height;

    return map;
  }

  @override
  List<DBEntityField> get fields => [
        DBEntityField(name: "chapterId", type: DBEntityFieldType.text),
        DBEntityField(name: "indexNumber", type: DBEntityFieldType.int),
        DBEntityField(
            name: "url", type: DBEntityFieldType.text, isPrimary: true),
        DBEntityField(name: "width", type: DBEntityFieldType.int),
        DBEntityField(name: "height", type: DBEntityFieldType.int),
      ];
}
