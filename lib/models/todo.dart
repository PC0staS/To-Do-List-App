class Todo {
  final int? id;
  final String title;
  final String description;
  final bool isCompleted;
  final DateTime createdAt;

  Todo({
    this.id,
    required this.title,
    required this.description,
    this.isCompleted = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();


Map<String,dynamic> toMap(){
  return {
    'id': id,
    'title': title,
    'description': description,
    'isCompleted': isCompleted ? 1 : 0,
    'createdAt': createdAt.toIso8601String(),
  };
}

factory Todo.fromMap(Map<String, dynamic> map) {
  return Todo(
    id: map['id'] as int?,
    title: map['title'] as String,
    description: map['description'] as String,
    isCompleted: (map['isCompleted'] as int) == 1,
    createdAt: DateTime.parse(map['createdAt'] as String),
  );
}
}    