import 'package:drift/drift.dart';

class SyncQueue extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get entityId => text()(); // taskId
  TextColumn get entityType => text()(); // "task"

  TextColumn get action => text()(); // create, update, delete

  TextColumn get payload => text()(); // JSON string

  TextColumn get status => text()
      .withDefault(const Constant('pending'))(); // pending, syncing, failed

  IntColumn get retryCount =>
      integer().withDefault(const Constant(0))();

  DateTimeColumn get createdAt => dateTime()();
}
