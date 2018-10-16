import 'package:manga_reader/Model/DBModel.dart';

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