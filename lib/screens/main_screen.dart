import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import '../widgets/todo_list_view.dart';
import '../widgets/notification_simulator.dart';
import '../widgets/live_activity_simulator.dart';
import 'add_todo.dart';
import 'dart:io';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<Todo> todos = [];
  bool isLoading = true;
  final Set<String> _newlyAddedTodos = {};
  final Map<String, bool> _pinnedTodos = {};
  bool _showNotificationSimulator = false;
  bool _showLiveActivitySimulator = false;

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _loadTodos();
  }

  /// Inicializa los servicios necesarios
  Future<void> _initializeServices() async {
    try {
      await NotificationService.initialize();
      print('✅ Services initialized successfully');
    } catch (e) {
      print('❌ Error initializing services: $e');
    }
  }

  /// Carga todas las tareas desde la base de datos
  Future<void> _loadTodos() async {
    try {
      final todoList = await DatabaseService.getAllTodos();
      setState(() {
        todos = todoList;
        isLoading = false;
      });
      
      // Verificar qué tareas están fijadas
      await _loadPinnedStatus();
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error loading todos: $e');
    }
  }

  /// Carga el estado de las tareas fijadas
  Future<void> _loadPinnedStatus() async {
    try {
      for (final todo in todos) {
        final isPinned = await NotificationService.isTodoPinned(todo);
        _pinnedTodos[todo.id.toString()] = isPinned;
      }
      setState(() {});
    } catch (e) {
      print('Error loading pinned status: $e');
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
      print('Error adding sample todos: $e');
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
      // Remover de notificaciones si está fijada
      if (_pinnedTodos[todo.id.toString()] == true) {
        await NotificationService.removeTodoFromNotification(todo);
        await NotificationService.endLiveActivity(todo);
      }
      
      await DatabaseService.deleteTodo(todo.id!);
      _loadTodos(); // Recargar la lista
    } catch (e) {
      print('Error deleting todo: $e');
    }
  }

  /// Alterna el estado de pin de una tarea
  Future<void> _toggleTodoPin(Todo todo) async {
    try {
      final isPinned = _pinnedTodos[todo.id.toString()] ?? false;
      
      if (isPinned) {
        // Desfijar tarea
        await NotificationService.removeTodoFromNotification(todo);
        await NotificationService.endLiveActivity(todo);
        _pinnedTodos[todo.id.toString()] = false;
        print('📌 Unpinned: ${todo.title}');
        
        // Ocultar simuladores si no hay más tareas pineadas
        if (_getPinnedTodos.isEmpty) {
          _showNotificationSimulator = false;
          _showLiveActivitySimulator = false;
        }
      } else {
        // Fijar tarea
        await NotificationService.pinTodoToNotification(todo);
        await NotificationService.startLiveActivity(todo);
        _pinnedTodos[todo.id.toString()] = true;
        print('📌 Pinned: ${todo.title}');
        
        // Mostrar mensaje de confirmación
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('📌 ${todo.title} pinned to notifications'),
              duration: const Duration(seconds: 2),
              backgroundColor: Colors.green,
            ),
          );
          
          // Mostrar simuladores en emuladores
          _showNotificationSimulator = true;
          if (Platform.isIOS) {
            _showLiveActivitySimulator = true;
          }
        }
      }
      
      setState(() {});
    } catch (e) {
      print('❌ Error toggling todo pin: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  /// Prueba las notificaciones con una tarea de ejemplo
  Future<void> _testNotifications() async {
    try {
      final testTodo = Todo(
        id: 999,
        title: 'Test Notification',
        description: 'This is a test notification',
        dueDate: DateTime.now(),
      );
      
      await NotificationService.pinTodoToNotification(testTodo);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🧪 Test notification sent! Check your notification panel.'),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      print('❌ Error testing notifications: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Test failed: ${e.toString()}'),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Obtiene la lista de tareas pineadas
  List<Todo> get _getPinnedTodos {
    return todos.where((todo) => _pinnedTodos[todo.id.toString()] == true).toList();
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
          // Botón para mostrar/ocultar simuladores
          if (_getPinnedTodos.isNotEmpty)
            IconButton(
              onPressed: () {
                setState(() {
                  _showNotificationSimulator = !_showNotificationSimulator;
                  if (Platform.isIOS) {
                    _showLiveActivitySimulator = !_showLiveActivitySimulator;
                  }
                });
              },
              icon: Icon(
                _showNotificationSimulator ? Icons.visibility_off : Icons.visibility,
              ),
              tooltip: 'Toggle Notification Simulator',
            ),
          // Botón para probar notificaciones
          IconButton(
            onPressed: _testNotifications,
            icon: const Icon(Icons.notifications_active),
            tooltip: 'Test Notifications',
          ),
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
      body: Stack(
        children: [
          _buildBody(),
          // Simuladores superpuestos
          if (_showNotificationSimulator && _getPinnedTodos.isNotEmpty)
            Positioned(
              top: 16,
              left: 0,
              right: 0,
              child: NotificationSimulator(
                pinnedTodos: _getPinnedTodos,
                onClose: () {
                  setState(() {
                    _showNotificationSimulator = false;
                  });
                },
              ),
            ),
          if (_showLiveActivitySimulator && _getPinnedTodos.isNotEmpty && Platform.isIOS)
            Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: LiveActivitySimulator(
                pinnedTodos: _getPinnedTodos,
                onClose: () {
                  setState(() {
                    _showLiveActivitySimulator = false;
                  });
                },
              ),
            ),
        ],
      ),
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
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _testNotifications,
              icon: const Icon(Icons.notifications_active),
              label: const Text('Probar Notificaciones'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return TodoListView(
      todos: todos,
      onTodoToggle: _toggleTodo,
      onTodoDelete: _deleteTodo,
      onTodoPin: _toggleTodoPin,
      newlyAddedTodos: _newlyAddedTodos,
      pinnedTodos: _pinnedTodos,
    );
  }
}


