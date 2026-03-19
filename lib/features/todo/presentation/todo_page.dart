import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../todo/data/todo_local_datasource.dart';
import '../../todo/data/todo_model.dart';
import '../../../sync/sync_queue.dart';
import '../../../sync/sync_queue_model.dart';
import '../../../sync/sync_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final TodoLocalDataSource localDataSource = TodoLocalDataSource();
  final SyncQueue syncQueue = SyncQueue();
  final SyncService syncService = SyncService();

  List<Todo> todos = [];

  @override
  void initState() {
    super.initState();
    loadTodos();
    listenConnectivity();
  }

  Future<void> loadTodos() async {
    final data = await localDataSource.getTodos();

    setState(() {
      todos = data;
    });

    // ✅ TTL Check
    if (localDataSource.shouldRefresh()) {
      print("[CACHE] TTL expired → should fetch from server");
      localDataSource.updateLastFetched();
    } else {
      print("[CACHE] Using cached data");
    }
  }

  Future<void> addTodo() async {
    final todo = Todo(
      id: const Uuid().v4(),
      title: "Task ${DateTime.now()}",
      isCompleted: false,
      updatedAt: DateTime.now(),
    );

    // Save locally
    await localDataSource.insertTodo(todo);

    // Add to queue
    final queueItem = SyncQueueItem(
      id: const Uuid().v4(), // ✅ UNIQUE ID (fix applied)
      actionType: "ADD_TODO",
      payload: jsonEncode(todo.toMap()),
      createdAt: DateTime.now(),
      isSynced: false,
    );

    await syncQueue.addToQueue(queueItem);

    await loadTodos();
  }

  Future<void> toggleComplete(Todo todo) async {
    final updated = Todo(
      id: todo.id,
      title: todo.title,
      isCompleted: !todo.isCompleted,
      updatedAt: DateTime.now(),
    );

    // Update locally
    await localDataSource.updateTodo(updated);

    // Add to queue (UNIQUE ID FIX)
    final queueItem = SyncQueueItem(
      id: const Uuid().v4(), // ✅ FIXED HERE
      actionType: "UPDATE_TODO",
      payload: jsonEncode(updated.toMap()),
      createdAt: DateTime.now(),
      isSynced: false,
    );

    await syncQueue.addToQueue(queueItem);

    await loadTodos();
  }

  void listenConnectivity() {
    Connectivity().onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        print("[CONNECTIVITY] Online → Sync triggered");
        syncService.sync();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Todo App")),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () async {
              await syncService.sync();
            },
            child: const Text("Sync Now"),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: todos.length,
              itemBuilder: (context, index) {
                final todo = todos[index];
                return ListTile(
                  title: Text(
                    todo.title,
                    style: TextStyle(
                      decoration: todo.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  trailing: Checkbox(
                    value: todo.isCompleted,
                    onChanged: (_) => toggleComplete(todo),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addTodo,
        child: const Icon(Icons.add),
      ),
    );
  }
}