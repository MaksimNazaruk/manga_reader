import 'dart:core';

import 'package:meta/meta.dart';

enum DBEntityFieldType {
  text,
  int,
  real,
  blob,
  entity,
  array // TODO: how?
}

class DBEntityField {
  final String name;
  final DBEntityFieldType type;
  final bool isPrimary; // only one field can be primary
  DBEntityDescription
      referenceEntityDescription; // used for entity-based fields of types entity and array

  DBEntityField(
      {@required this.name,
      @required this.type,
      this.isPrimary = false,
      this.referenceEntityDescription});
}

abstract class DBEntityDescription<T> {
  List<DBEntityField> get fields;
  T fromDBMap(Map<String, dynamic> map);
  Map<String,dynamic> toDBMap(T entity);

  String get sqlDescription {
    
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
}
