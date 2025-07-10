import '../models/todo.dart';

/// Clase que maneja toda la lógica de negocio para las tareas
class TodoLogic {
  
  /// Filtra tareas por diferentes criterios de tiempo
  static Map<String, List<Todo>> filterTodosByDays(List<Todo> todos) {
    final Map<String, List<Todo>> filteredTodos = {
      'overdue': [],
      'yesterday': [],
      'today': [],
      'tomorrow': [],
      'upcoming': [],
      'no_date': [],
    };

    for (final todo in todos) {
      if (todo.dueDate == null) {
        filteredTodos['no_date']!.add(todo);
      } else if (todo.isOverdue && !todo.isDueYesterday) {
        filteredTodos['overdue']!.add(todo);
      } else if (todo.isDueYesterday) {
        filteredTodos['yesterday']!.add(todo);
      } else if (todo.isDueToday) {
        filteredTodos['today']!.add(todo);
      } else if (todo.isDueTomorrow) {
        filteredTodos['tomorrow']!.add(todo);
      } else {
        filteredTodos['upcoming']!.add(todo);
      }
    }

    return filteredTodos;
  }

  /// Obtiene tareas que vencen hoy
  static List<Todo> getTodayTodos(List<Todo> todos) {
    return todos.where((todo) => todo.isDueToday).toList();
  }

  /// Obtiene tareas que vencen mañana
  static List<Todo> getTomorrowTodos(List<Todo> todos) {
    return todos.where((todo) => todo.isDueTomorrow).toList();
  }

  /// Obtiene tareas que vencieron ayer
  static List<Todo> getYesterdayTodos(List<Todo> todos) {
    return todos.where((todo) => todo.isDueYesterday).toList();
  }

  /// Obtiene tareas vencidas (excluyendo las de ayer)
  static List<Todo> getOverdueTodos(List<Todo> todos) {
    return todos.where((todo) => todo.isOverdue && !todo.isDueYesterday).toList();
  }

  /// Obtiene tareas sin fecha límite
  static List<Todo> getNoDateTodos(List<Todo> todos) {
    return todos.where((todo) => todo.dueDate == null).toList();
  }

  /// Obtiene tareas próximas (más de 1 día en el futuro)
  static List<Todo> getUpcomingTodos(List<Todo> todos) {
    return todos.where((todo) => 
      todo.dueDate != null && 
      !todo.isDueToday && 
      !todo.isDueTomorrow && 
      !todo.isOverdue
    ).toList();
  }

  /// Obtiene tareas para un día específico
  static List<Todo> getTodosForDate(List<Todo> todos, DateTime date) {
    return todos.where((todo) {
      if (todo.dueDate == null) return false;
      return todo.dueDate!.year == date.year &&
             todo.dueDate!.month == date.month &&
             todo.dueDate!.day == date.day;
    }).toList();
  }

  /// Obtiene tareas para un rango de días específico
  static List<Todo> getTodosForDaysRange(List<Todo> todos, int daysFromToday) {
    return todos.where((todo) => todo.daysFromToday == daysFromToday).toList();
  }

  /// Ordena tareas por fecha límite (las sin fecha al final)
  static List<Todo> sortByDueDate(List<Todo> todos, {bool ascending = true}) {
    final todosWithDate = todos.where((todo) => todo.dueDate != null).toList();
    final todosWithoutDate = todos.where((todo) => todo.dueDate == null).toList();

    todosWithDate.sort((a, b) {
      if (ascending) {
        return a.dueDate!.compareTo(b.dueDate!);
      } else {
        return b.dueDate!.compareTo(a.dueDate!);
      }
    });

    return [...todosWithDate, ...todosWithoutDate];
  }

  /// Ordena tareas por prioridad (vencidas primero, luego por fecha)
  static List<Todo> sortByPriority(List<Todo> todos) {
    return todos..sort((a, b) {
      // Tareas completadas al final
      if (a.isCompleted && !b.isCompleted) return 1;
      if (!a.isCompleted && b.isCompleted) return -1;

      // Entre tareas no completadas
      if (!a.isCompleted && !b.isCompleted) {
        // Tareas vencidas primero
        if (a.isOverdue && !b.isOverdue) return -1;
        if (!a.isOverdue && b.isOverdue) return 1;

        // Si ambas tienen fecha, ordenar por fecha
        if (a.dueDate != null && b.dueDate != null) {
          return a.dueDate!.compareTo(b.dueDate!);
        }

        // Tareas sin fecha al final
        if (a.dueDate == null && b.dueDate != null) return 1;
        if (a.dueDate != null && b.dueDate == null) return -1;
      }

      // Por defecto, mantener orden actual
      return 0;
    });
  }

  /// Obtiene estadísticas de las tareas
  static Map<String, int> getTodoStats(List<Todo> todos) {
    final stats = <String, int>{};
    
    stats['total'] = todos.length;
    stats['completed'] = todos.where((todo) => todo.isCompleted).length;
    stats['pending'] = todos.where((todo) => !todo.isCompleted).length;
    stats['overdue'] = getOverdueTodos(todos).length;
    stats['today'] = getTodayTodos(todos).length;
    stats['tomorrow'] = getTomorrowTodos(todos).length;
    stats['no_date'] = getNoDateTodos(todos).length;

    return stats;
  }

  /// Obtiene el progreso de completación como porcentaje
  static double getCompletionProgress(List<Todo> todos) {
    if (todos.isEmpty) return 0.0;
    final completed = todos.where((todo) => todo.isCompleted).length;
    return (completed / todos.length) * 100;
  }
}
