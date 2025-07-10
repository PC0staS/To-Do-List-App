import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/todo.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  static bool _isInitialized = false;
  static final Set<String> _pinnedTodos = {}; // Para simular en emuladores
  
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Configuración básica para Android
      const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      
      // Configuración básica para iOS
      const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      
      const InitializationSettings initializationSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );
      
      final result = await _notifications.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationResponse,
      );
      
      // Crear canal de notificación para Android
      if (Platform.isAndroid) {
        await _createNotificationChannel();
      }
      
      _isInitialized = result ?? false;
      
      print('Notification service initialized: $_isInitialized');
    } catch (e) {
      print('Error initializing notifications: $e');
      // En caso de error, seguimos funcionando sin notificaciones
      _isInitialized = true;
    }
  }
  
  static Future<void> _createNotificationChannel() async {
    try {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'todo_channel',
        'Todo Tasks',
        description: 'Notifications for pinned todo tasks',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
        showBadge: true,
      );
      
      await _notifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
      
      print('Notification channel created successfully');
    } catch (e) {
      print('Error creating notification channel: $e');
    }
  }
  
  static void _onNotificationResponse(NotificationResponse response) {
    print('Notification clicked: ${response.payload}');
  }
  
  /// Fija una tarea como notificación persistente
  static Future<void> pinTodoToNotification(Todo todo) async {
    if (!_isInitialized) {
      await initialize();
    }
    
    try {
      // Agregar a la lista local primero
      _pinnedTodos.add(todo.id.toString());
      
      if (Platform.isAndroid) {
        await _showAndroidNotification(todo);
      } else if (Platform.isIOS) {
        await _showIOSNotification(todo);
      }
      
      print('✅ Todo pinned: ${todo.title}');
    } catch (e) {
      print('❌ Error pinning todo to notification: $e');
      // Mantener en la lista local aunque falle la notificación
    }
  }
  
  /// Remueve una tarea de las notificaciones
  static Future<void> removeTodoFromNotification(Todo todo) async {
    if (!_isInitialized) return;
    
    try {
      // Remover de la lista local
      _pinnedTodos.remove(todo.id.toString());
      
      final notificationId = todo.id?.hashCode ?? 0;
      await _notifications.cancel(notificationId);
      print('✅ Notification removed for: ${todo.title}');
    } catch (e) {
      print('❌ Error removing notification: $e');
    }
  }
  
  /// Muestra una notificación en Android
  static Future<void> _showAndroidNotification(Todo todo) async {
    try {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'todo_channel',
        'Todo Tasks',
        channelDescription: 'Notifications for pinned todo tasks',
        importance: Importance.high,
        priority: Priority.high,
        ongoing: true, // Notificación persistente
        autoCancel: false,
        icon: '@mipmap/ic_launcher',
        playSound: true,
        enableVibration: true,
        category: AndroidNotificationCategory.reminder,
        visibility: NotificationVisibility.public,
      );
      
      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
      );
      
      String body = 'Pinned task - Tap to view';
      if (todo.description.isNotEmpty) {
        body = todo.description;
      }
      if (todo.dueDate != null) {
        final dueDate = todo.dueDate!;
        body += ' • Due: ${dueDate.day}/${dueDate.month}/${dueDate.year}';
      }
      
      await _notifications.show(
        todo.id?.hashCode ?? 0,
        '📌 ${todo.title}',
        body,
        notificationDetails,
        payload: 'todo_${todo.id}',
      );
      
      print('📱 Android notification shown for: ${todo.title}');
    } catch (e) {
      print('❌ Error showing Android notification: $e');
      throw e;
    }
  }
  
  /// Muestra una notificación en iOS
  static Future<void> _showIOSNotification(Todo todo) async {
    try {
      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.timeSensitive,
      );
      
      const NotificationDetails notificationDetails = NotificationDetails(
        iOS: iosDetails,
      );
      
      String body = 'Pinned task - Tap to view';
      if (todo.description.isNotEmpty) {
        body = todo.description;
      }
      
      await _notifications.show(
        todo.id?.hashCode ?? 0,
        '📌 ${todo.title}',
        body,
        notificationDetails,
        payload: 'todo_${todo.id}',
      );
      
      print('🍎 iOS notification shown for: ${todo.title}');
    } catch (e) {
      print('❌ Error showing iOS notification: $e');
      throw e;
    }
  }
  
  /// Verifica si una tarea está fijada
  static Future<bool> isTodoPinned(Todo todo) async {
    if (!_isInitialized) return false;
    
    try {
      // Primero verificar la lista local
      if (_pinnedTodos.contains(todo.id.toString())) {
        return true;
      }
      
      // En Android, también verificar notificaciones activas
      if (Platform.isAndroid) {
        final activeNotifications = await _notifications.getActiveNotifications();
        final isActive = activeNotifications.any((notification) => 
          notification.id == (todo.id?.hashCode ?? 0));
        
        if (isActive) {
          // Sincronizar con la lista local
          _pinnedTodos.add(todo.id.toString());
          return true;
        }
      }
      
      return false;
    } catch (e) {
      print('❌ Error checking if todo is pinned: $e');
      // Fallback a la lista local
      return _pinnedTodos.contains(todo.id.toString());
    }
  }
  
  /// Obtiene el número de tareas pineadas
  static int getPinnedCount() {
    return _pinnedTodos.length;
  }
  
  /// Obtiene la lista de IDs de tareas pineadas
  static Set<String> getPinnedTodoIds() {
    return Set.from(_pinnedTodos);
  }
  
  /// Limpia todas las notificaciones
  static Future<void> cancelAllNotifications() async {
    try {
      await _notifications.cancelAll();
      _pinnedTodos.clear();
      print('✅ All notifications cancelled');
    } catch (e) {
      print('❌ Error cancelling notifications: $e');
    }
  }
  
  /// Placeholder para Live Activities (iOS)
  static Future<void> startLiveActivity(Todo todo) async {
    print('🔄 Live Activity placeholder for: ${todo.title}');
  }
  
  /// Placeholder para actualizar Live Activities (iOS)
  static Future<void> updateLiveActivity(Todo todo) async {
    print('🔄 Update Live Activity placeholder for: ${todo.title}');
  }
  
  /// Placeholder para terminar Live Activities (iOS)
  static Future<void> endLiveActivity(Todo todo) async {
    print('🔄 End Live Activity placeholder for: ${todo.title}');
  }
}
