import 'package:flutter/material.dart';
import '../models/todo.dart';
import 'todo_item_widget.dart';
import 'todo_section_header.dart';

class TodoListView extends StatefulWidget {
  final List<Todo> todos;
  final Function(Todo) onTodoToggle;
  final Function(Todo) onTodoDelete;
  final Function(Todo) onTodoPin;
  final Set<String> newlyAddedTodos;
  final Map<String, bool> pinnedTodos;

  const TodoListView({
    super.key,
    required this.todos,
    required this.onTodoToggle,
    required this.onTodoDelete,
    required this.onTodoPin,
    this.newlyAddedTodos = const {},
    this.pinnedTodos = const {},
  });

  @override
  State<TodoListView> createState() => _TodoListViewState();
}

class _TodoListViewState extends State<TodoListView> with TickerProviderStateMixin {
  final Map<String, bool> _fadingOutItems = {};
  final Map<String, bool> _fadingInItems = {};
  final Map<String, bool> _newItems = {};

  void _handleTodoToggle(Todo todo) {
    if (_fadingOutItems.containsKey(todo.id.toString())) return;

    setState(() {
      _fadingOutItems[todo.id.toString()] = true;
    });

    // Marcar como nuevo item si se está completando
    if (!todo.isCompleted) {
      _newItems[todo.id.toString()] = true;
    }

    // Esperar el fade out y luego hacer el toggle
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        widget.onTodoToggle(todo);
        
        setState(() {
          _fadingOutItems.remove(todo.id.toString());
          if (_newItems.containsKey(todo.id.toString())) {
            _fadingInItems[todo.id.toString()] = true;
          }
        });

        // Limpiar el fade in después de completar
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            setState(() {
              _fadingInItems.remove(todo.id.toString());
              _newItems.remove(todo.id.toString());
            });
          }
        });
      }
    });
  }

  void _handleTodoDelete(Todo todo) {
    if (_fadingOutItems.containsKey(todo.id.toString())) return;

    setState(() {
      _fadingOutItems[todo.id.toString()] = true;
    });

    // Esperar el fade out y luego eliminar
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        widget.onTodoDelete(todo);
        setState(() {
          _fadingOutItems.remove(todo.id.toString());
        });
      }
    });
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
                      onToggle: () => _handleTodoToggle(todo),
                      onDelete: () => _handleTodoDelete(todo),
                      onPin: () => widget.onTodoPin(todo),
                      showDeleteButton: false,
                      shouldFadeOut: _fadingOutItems.containsKey(todo.id.toString()),
                      shouldFadeIn: widget.newlyAddedTodos.contains(todo.id.toString()),
                      isPinned: widget.pinnedTodos[todo.id.toString()] ?? false,
                    )),
                  ],

                  // Sección "Today"
                  if (todayTodos.isNotEmpty) ...[
                    TodoSectionHeader(title: 'Today', count: todayTodos.length),
                    ...todayTodos.map((todo) => TodoItemWidget(
                      key: ValueKey('today_${todo.id}'),
                      todo: todo,
                      onToggle: () => _handleTodoToggle(todo),
                      onDelete: () => _handleTodoDelete(todo),
                      onPin: () => widget.onTodoPin(todo),
                      showDeleteButton: false,
                      shouldFadeOut: _fadingOutItems.containsKey(todo.id.toString()),
                      shouldFadeIn: widget.newlyAddedTodos.contains(todo.id.toString()),
                      isPinned: widget.pinnedTodos[todo.id.toString()] ?? false,
                    )),
                  ],

                  // Sección "Tomorrow"
                  if (tomorrowTodos.isNotEmpty) ...[
                    TodoSectionHeader(title: 'Tomorrow', count: tomorrowTodos.length),
                    ...tomorrowTodos.map((todo) => TodoItemWidget(
                      key: ValueKey('tomorrow_${todo.id}'),
                      todo: todo,
                      onToggle: () => _handleTodoToggle(todo),
                      onDelete: () => _handleTodoDelete(todo),
                      onPin: () => widget.onTodoPin(todo),
                      showDeleteButton: false,
                      shouldFadeOut: _fadingOutItems.containsKey(todo.id.toString()),
                      shouldFadeIn: widget.newlyAddedTodos.contains(todo.id.toString()),
                      isPinned: widget.pinnedTodos[todo.id.toString()] ?? false,
                    )),
                  ],

                  // Sección "Upcoming"
                  if (upcomingTodos.isNotEmpty) ...[
                    TodoSectionHeader(title: 'Upcoming', count: upcomingTodos.length),
                    ...upcomingTodos.map((todo) => TodoItemWidget(
                      key: ValueKey('upcoming_${todo.id}'),
                      todo: todo,
                      onToggle: () => _handleTodoToggle(todo),
                      onDelete: () => _handleTodoDelete(todo),
                      onPin: () => widget.onTodoPin(todo),
                      showDeleteButton: false,
                      shouldFadeOut: _fadingOutItems.containsKey(todo.id.toString()),
                      shouldFadeIn: widget.newlyAddedTodos.contains(todo.id.toString()),
                      isPinned: widget.pinnedTodos[todo.id.toString()] ?? false,
                    )),
                  ],

                  // Sección "No Date"
                  if (noDateTodos.isNotEmpty) ...[
                    TodoSectionHeader(title: 'No Date', count: noDateTodos.length),
                    ...noDateTodos.map((todo) => TodoItemWidget(
                      key: ValueKey('nodate_${todo.id}'),
                      todo: todo,
                      onToggle: () => _handleTodoToggle(todo),
                      onDelete: () => _handleTodoDelete(todo),
                      onPin: () => widget.onTodoPin(todo),
                      showDeleteButton: false,
                      shouldFadeOut: _fadingOutItems.containsKey(todo.id.toString()),
                      shouldFadeIn: widget.newlyAddedTodos.contains(todo.id.toString()),
                      isPinned: widget.pinnedTodos[todo.id.toString()] ?? false,
                    )),
                  ],

                  // Sección "Finished"
                  if (finishedTodos.isNotEmpty) ...[
                    TodoSectionHeader(title: 'Finished', count: finishedTodos.length),
                    ...finishedTodos.map((todo) => TodoItemWidget(
                      key: ValueKey('finished_${todo.id}'),
                      todo: todo,
                      onToggle: () => _handleTodoToggle(todo),
                      onDelete: () => _handleTodoDelete(todo),
                      onPin: null, // No pin para tareas completadas
                      showDeleteButton: true,
                      shouldFadeOut: _fadingOutItems.containsKey(todo.id.toString()),
                      shouldFadeIn: _fadingInItems.containsKey(todo.id.toString()),
                      isPinned: false,
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
