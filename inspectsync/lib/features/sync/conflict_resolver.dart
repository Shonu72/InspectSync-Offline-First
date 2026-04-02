import 'dart:convert';
import 'package:drift/drift.dart';
import '../../../core/db/app_database.dart';

class ConflictResolver {
  final AppDatabase _db;

  ConflictResolver(this._db);

  Future<bool> detectAndHandleConflict(String entityId, Map<String, dynamic> localPayload, Map<String, dynamic> serverPayload) async {
    // Basic logic: if versions differ or any field is different, handle conflict
    bool hasConflict = false;

    // Keys to ignore during comparison (e.g., version, timestamps)
    final ignoreKeys = {'version', 'updatedAt', 'isSynced'};

    localPayload.forEach((key, localValue) {
      if (ignoreKeys.contains(key)) return;
      
      if (serverPayload.containsKey(key)) {
        final serverValue = serverPayload[key];
        // Simple comparison for strings, numbers, etc.
        if (localValue.toString() != serverValue.toString()) {
          hasConflict = true;
        }
      }
    });
    
    if (hasConflict) {
      final localJson = jsonEncode(localPayload);
      final serverJson = jsonEncode(serverPayload);
      
      // Delete any existing unresolved conflicts for this entity first
      await (_db.delete(_db.conflicts)
            ..where((c) => c.entityId.equals(entityId) & c.status.equals('unresolved')))
          .go();

      await _db.into(_db.conflicts).insert(ConflictsCompanion.insert(
        entityId: entityId,
        localData: localJson,
        serverData: serverJson,
        createdAt: DateTime.now(),
      ));
      return true;
    }
    return false;
  }
}
