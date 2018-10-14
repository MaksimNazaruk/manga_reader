import 'dart:core';
import 'dart:async';

import 'package:meta/meta.dart';
import 'package:sqflite/sqflite.dart';

enum DBEntityFieldType {
  text,
  int,
  real,
  blob,
  // entity,
  // array // TODO: how?
}

class DBEntityField {
  final String name;
  final DBEntityFieldType type;
  final bool isPrimary; // only one field can be primary
  // final dynamic Function() getValue;
  // final Function(dynamic newValue) setValue;
  // DBEntityDescription
  //     referenceEntityDescription; // used for entity-based fields of types entity and array

  DBEntityField(
      {@required this.name, @required this.type, this.isPrimary = false});

  Map<DBEntityFieldType, String> _sqlDataTypes = {
    DBEntityFieldType.text: "TEXT",
    DBEntityFieldType.int: "INTEGER",
    DBEntityFieldType.real: "REAL",
    DBEntityFieldType.blob: "BLOB"
  };

  String get sqlDescription {
    String description = "$name ${_sqlDataTypes[type]}";
    if (isPrimary) {
      description += " PRIMARY KEY";
    }
    return description;
  }
}

abstract class DBEntityDescription<T> {
  List<DBEntityField> get fields;
  String get tableName;
  T fromDBMap(Map<String, dynamic> map);
  Map<String, dynamic> toDBMap(T entity);

  String get sqlDescription {
    String fieldsDescription =
        fields.map((field) => field.sqlDescription).toList().join(", ");
    return "$tableName ($fieldsDescription)";
  }

  // T fromDBMap(Map<String, dynamic> map) {}

  // Map<String, dynamic> toDBMap(T entity) {
  //   Map<String, dynamic> map = {};
  //   fields.forEach((field) {
  //     map[field.name] = field.getField(entity);
  //   });
  //   return map;
  // }
}

class DBModel {
  final List<DBEntityDescription> entityDescriptions;
  DBModel({this.entityDescriptions});
}

class DBManager {
  final DBModel model;
  final String fileName;
  DBManager({this.model, this.fileName});

  Database _db;

  Future<void> initDatabase() async {
    var databasesPath = await getDatabasesPath();
    String path = databasesPath + "/" + fileName;

    _db = await openDatabase(path, version: 1, onCreate: (db, version) {
      model.entityDescriptions.forEach((entityDescription) async {
        await db.execute("CREATE TABLE ${entityDescription.sqlDescription}");
      });
    });
  }

  Future<void> insert<T>(
      {DBEntityDescription<T> description,
      T entity,
      ConflictAlgorithm conflictAlgorithm = ConflictAlgorithm.replace}) async {
    await _db.insert(description.tableName, description.toDBMap(entity),
        conflictAlgorithm: conflictAlgorithm);
  }

  Future<void> insertBatch<T>(
      {DBEntityDescription<T> description,
      List<T> entities,
      ConflictAlgorithm conflictAlgorithm = ConflictAlgorithm.replace}) async {
    Batch batch = _db.batch();
    entities.forEach((entity) {
      batch.insert(description.tableName, description.toDBMap(entity),
          conflictAlgorithm: ConflictAlgorithm.replace);
    });
    await batch.commit(noResult: true);
  }

  Future<List<T>> fetchAll<T>(DBEntityDescription<T> description) async {
    List fetchResult = await _db.query(description.tableName); // TODO: ordering
    return fetchResult.map((map) => description.fromDBMap(map)).toList();
  }

  Future<List<T>> fetchWithPredicate<T>(
      DBEntityDescription<T> description, String predicate) async {
    List fetchResult = await _db.query(description.tableName,
        where: predicate); // TODO: ordering
    return fetchResult.map((map) => description.fromDBMap(map)).toList();
  }

  // static Future<List<MangaInfo>> fetchByTitle(Database db, String title) async {
  //   List fetchResult = await db.query(_tableName,
  //       where: "title LIKE '%$title%' COLLATE NOCASE", orderBy: "hits DESC");
  //   return fetchResult.map((map) => MangaInfo.fromDBMap(map)).toList();
  // }

  // static Future<List<MangaInfo>> fetchById(Database db, String id) async {
  //   List fetchResult = await db.query(_tableName, where: "id = '$id'");
  //   return fetchResult.map((map) => MangaInfo.fromDBMap(map)).toList();
  // }
}
