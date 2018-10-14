import 'package:manga_reader/Model/DBModel.dart';
import 'package:manga_reader/Model/MangaModel.dart';

class DBProvider {
  static DBManager dbManager =
      DBManager(fileName: "MangaReader.db", model: MangaDBModel());
}

class MangaDBModel extends DBModel {
  @override
  List<DBEntityDescription> get entityDescriptions => [
        MangaInfoDescription(),
        ChapterInfoDescription(),
        MangaImageInfoDescription()
      ];
}
