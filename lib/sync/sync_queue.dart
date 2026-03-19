import 'package:sqflite/sqflite.dart';
import '../core/database/local_database.dart';
import 'sync_queue_model.dart';

class SyncQueue {
  Future<void> addToQueue(SyncQueueItem item) async {
    final db = await LocalDatabase.instance.database;

    await db.insert('sync_queue', item.toMap());

    print("[QUEUE] Added: ${item.actionType}");

    final count = Sqflite.firstIntValue(
      await db.rawQuery("SELECT COUNT(*) FROM sync_queue WHERE isSynced = 0"),
    );

    print("[QUEUE] Current size: $count");
  }

  Future<List<Map<String, dynamic>>> getPendingQueue() async {
    final db = await LocalDatabase.instance.database;

    return await db.query(
      'sync_queue',
      where: 'isSynced = ?',
      whereArgs: [0],
    );
  }

  Future<void> markSynced(String id) async {
    final db = await LocalDatabase.instance.database;

    await db.update(
      'sync_queue',
      {'isSynced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}