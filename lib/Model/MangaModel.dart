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
  bool isFavourite = false;

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
        .insertBatch(description: ChapterInfoDescription(), entities: chapters)
        .then((_) {
      print("!@! saved chapters for $title");
    });
    // categories = List<String>.from(map["categories"] as List);
  }
}

class MangaInfoDescription extends DBEntityDescription<MangaInfo> {
  @override
  String get tableName => "MangaInfo";

  @override
  MangaInfo newEntity() => MangaInfo();

  @override
  List<DBEntityField<MangaInfo>> get fields => [
        DBEntityField(
            name: "id",
            type: DBEntityFieldType.text,
            isPrimary: true,
            getValue: (entity) => entity.id,
            setValue: (entity, value) {
              entity.id = value;
            }),
        DBEntityField(
            name: "title",
            type: DBEntityFieldType.text,
            getValue: (entity) => entity.title,
            setValue: (entity, value) {
              entity.title = value;
            }),
        DBEntityField(
            name: "alias",
            type: DBEntityFieldType.text,
            getValue: (entity) => entity.alias,
            setValue: (entity, value) {
              entity.alias = value;
            }),
        DBEntityField(
            name: "posterUrl",
            type: DBEntityFieldType.text,
            getValue: (entity) => entity.posterUrl,
            setValue: (entity, value) {
              entity.posterUrl = value;
            }),
        DBEntityField(
            name: "hits",
            type: DBEntityFieldType.int,
            getValue: (entity) => entity.hits,
            setValue: (entity, value) {
              entity.hits = value;
            }),
        DBEntityField(
            name: "author",
            type: DBEntityFieldType.text,
            getValue: (entity) => entity.author,
            setValue: (entity, value) {
              entity.author = value;
            }),
        DBEntityField(
            name: "artist",
            type: DBEntityFieldType.text,
            getValue: (entity) => entity.artist,
            setValue: (entity, value) {
              entity.artist = value;
            }),
        DBEntityField(
            name: "chaptersNumber",
            type: DBEntityFieldType.int,
            getValue: (entity) => entity.chaptersNumber,
            setValue: (entity, value) {
              entity.chaptersNumber = value;
            }),
        DBEntityField(
            name: "releaseYear",
            type: DBEntityFieldType.int,
            getValue: (entity) => entity.releaseYear,
            setValue: (entity, value) {
              entity.releaseYear = value;
            }),
        DBEntityField(
            name: "language",
            type: DBEntityFieldType.int,
            getValue: (entity) => entity.language,
            setValue: (entity, value) {
              entity.language = value;
            }),
        DBEntityField(
            name: "description",
            type: DBEntityFieldType.text,
            getValue: (entity) => entity.description,
            setValue: (entity, value) {
              entity.description = value;
            }),
        DBEntityField(
            name: "fullInfoLoaded",
            type: DBEntityFieldType.int,
            getValue: (entity) => entity.fullInfoLoaded ? 1 : 0,
            setValue: (entity, value) {
              entity.fullInfoLoaded = value == 1 ? true : false;
            }),
        DBEntityField(
            name: "lastReadDate",
            type: DBEntityFieldType.real,
            getValue: (entity) => entity.lastReadDate,
            setValue: (entity, value) {
              entity.lastReadDate = value;
            }),
        DBEntityField(
            name: "isFavourite",
            type: DBEntityFieldType.int,
            getValue: (entity) => entity.isFavourite ? 1 : 0,
            setValue: (entity, value) {
              entity.isFavourite = value == 1 ? true : false;
            }),
      ];
}

class ChapterInfo {
  String mangaId;
  double number;
  double date;
  String title;
  String id;

  ChapterInfo();

  ChapterInfo.fromArray(String mangaId, List<dynamic> array) {
    this.mangaId = mangaId;
    this.number = (array[0] as num).toDouble();
    this.date = array[1];
    this.title = array[2];
    this.id = array[3];
  }
}

class ChapterInfoDescription extends DBEntityDescription<ChapterInfo> {
  @override
  String get tableName => "ChapterInfo";

  @override
  ChapterInfo newEntity() => ChapterInfo();

  @override
  List<DBEntityField<ChapterInfo>> get fields => [
        DBEntityField(
            name: "id",
            type: DBEntityFieldType.text,
            isPrimary: true,
            getValue: (entity) => entity.id,
            setValue: (entity, value) {
              entity.id = value;
            }),
        DBEntityField(
            name: "title",
            type: DBEntityFieldType.text,
            getValue: (entity) => entity.title,
            setValue: (entity, value) {
              entity.title = value;
            }),
        DBEntityField(
            name: "number",
            type: DBEntityFieldType.real,
            getValue: (entity) => entity.number,
            setValue: (entity, value) {
              entity.number = (value as num).toDouble();
            }),
        DBEntityField(
            name: "date",
            type: DBEntityFieldType.real,
            getValue: (entity) => entity.date,
            setValue: (entity, value) {
              entity.date = value;
            }),
        DBEntityField(
            name: "mangaId",
            type: DBEntityFieldType.text,
            getValue: (entity) => entity.mangaId,
            setValue: (entity, value) {
              entity.mangaId = value;
            }),
      ];
}

class MangaImageInfo {
  String chapterId;
  double index;
  String url;
  int width;
  int height;

  MangaImageInfo();

  MangaImageInfo.fromArray(String chapterId, List<dynamic> array) {
    this.chapterId = chapterId;
    this.index = (array[0] as num).toDouble();
    this.url = array[1];
    this.width = array[2];
    this.height = array[3];
  }
}

class MangaImageInfoDescription extends DBEntityDescription<MangaImageInfo> {
  @override
  String get tableName => "MangaImageInfo";

  @override
  MangaImageInfo newEntity() => MangaImageInfo();

  @override
  List<DBEntityField<MangaImageInfo>> get fields => [
        DBEntityField(
            name: "chapterId",
            type: DBEntityFieldType.text,
            getValue: (entity) => entity.chapterId,
            setValue: (entity, value) {
              entity.chapterId = value;
            }),
        DBEntityField(
            name: "indexNumber",
            type: DBEntityFieldType.int,
            getValue: (entity) => entity.index,
            setValue: (entity, value) {
              entity.index = (value as num).toDouble();
            }),
        DBEntityField(
            name: "url",
            type: DBEntityFieldType.text,
            isPrimary: true,
            getValue: (entity) => entity.url,
            setValue: (entity, value) {
              entity.url = value;
            }),
        DBEntityField(
            name: "width",
            type: DBEntityFieldType.int,
            getValue: (entity) => entity.width,
            setValue: (entity, value) {
              entity.width = value;
            }),
        DBEntityField(
            name: "height",
            type: DBEntityFieldType.int,
            getValue: (entity) => entity.height,
            setValue: (entity, value) {
              entity.height = value;
            }),
      ];
}
