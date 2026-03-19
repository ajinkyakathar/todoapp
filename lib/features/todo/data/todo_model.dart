class Todo {
  final String id;
  final String title;
  final bool isCompleted;
  final DateTime updatedAt;

  Todo({
    required this.id,
    required this.title,
    required this.isCompleted,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted ? 1 : 0,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'],
      title: map['title'],
      isCompleted: map['isCompleted'] == 1,
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }
}