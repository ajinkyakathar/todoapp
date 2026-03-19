import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'sync_queue.dart';

class SyncService {
  final SyncQueue queue = SyncQueue();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  bool isSyncing = false;

  int successCount = 0;
  int failCount = 0;

  Future<void> sync() async {
    if (isSyncing) {
      print("[SYNC] Already running, skipping...");
      return;
    }

    isSyncing = true;

    final items = await queue.getPendingQueue();

    print("[SYNC] Pending items: ${items.length}");

    for (var item in items) {
      final id = item['id'];

      try {
        print("[SYNC] Processing: ${item['actionType']} ($id)");

        // Simulate failure
        if (Random().nextBool()) {
          throw Exception("Simulated failure");
        }

        final payload = jsonDecode(item['payload']);

        if (item['actionType'] == "ADD_TODO" ||
            item['actionType'] == "UPDATE_TODO") {
          await firestore.collection('todos').doc(payload['id']).set(payload);
        }

        await queue.markSynced(id);

        successCount++;

        print("[SYNC] Success: $id");
      } catch (e) {
        failCount++;

        print("[SYNC] Failed: $id → retrying...");

        await Future.delayed(const Duration(seconds: 2));

        try {
          final payload = jsonDecode(item['payload']);

          await firestore.collection('todos').doc(payload['id']).set(payload);

          await queue.markSynced(id);

          successCount++;

          print("[SYNC] Retry success: $id");
        } catch (e) {
          failCount++;
          print("[SYNC] Retry failed: $id");
        }
      }
    }

    print("========== SYNC SUMMARY ==========");
    print("Success Count: $successCount");
    print("Fail Count: $failCount");
    print("=================================");

    isSyncing = false;
  }
}