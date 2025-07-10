class Todo {
  final int? id;
  final String title;
  final String description;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? dueDate; // Nueva propiedad para fecha límite

  Todo({
    this.id,
    required this.title,
    required this.description,
    this.isCompleted = false,
    DateTime? createdAt,
    this.dueDate, // Fecha límite opcional
  }) : createdAt = createdAt ?? DateTime.now();

// Convert the Todo object to a Map for database storage
Map<String,dynamic> toMap(){
  return {
    'id': id,
    'title': title,
    'description': description,
    'isCompleted': isCompleted ? 1 : 0,
    'createdAt': createdAt.toIso8601String(),
    'dueDate': dueDate?.toIso8601String(), // Convertir fecha límite a string
  };
}
// Factory constructor to create a Todo object from a Map
factory Todo.fromMap(Map<String, dynamic> map) {
  return Todo(
    id: map['id'] as int?,
    title: map['title'] as String,
    description: map['description'] as String,
    isCompleted: (map['isCompleted'] as int) == 1,
    createdAt: DateTime.parse(map['createdAt'] as String),
    dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate'] as String) : null,
  );
}

  // Métodos útiles para filtrar por fechas
  
  /// Verifica si la tarea vence hoy
  bool get isDueToday {
    if (dueDate == null) return false;
    final today = DateTime.now();
    return dueDate!.year == today.year && 
           dueDate!.month == today.month && 
           dueDate!.day == today.day;
  }

  /// Verifica si la tarea vence mañana
  bool get isDueTomorrow {
    if (dueDate == null) return false;
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return dueDate!.year == tomorrow.year && 
           dueDate!.month == tomorrow.month && 
           dueDate!.day == tomorrow.day;
  }

  /// Verifica si la tarea venció ayer
  bool get isDueYesterday {
    if (dueDate == null) return false;
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return dueDate!.year == yesterday.year && 
           dueDate!.month == yesterday.month && 
           dueDate!.day == yesterday.day;
  }

  /// Verifica si la tarea está vencida
  bool get isOverdue {
    if (dueDate == null) return false;
    final now = DateTime.now();
    return dueDate!.isBefore(DateTime(now.year, now.month, now.day));
  }

  /// Obtiene la diferencia en días desde hoy
  /// Retorna negativo si es pasado, positivo si es futuro
  int get daysFromToday {
    if (dueDate == null) return 0;
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final dueDateOnly = DateTime(dueDate!.year, dueDate!.month, dueDate!.day);
    return dueDateOnly.difference(todayDate).inDays;
  }

  /// Obtiene una descripción legible de la fecha límite
  String get dueDateDescription {
    if (dueDate == null) return 'Sin fecha límite';
    
    final days = daysFromToday;
    
    if (days == 0) return 'Hoy';
    if (days == 1) return 'Mañana';
    if (days == -1) return 'Ayer';
    if (days == 2) return 'Pasado mañana';
    if (days == -2) return 'Anteayer';
    if (days > 0) return 'En $days días';
    return 'Hace ${-days} días';
  }

}