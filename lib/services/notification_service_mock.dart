import '../models/todo.dart';

/// Mock notification service for development and testing
/// This simulates the notification functionality without requiring platform-specific setup
class NotificationServiceMock {
  static final Set<String> _pinnedTodos = {};

  static Future<void> initialize() async {
    // Mock initialization - always succeeds
    await Future.delayed(const Duration(milliseconds: 100));
    print('Mock notification service initialized');
  }

  /// Simulates pinning a todo to notifications
  static Future<void> pinTodoToNotification(Todo todo) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _pinnedTodos.add(todo.id.toString());
    print('Mock: Pinned todo "${todo.title}" to notifications');
  }

  /// Simulates removing a todo from notifications
  static Future<void> removeTodoFromNotification(Todo todo) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _pinnedTodos.remove(todo.id.toString());
    print('Mock: Removed todo "${todo.title}" from notifications');
  }

  /// Simulates starting a Live Activity on iOS
  static Future<void> startLiveActivity(Todo todo) async {
    await Future.delayed(const Duration(milliseconds: 100));
    print('Mock: Started Live Activity for todo "${todo.title}"');
  }

  /// Simulates updating a Live Activity on iOS
  static Future<void> updateLiveActivity(Todo todo) async {
    await Future.delayed(const Duration(milliseconds: 100));
    print('Mock: Updated Live Activity for todo "${todo.title}"');
  }

  /// Simulates ending a Live Activity on iOS
  static Future<void> endLiveActivity(Todo todo) async {
    await Future.delayed(const Duration(milliseconds: 100));
    print('Mock: Ended Live Activity for todo "${todo.title}"');
  }

  /// Simulates checking if a todo is pinned
  static Future<bool> isTodoPinned(Todo todo) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _pinnedTodos.contains(todo.id.toString());
  }

  /// Simulates handling notification actions
  static Future<void> handleNotificationAction(String action, Todo todo) async {
    await Future.delayed(const Duration(milliseconds: 100));
    print('Mock: Handled notification action "$action" for todo "${todo.title}"');
  }
}
