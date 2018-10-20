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

class DBEntityField<T> {
  final String name;
  final DBEntityFieldType type;
  final bool nullable;
  final bool isPrimary; // only one field can be primary
  final dynamic defaultValue;
  final dynamic Function(T entity) getValue;
  final Function(T entity, dynamic newValue) setValue;
  // DBEntityDescription
  //     referenceEntityDescription; // used for entity-based fields of types entity and array

  DBEntityField(
      {@required this.name,
      @required this.type,
      this.nullable = true,
      this.isPrimary = false,
      this.defaultValue,
      this.getValue,
      this.setValue});

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
    if (defaultValue != null) {
      String value = (defaultValue is String) ? "'$defaultValue'" : "$defaultValue";
      description += " DEFAULT $value";
    }
    if (!nullable) {
      description += " NOT NULL";
    }
    return description;
  }
}

abstract class DBEntityDescription<T> {
  List<DBEntityField<T>> get fields;
  String get tableName;
  T newEntity();

  DBEntityField<T> get keyField {
    return fields.firstWhere((field) {
      return field.isPrimary;
    });
  }

  String get sqlDescription {
    String fieldsDescription =
        fields.map((field) => field.sqlDescription).toList().join(", ");
    return "$tableName ($fieldsDescription)";
  }

  T fromDBMap(Map<String, dynamic> map) {
    T entity = newEntity();
    fields.forEach((field) {
      field.setValue(entity, map[field.name]);
    });
    return entity;
  }

  Map<String, dynamic> toDBMap(T entity) {
    Map<String, dynamic> map = {};
    fields.forEach((field) {
      map[field.name] = field.getValue(entity);
    });
    return map;
  }
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

  Future<List<T>> fetchAll<T>(DBEntityDescription<T> description,
      {String ordering}) async {
    List fetchResult =
        await _db.query(description.tableName, orderBy: ordering);
    return fetchResult.map((map) => description.fromDBMap(map)).toList();
  }

  Future<List<T>> fetchWithPredicate<T>(
      DBEntityDescription<T> description, String predicate,
      {String ordering}) async {
    List fetchResult = await _db.query(description.tableName,
        where: predicate, orderBy: ordering);
    return fetchResult.map((map) => description.fromDBMap(map)).toList();
  }

  Future<T> fetchByKey<T>(
      DBEntityDescription<T> description, dynamic key) async {
        // TODO: check correspondence of key to the actual field type?
    String keyFieldName = description.keyField.name;
    String valueDescription = key is String ? "'$key'" : "$key";
    List fetchResult = await _db.query(description.tableName, where: "$keyFieldName = $valueDescription");
    var result = fetchResult.map((map) => description.fromDBMap(map)).toList();
    return result.isNotEmpty ? result.first : null;
  }
}
