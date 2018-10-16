import 'package:manga_reader/Model/DBModel.dart';
import 'package:manga_reader/Model/DBProvider.dart';
import 'package:manga_reader/Model/MangaModel/ChapterInfo.dart';

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