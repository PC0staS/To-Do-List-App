import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../services/database_service.dart';
import '../widgets/todo_list_view.dart';
import 'add_todo.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<Todo> todos = [];
  bool isLoading = true;
  final Set<String> _newlyAddedTodos = {};

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  /// Carga todas las tareas desde la base de datos
  Future<void> _loadTodos() async {
    try {
      final todoList = await DatabaseService.getAllTodos();
      setState(() {
        todos = todoList;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint('Error loading todos: $e');
    }
  }

  /// Añade tareas de prueba si la base de datos está vacía
  Future<void> _addSampleTodos() async {
    try {
      // Crear algunas tareas de prueba
      final today = DateTime.now();
      final tomorrow = today.add(const Duration(days: 1));
      
      final sampleTodos = [
        Todo(
          title: 'Design new icons',
          description: 'Create icons for the app',
          isCompleted: true,
          dueDate: today,
        ),
        Todo(
          title: 'Walk the dog',
          description: 'Take the dog for a walk in the park',
          dueDate: today,
        ),
        Todo(
          title: 'Buy groceries',
          description: 'Get milk, bread, and eggs',
          dueDate: today,
        ),
        Todo(
          title: 'Call plumber',
          description: 'Fix the kitchen sink',
          dueDate: today,
        ),
        Todo(
          title: 'Finish report',
          description: 'Complete the quarterly report',
          dueDate: tomorrow,
        ),
        Todo(
          title: 'Book flight tickets',
          description: 'Book tickets for vacation',
          dueDate: tomorrow,
        ),
      ];

      for (final todo in sampleTodos) {
        await DatabaseService.insertTodo(todo);
      }
      
      _loadTodos(); // Recargar después de agregar
    } catch (e) {
      debugPrint('Error adding sample todos: $e');
    }
  }

  /// Alterna el estado de completado de una tarea
  Future<void> _toggleTodo(Todo todo) async {
    try {
      final updatedTodo = Todo(
        id: todo.id,
        title: todo.title,
        description: todo.description,
        isCompleted: !todo.isCompleted,
        createdAt: todo.createdAt,
        dueDate: todo.dueDate,
      );
      
      await DatabaseService.updateTodo(updatedTodo);
      _loadTodos(); // Recargar la lista
    } catch (e) {
      print('Error toggling todo: $e');
    }
  }

  /// Elimina una tarea
  Future<void> _deleteTodo(Todo todo) async {
    try {
      await DatabaseService.deleteTodo(todo.id!);
      _loadTodos(); // Recargar la lista
    } catch (e) {
      print('Error deleting todo: $e');
    }
  }

  /// Agrega una nueva tarea
  Future<void> _addTodo(Todo todo) async {
    try {
      await DatabaseService.insertTodo(todo);
      _newlyAddedTodos.add(todo.id.toString());
      _loadTodos();
      
      // Limpiar el flag después de la animación
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) {
          setState(() {
            _newlyAddedTodos.remove(todo.id.toString());
          });
        }
      });
    } catch (e) {
      print('Error adding todo: $e');
    }
  }

  void _navigateToAddTodo() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTodoScreen(
          onAddTodo: _addTodo,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F9),
      appBar: AppBar(
        title: const Text(
          'To-Do List',
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: false,
        backgroundColor: const Color(0xFFFAF9F9),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: FloatingActionButton(
              shape: const CircleBorder(
                side: BorderSide(color: Colors.black, width: 1.5),
              ),
              mini: true,
              backgroundColor: const Color.fromARGB(255, 255, 255, 255),
              elevation: 0,
              highlightElevation: 0,
              onPressed: _navigateToAddTodo,
              child: const Icon(Icons.add, color: Color.fromARGB(255, 0, 0, 0)),
            ),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (todos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'No tienes tareas todavía.\n¡Agrega una nueva tarea!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addSampleTodos,
              child: const Text('Agregar tareas de prueba'),
            ),
          ],
        ),
      );
    }

    return TodoListView(
      todos: todos,
      onToggleComplete: _toggleTodo,
      onDelete: _deleteTodo,
      newlyAddedTodos: _newlyAddedTodos,
    );
  }
}


