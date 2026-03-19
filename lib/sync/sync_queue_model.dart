class SyncQueueItem {
  final String id;
  final String actionType;
  final String payload;
  final DateTime createdAt;
  final bool isSynced;

  SyncQueueItem({
    required this.id,
    required this.actionType,
    required this.payload,
    required this.createdAt,
    required this.isSynced,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'actionType': actionType,
      'payload': payload,
      'createdAt': createdAt.toIso8601String(),
      'isSynced': isSynced ? 1 : 0,
    };
  }
}