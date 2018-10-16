import 'package:manga_reader/Model/DBModel.dart';

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