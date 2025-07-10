import 'package:flutter/material.dart';
import '../models/todo.dart';
import 'todo_item_widget.dart';
import 'todo_section_header.dart';

class TodoListView extends StatefulWidget {
  final List<Todo> todos;
  final Function(Todo) onToggleComplete;
  final Function(Todo) onDelete;
  final Set<String> newlyAddedTodos;

  const TodoListView({
    super.key,
    required this.todos,
    required this.onToggleComplete,
    required this.onDelete,
    this.newlyAddedTodos = const {},
  });

  @override
  State<TodoListView> createState() => _TodoListViewState();
}

class _TodoListViewState extends State<TodoListView> with TickerProviderStateMixin {
  final Map<String, bool> _fadingInItems = {};

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    // Marcar elementos recién agregados para animación de entrada
    for (final todoId in widget.newlyAddedTodos) {
      _fadingInItems[todoId] = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filtrar tareas por categorías - separando completadas de no completadas
    final overdueTodos = widget.todos.where((todo) => 
      !todo.isCompleted && 
      todo.isOverdue && 
      !todo.isDueYesterday
    ).toList();
    
    final todayTodos = widget.todos.where((todo) => 
      !todo.isCompleted && 
      todo.isDueToday
    ).toList();
    
    final tomorrowTodos = widget.todos.where((todo) => 
      !todo.isCompleted && 
      todo.isDueTomorrow
    ).toList();
    
    final upcomingTodos = widget.todos.where((todo) => 
      !todo.isCompleted &&
      todo.dueDate != null && 
      !todo.isDueToday && 
      !todo.isDueTomorrow && 
      !todo.isOverdue
    ).toList();
    
    final noDateTodos = widget.todos.where((todo) => 
      !todo.isCompleted && 
      todo.dueDate == null
    ).toList();
    
    final finishedTodos = widget.todos.where((todo) => todo.isCompleted).toList();

    return Container(
      color: const Color(0xFFFAF9F9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sección "Overdue"
                  if (overdueTodos.isNotEmpty) ...[
                    TodoSectionHeader(title: 'Overdue', count: overdueTodos.length),
                    ...overdueTodos.map((todo) => TodoItemWidget(
                      key: ValueKey('overdue_${todo.id}'),
                      todo: todo,
                      onToggleComplete: widget.onToggleComplete,
                      onDelete: widget.onDelete,
                      isNewlyAdded: widget.newlyAddedTodos.contains(todo.id.toString()),
                    )),
                  ],

                  // Sección "Today"
                  if (todayTodos.isNotEmpty) ...[
                    TodoSectionHeader(title: 'Today', count: todayTodos.length),
                    ...todayTodos.map((todo) => TodoItemWidget(
                      key: ValueKey('today_${todo.id}'),
                      todo: todo,
                      onToggleComplete: widget.onToggleComplete,
                      onDelete: widget.onDelete,
                      isNewlyAdded: widget.newlyAddedTodos.contains(todo.id.toString()),
                    )),
                  ],

                  // Sección "Tomorrow"
                  if (tomorrowTodos.isNotEmpty) ...[
                    TodoSectionHeader(title: 'Tomorrow', count: tomorrowTodos.length),
                    ...tomorrowTodos.map((todo) => TodoItemWidget(
                      key: ValueKey('tomorrow_${todo.id}'),
                      todo: todo,
                      onToggleComplete: widget.onToggleComplete,
                      onDelete: widget.onDelete,
                      isNewlyAdded: widget.newlyAddedTodos.contains(todo.id.toString()),
                    )),
                  ],

                  // Sección "Upcoming"
                  if (upcomingTodos.isNotEmpty) ...[
                    TodoSectionHeader(title: 'Upcoming', count: upcomingTodos.length),
                    ...upcomingTodos.map((todo) => TodoItemWidget(
                      key: ValueKey('upcoming_${todo.id}'),
                      todo: todo,
                      onToggleComplete: widget.onToggleComplete,
                      onDelete: widget.onDelete,
                      isNewlyAdded: widget.newlyAddedTodos.contains(todo.id.toString()),
                    )),
                  ],

                  // Sección "No Date"
                  if (noDateTodos.isNotEmpty) ...[
                    TodoSectionHeader(title: 'No Date', count: noDateTodos.length),
                    ...noDateTodos.map((todo) => TodoItemWidget(
                      key: ValueKey('nodate_${todo.id}'),
                      todo: todo,
                      onToggleComplete: widget.onToggleComplete,
                      onDelete: widget.onDelete,
                      isNewlyAdded: widget.newlyAddedTodos.contains(todo.id.toString()),
                    )),
                  ],

                  // Sección "Finished"
                  if (finishedTodos.isNotEmpty) ...[
                    TodoSectionHeader(title: 'Finished', count: finishedTodos.length),
                    ...finishedTodos.map((todo) => TodoItemWidget(
                      key: ValueKey('finished_${todo.id}'),
                      todo: todo,
                      onToggleComplete: widget.onToggleComplete,
                      onDelete: widget.onDelete,
                      isNewlyAdded: _fadingInItems.containsKey(todo.id.toString()),
                    )),
                  ],

                  // Espacio al final
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
