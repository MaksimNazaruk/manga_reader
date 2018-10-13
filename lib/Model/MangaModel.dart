import 'package:manga_reader/Model/DBModel.dart';

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

  MangaInfo();

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
