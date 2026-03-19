import '../../../core/database/local_database.dart';
import 'todo_model.dart';

class TodoLocalDataSource {
  DateTime? lastFetched;

  Future<void> insertTodo(Todo todo) async {
    final db = await LocalDatabase.instance.database;
    await db.insert('todos', todo.toMap());
  }

  Future<List<Todo>> getTodos() async {
    final db = await LocalDatabase.instance.database;

    final result = await db.query('todos');

    return result.map((e) => Todo.fromMap(e)).toList();
  }

  // ✅ TTL Logic (5 minutes)
  bool shouldRefresh() {
    if (lastFetched == null) return true;

    final diff = DateTime.now().difference(lastFetched!);
    return diff.inMinutes > 5;
  }

  void updateLastFetched() {
    lastFetched = DateTime.now();
  }

  Future<void> updateTodo(Todo todo) async {
    final db = await LocalDatabase.instance.database;

    await db.update(
      'todos',
      todo.toMap(),
      where: 'id = ?',
      whereArgs: [todo.id],
    );
  }
}