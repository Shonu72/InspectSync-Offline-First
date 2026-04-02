import 'package:drift/drift.dart';

class Conflicts extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get entityId => text()();

  TextColumn get localData => text()();   // JSON
  TextColumn get serverData => text()();  // JSON

  TextColumn get status =>
      text().withDefault(const Constant('unresolved'))();

  DateTimeColumn get createdAt => dateTime()();
}
