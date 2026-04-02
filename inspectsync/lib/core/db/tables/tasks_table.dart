import 'package:drift/drift.dart';

class Tasks extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();

  RealColumn get lat => real().nullable()();
  RealColumn get lng => real().nullable()();

  TextColumn get status => text()(); // pending, completed
  IntColumn get version => integer().withDefault(const Constant(1))();

  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
